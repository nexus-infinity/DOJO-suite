import Foundation
import AppKit
import DOJOShared

/// Local Application Support persistence + export for M1 generated objects.

enum GeneratedObjectStore {
    static let folderName = "org.field.dojo"
    static let fileName = "generated_objects.json"
    static let localReceiptFileName = "local_capture_receipts.jsonl"
    static let exportFolderName = "DOJO-Exports"

    private static var appSupportDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let dir = base.appendingPathComponent(folderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static var storeURL: URL {
        appSupportDirectory.appendingPathComponent(fileName)
    }

    static var localReceiptURL: URL {
        appSupportDirectory.appendingPathComponent(localReceiptFileName)
    }

    static var exportDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? appSupportDirectory
        let dir = docs.appendingPathComponent(exportFolderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func loadAll() -> [GeneratedObjectShell] {
        let url = storeURL
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode([GeneratedObjectShell].self, from: data)
            return decoded.sorted { $0.createdAt > $1.createdAt }
        } catch {
            return []
        }
    }

    /// Upserts object and marks isSavedLocally.
    @discardableResult
    static func save(_ object: GeneratedObjectShell) throws -> GeneratedObjectShell {
        var all = loadAll()
        var saved = object
        saved.isSavedLocally = true
        if let idx = all.firstIndex(where: { $0.id == saved.id }) {
            all[idx] = saved
        } else {
            all.insert(saved, at: 0)
        }
        try write(all)
        return saved
    }

    static func saveAll(_ objects: [GeneratedObjectShell]) throws {
        try write(objects.map {
            var o = $0
            o.isSavedLocally = true
            return o
        })
    }

    /// Completes one Mac Today composer loop: persist the object, issue a
    /// content-addressed local receipt, then attach that receipt for proof.
    /// This is surface evidence only. It does not promote FIELD authority.
    @discardableResult
    static func complete(
        _ object: GeneratedObjectShell,
        operation: String,
        result: String
    ) throws -> (object: GeneratedObjectShell, receipt: LocalCaptureReceipt) {
        var completed = object
        completed.isSavedLocally = true
        completed.localReceipt = nil

        var all = loadAll()
        upsert(completed, into: &all)
        try write(all)

        let receipt = LocalCaptureReceiptJournal.make(
            objectID: completed.id.uuidString,
            kind: completed.kind.rawValue,
            home: completed.home.rawValue,
            title: completed.title,
            body: completed.body,
            subtitle: completed.subtitle,
            createdAt: completed.createdAt,
            sourcePrompt: completed.sourcePrompt,
            operation: operation,
            result: result,
            objectPath: storeURL.path,
            receiptPath: localReceiptURL.path
        )

        try LocalCaptureReceiptJournal.append(receipt, to: localReceiptURL)

        completed.localReceipt = receipt
        upsert(completed, into: &all)
        try write(all)
        return (completed, receipt)
    }

    /// Capture remains the offline closed loop. Same store, named operation.
    @discardableResult
    static func capture(_ object: GeneratedObjectShell) throws -> (object: GeneratedObjectShell, receipt: LocalCaptureReceipt) {
        try complete(
            object,
            operation: LocalCaptureReceipt.Operation.capture,
            result: LocalCaptureReceipt.Outcome.captured
        )
    }

    /// Same object shape as Today composer Keep (text, no attachments).
    @discardableResult
    static func keepTextCapture(_ note: String) throws -> (object: GeneratedObjectShell, receipt: LocalCaptureReceipt) {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let object = GeneratedObjectShell(
            kind: .document,
            home: .captures,
            title: "Capture · \(trimmed.prefix(48))",
            body: trimmed,
            subtitle: "Local capture",
            sourcePrompt: trimmed,
            lastStablePoint: "capture_kept",
            nextAvailableAction: "Review · Save · Export · Continue",
            changedWhileAway: "none"
        )
        return try capture(object)
    }

    private static func upsert(_ object: GeneratedObjectShell, into objects: inout [GeneratedObjectShell]) {
        if let index = objects.firstIndex(where: { $0.id == object.id }) {
            objects[index] = object
        } else {
            objects.insert(object, at: 0)
        }
    }

    private static func write(_ objects: [GeneratedObjectShell]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(objects)
        try data.write(to: storeURL, options: .atomic)
    }

    enum ExportMode {
        case clipboard
        case markdownFile
    }

    @discardableResult
    static func export(_ object: GeneratedObjectShell, mode: ExportMode) throws -> String {
        let md = object.asMarkdown()
        switch mode {
        case .clipboard:
            let pb = NSPasteboard.general
            pb.clearContents()
            pb.setString(md, forType: .string)
            return "clipboard"
        case .markdownFile:
            let safe = object.title
                .replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: ":", with: "-")
            let name = "\(safe.prefix(40))-\(object.id.uuidString.prefix(8)).md"
            let url = exportDirectory.appendingPathComponent(String(name))
            try md.write(to: url, atomically: true, encoding: .utf8)
            return url.path
        }
    }
}

/// UserDefaults for M1 default provider/model (not secrets).
enum M1Preferences {
    private static let providerKey = "m1.defaultProvider"
    private static let modelKey = "m1.defaultModel"

    static var defaultProvider: HostedProviderID {
        get {
            if let raw = UserDefaults.standard.string(forKey: providerKey),
               let p = HostedProviderID(rawValue: raw),
               p.isHostedLive {
                return p
            }
            return .openai
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: providerKey)
        }
    }

    static var defaultModelID: String {
        get {
            let p = defaultProvider
            let stored = UserDefaults.standard.string(forKey: modelKey)
            return HostedProviderCatalog.resolvedModelID(provider: p, preferred: stored)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: modelKey)
        }
    }

    static func setDefault(provider: HostedProviderID, modelID: String) {
        defaultProvider = provider
        defaultModelID = HostedProviderCatalog.resolvedModelID(provider: provider, preferred: modelID)
    }
}
