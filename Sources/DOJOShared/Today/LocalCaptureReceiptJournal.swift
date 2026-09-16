import Foundation

/// Append-only JSONL journal for Mac Today local composer receipts.
///
/// Same seam `GeneratedObjectStore` writes on Keep. Surface evidence only —
/// not Chronicle, not chamber authority.
public enum LocalCaptureReceiptJournal {
    public static func make(
        objectID: String,
        kind: String,
        home: String,
        title: String,
        body: String,
        subtitle: String,
        createdAt: Date,
        sourcePrompt: String?,
        operation: String,
        result: String,
        objectPath: String,
        receiptPath: String
    ) -> LocalCaptureReceipt {
        LocalCaptureReceipt(
            objectID: objectID,
            surface: "DOJO Today · macOS",
            operation: operation,
            result: result,
            contentSHA256: LocalCaptureReceipt.contentDigest(
                objectID: objectID,
                kind: kind,
                home: home,
                title: title,
                body: body,
                subtitle: subtitle,
                createdAt: createdAt,
                sourcePrompt: sourcePrompt
            ),
            objectPath: objectPath,
            receiptPath: receiptPath
        )
    }

    public static func append(_ receipt: LocalCaptureReceipt, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var line = String(data: try encoder.encode(receipt), encoding: .utf8) ?? ""
        line.append("\n")
        let data = Data(line.utf8)
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        if FileManager.default.fileExists(atPath: url.path) {
            let handle = try FileHandle(forWritingTo: url)
            defer { try? handle.close() }
            try handle.seekToEnd()
            try handle.write(contentsOf: data)
            try handle.synchronize()
        } else {
            try data.write(to: url, options: .atomic)
        }
    }

    public static func load(from url: URL) throws -> [LocalCaptureReceipt] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let text = try String(contentsOf: url, encoding: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var receipts: [LocalCaptureReceipt] = []
        for raw in text.split(whereSeparator: \.isNewline) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { continue }
            receipts.append(try decoder.decode(LocalCaptureReceipt.self, from: Data(line.utf8)))
        }
        return receipts
    }
}
