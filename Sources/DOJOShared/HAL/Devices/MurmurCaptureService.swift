@preconcurrency import AVFoundation
import Accelerate
import Foundation

#if !os(watchOS)

/// AVAudioEngine-based capture service for the iPhone murmur.
/// Captures at the device's native rate, converts to 16kHz mono PCM16LE,
/// ships 100ms audio chunks + 1s quality frames via MurmurQueue.
@MainActor
public final class MurmurCaptureService: ObservableObject {

    @Published public var isCapturing = false

    private let queue: MurmurQueue
    private let deviceID: String
    private let streamID: String

    private let engine = AVAudioEngine()
    private var converter: AVAudioConverter?
    private var seq = 0

    // 100ms chunk accumulator (in 16kHz mono float32)
    private var chunkBuffer: [Float] = []

    // 1s quality window accumulators
    private var windowBuffer: [Float] = []
    private var speechFrames = 0
    private var totalFrames = 0
    private var qualityTimer: Task<Void, Never>?

    /// Full-session PCM16LE accumulator for MFC-01 sealed voice object (durable seal on stop).
    private var sessionPCM = Data()
    private let sealedStore: SealedVoiceObjectStore

    /// Last sealed offline voice object from this service (nil until a session seals).
    @Published public private(set) var lastSealedVoiceObject: SealedVoiceObject?

    /// Real-time RMS level in dBFS, updated every audio buffer (~10x/sec). -96 = silence.
    @Published public private(set) var currentDbLevel: Float = -96.0

    public init(
        deviceID: String,
        streamID: String = "mic.main",
        queue: MurmurQueue,
        sealedStore: SealedVoiceObjectStore = .shared
    ) {
        self.deviceID = deviceID
        self.streamID = streamID
        self.queue = queue
        self.sealedStore = sealedStore
    }

    // MARK: - Control

    public func start() throws {
        guard !isCapturing else { return }

        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        #endif

        let inputNode = engine.inputNode
        let nativeFormat = inputNode.outputFormat(forBus: 0)
        let targetFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: Double(MurmurConstants.sampleRateHz),
            channels: 1,
            interleaved: false
        )!

        guard let conv = AVAudioConverter(from: nativeFormat, to: targetFormat) else {
            throw CaptureError.converterUnavailable
        }
        converter = conv

        inputNode.installTap(onBus: 0, bufferSize: 4_096, format: nativeFormat) { [weak self] buffer, _ in
            // Copy buffer for off-main processing — AVAudioEngine tap runs on a real-time thread.
            guard let self else { return }
            let copied = buffer.copy() as! AVAudioPCMBuffer
            Task.detached(priority: .userInitiated) { [weak self] in
                await self?.onBuffer(copied, converter: conv, targetFormat: targetFormat)
            }
        }

        engine.prepare()
        try engine.start()
        sessionPCM = Data()
        isCapturing = true
        startQualityTimer()
    }

    public func stop() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        qualityTimer?.cancel()
        qualityTimer = nil
        converter = nil

        // Flush remainder into session seal (short captures < 100ms chunk).
        if !chunkBuffer.isEmpty {
            sessionPCM.append(toPCM16(chunkBuffer))
            chunkBuffer = []
        }
        windowBuffer = []
        speechFrames = 0
        totalFrames = 0
        isCapturing = false

        // MFC-01: seal original session bytes to durable local storage + hash (no AKRON claim).
        if !sessionPCM.isEmpty {
            if let sealed = try? sealedStore.seal(pcm16le: sessionPCM, deviceSessionID: deviceID) {
                lastSealedVoiceObject = sealed
            }
        }
        sessionPCM = Data()

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    /// Test / offline path: seal arbitrary PCM without the mic (same store as live capture).
    public func sealOfflinePCMForTest(_ pcm16le: Data) throws -> SealedVoiceObject {
        let sealed = try sealedStore.seal(pcm16le: pcm16le, deviceSessionID: deviceID)
        lastSealedVoiceObject = sealed
        return sealed
    }

    // MARK: - Buffer processing

    private func onBuffer(_ buffer: AVAudioPCMBuffer, converter: AVAudioConverter, targetFormat: AVAudioFormat) async {
        guard let converted = convert(buffer, using: converter, to: targetFormat),
              let data = converted.floatChannelData?[0] else { return }

        let count = Int(converted.frameLength)
        guard count > 0 else { return }
        let samples = Array(UnsafeBufferPointer(start: data, count: count))

        // Compute RMS dB for the monitor.
        var rms: Float = 0
        vDSP_rmsqv(data, 1, &rms, vDSP_Length(count))
        let db = rms > 1e-9 ? 20 * log10f(rms) : -96.0
        let isSpeech = rms > 0.015  // ~-36 dBFS speech threshold

        currentDbLevel = db
        windowBuffer.append(contentsOf: samples)
        totalFrames += 1
        if isSpeech { speechFrames += 1 }
        chunkBuffer.append(contentsOf: samples)

        shipPendingChunks()
    }

    @MainActor
    private func shipPendingChunks() {
        while chunkBuffer.count >= MurmurConstants.chunkSampleCount {
            let chunk = Array(chunkBuffer.prefix(MurmurConstants.chunkSampleCount))
            chunkBuffer.removeFirst(MurmurConstants.chunkSampleCount)
            shipChunk(chunk)
        }
    }

    private func convert(
        _ buffer: AVAudioPCMBuffer,
        using converter: AVAudioConverter,
        to format: AVAudioFormat
    ) -> AVAudioPCMBuffer? {
        let ratio = format.sampleRate / buffer.format.sampleRate
        let outFrames = AVAudioFrameCount(Double(buffer.frameLength) * ratio)
        guard outFrames > 0,
              let out = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: outFrames) else { return nil }

        var error: NSError?
        var inputConsumed = false
        converter.convert(to: out, error: &error) { _, status in
            if inputConsumed {
                status.pointee = .noDataNow
                return nil
            }
            inputConsumed = true
            status.pointee = .haveData
            return buffer
        }
        return error == nil ? out : nil
    }

    private func shipChunk(_ samples: [Float]) {
        let speechRatio = totalFrames > 0 ? Float(speechFrames) / Float(totalFrames) : 0
        let pcmData = toPCM16(samples)
        // Accumulate full-session original bytes for MFC-01 seal (evidence spine).
        sessionPCM.append(pcmData)
        let payload = AudioChunkPayload(
            pcmData: pcmData,
            speech: speechRatio > 0.1,
            vadProb: speechRatio
        )
        let packet = MurmurPacket(
            deviceID: deviceID,
            sourceID: deviceID,
            streamID: streamID,
            seq: nextSeq(),
            kind: "audio_chunk",
            payload: payload
        )
        Task { await queue.enqueue(.audioChunk(packet)) }
    }

    // MARK: - Quality frame (1s timer)

    private func startQualityTimer() {
        qualityTimer = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await self?.emitQualityFrame()
            }
        }
    }

    public func emitQualityFrame() async {
        let samples = windowBuffer
        let sf = speechFrames
        let tf = totalFrames
        windowBuffer = []
        speechFrames = 0
        totalFrames = 0

        guard !samples.isEmpty else { return }

        var rms: Float = 0
        vDSP_rmsqv(samples, 1, &rms, vDSP_Length(samples.count))
        let rmsDb = rms > 1e-9 ? 20 * log10f(rms) : -96.0
        let noiseFloorDb = rmsDb - 20.0  // simplified estimate; upgrade in v1
        let snrEst = max(0, rmsDb - noiseFloorDb)
        let clipCount = samples.lazy.filter { abs($0) > 0.99 }.count
        let clipRate = Float(clipCount) / Float(max(1, samples.count))
        let speechRatio = tf > 0 ? Float(sf) / Float(tf) : 0

        let payload = QualityFramePayload(
            audioPresent: isCapturing,
            vadSpeechRatio: speechRatio,
            snrEst: snrEst,
            noiseFloorDb: noiseFloorDb,
            rmsDb: rmsDb,
            clipRate: clipRate
        )
        let packet = MurmurPacket(
            deviceID: deviceID,
            sourceID: deviceID,
            streamID: streamID,
            seq: nextSeq(),
            kind: "quality_frame",
            payload: payload
        )
        await queue.enqueue(.qualityFrame(packet))
    }

    // MARK: - Helpers

    private func nextSeq() -> Int {
        seq += 1
        return seq
    }

    private func toPCM16(_ samples: [Float]) -> Data {
        var data = Data(capacity: samples.count * 2)
        for s in samples {
            let clamped = max(-1.0, min(1.0, s))
            let v = Int16(clamped * Float(Int16.max))
            withUnsafeBytes(of: v.littleEndian) { data.append(contentsOf: $0) }
        }
        return data
    }

    public enum CaptureError: Error {
        case converterUnavailable
    }
}

#endif  // !os(watchOS)
