import Foundation

/// A small, local deterministic operation contract.
///
/// This is the first vertical slice for the FIELD visual-projection proposal:
/// a proposed operation is checked against one canonical object, a receipt is
/// emitted, and the resulting object is rendered through
/// `DOJO.RenderProjection.V1`. It is deliberately not a live King’s Chamber
/// authority endpoint or a live MCP write path.
public enum FieldOperationKindV0: String, Codable, Sendable, Equatable {
    case setNext = "SET_NEXT"
}

public struct FieldObjectV0: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let geometry: String
    public let chamber: String
    public let role: String
    public let evidence: String
    public let authority: String
    public let primeState: String
    public let version: Int
    public let source: String
    public let provenance: String
    public let next: String

    public init(
        id: String,
        geometry: String,
        chamber: String,
        role: String,
        evidence: String,
        authority: String,
        primeState: String,
        version: Int = 0,
        source: String,
        provenance: String,
        next: String
    ) {
        self.id = id
        self.geometry = geometry
        self.chamber = chamber
        self.role = role
        self.evidence = evidence
        self.authority = authority
        self.primeState = primeState
        self.version = version
        self.source = source
        self.provenance = provenance
        self.next = next
    }

    public func renderRow() -> DojoRenderRawRow {
        DojoRenderRawRow(
            url: id,
            geometry: geometry,
            chamber: chamber,
            role: role,
            evidence: evidence,
            authority: authority,
            next: next,
            primeState: primeState
        )
    }

    fileprivate func replacingNext(_ value: String) -> FieldObjectV0 {
        FieldObjectV0(
            id: id,
            geometry: geometry,
            chamber: chamber,
            role: role,
            evidence: evidence,
            authority: authority,
            primeState: primeState,
            version: version + 1,
            source: source,
            provenance: provenance,
            next: value
        )
    }
}

public struct FieldOperationRequestV0: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let requestedBy: String
    public let sourceSurface: String
    public let targetObjectID: String
    public let operation: FieldOperationKindV0
    public let value: String
    public let expectedVersion: Int
    public let authority: String
    public let requestedAt: Date

    public init(
        id: String,
        requestedBy: String,
        sourceSurface: String,
        targetObjectID: String,
        operation: FieldOperationKindV0 = .setNext,
        value: String,
        expectedVersion: Int,
        authority: String = "compose",
        requestedAt: Date
    ) {
        self.id = id
        self.requestedBy = requestedBy
        self.sourceSurface = sourceSurface
        self.targetObjectID = targetObjectID
        self.operation = operation
        self.value = value
        self.expectedVersion = expectedVersion
        self.authority = authority
        self.requestedAt = requestedAt
    }
}

public enum FieldOperationDecisionV0: String, Codable, Sendable, Equatable {
    case accepted = "ACCEPTED_LOCAL"
    case hold = "HOLD"
}

public struct FieldOperationReceiptV0: Codable, Sendable, Equatable {
    public let receiptID: String
    public let operationID: String
    public let objectID: String
    public let decision: FieldOperationDecisionV0
    public let reason: String
    public let issuedAt: Date
    public let priorVersion: Int?
    public let resultingVersion: Int?
    public let mutationApplied: Bool
    public let authorityCeiling: String
    public let governanceStatus: String

    public init(
        receiptID: String,
        operationID: String,
        objectID: String,
        decision: FieldOperationDecisionV0,
        reason: String,
        issuedAt: Date,
        priorVersion: Int?,
        resultingVersion: Int?,
        mutationApplied: Bool,
        authorityCeiling: String,
        governanceStatus: String = "LOCAL_FIXTURE_ONLY"
    ) {
        self.receiptID = receiptID
        self.operationID = operationID
        self.objectID = objectID
        self.decision = decision
        self.reason = reason
        self.issuedAt = issuedAt
        self.priorVersion = priorVersion
        self.resultingVersion = resultingVersion
        self.mutationApplied = mutationApplied
        self.authorityCeiling = authorityCeiling
        self.governanceStatus = governanceStatus
    }
}

public struct FieldOperationResultV0: Sendable, Equatable {
    public let object: FieldObjectV0?
    public let receipt: FieldOperationReceiptV0
    public let projection: DojoRenderProjectionResult

    public init(
        object: FieldObjectV0?,
        receipt: FieldOperationReceiptV0,
        projection: DojoRenderProjectionResult
    ) {
        self.object = object
        self.receipt = receipt
        self.projection = projection
    }
}

/// Local deterministic admission and commit seam for one non-destructive verb.
///
/// The store represents canonical state only inside this testable specimen.
/// It does not imply that the process is connected to King’s Chamber, Arkadaş,
/// Notion, an MCP server, or a persistent database.
public struct DeterministicFieldStoreV0: Sendable, Equatable {
    public private(set) var objects: [String: FieldObjectV0]

    public init(objects: [FieldObjectV0] = []) {
        self.objects = Dictionary(uniqueKeysWithValues: objects.map { ($0.id, $0) })
    }

    public mutating func apply(
        _ request: FieldOperationRequestV0,
        issuedAt: Date
    ) -> FieldOperationResultV0 {
        let current = objects[request.targetObjectID]
        let holdReason = validate(request, current: current)

        if let holdReason {
            let receipt = FieldOperationReceiptV0(
                receiptID: receiptID(for: request),
                operationID: request.id,
                objectID: request.targetObjectID,
                decision: .hold,
                reason: holdReason,
                issuedAt: issuedAt,
                priorVersion: current?.version,
                resultingVersion: current?.version,
                mutationApplied: false,
                authorityCeiling: "none",
                governanceStatus: "LOCAL_FIXTURE_ONLY"
            )
            return result(receipt: receipt, current: current)
        }

        // Validation establishes that the object exists and the operation is
        // SET_NEXT, so these unwraps are safe within this bounded seam.
        let updated = current!.replacingNext(plainNext(request.value))
        objects[updated.id] = updated
        let receipt = FieldOperationReceiptV0(
            receiptID: receiptID(for: request),
            operationID: request.id,
            objectID: updated.id,
            decision: .accepted,
            reason: "SET_NEXT accepted for the expected object version.",
            issuedAt: issuedAt,
            priorVersion: current!.version,
            resultingVersion: updated.version,
            mutationApplied: true,
            authorityCeiling: "compose",
            governanceStatus: "LOCAL_FIXTURE_ONLY"
        )
        return result(receipt: receipt, current: updated)
    }

    private func validate(
        _ request: FieldOperationRequestV0,
        current: FieldObjectV0?
    ) -> String? {
        guard !request.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "HOLD.OperationIdentityMissing"
        }
        guard !request.requestedBy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "HOLD.RequesterMissing"
        }
        guard !request.sourceSurface.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "HOLD.SourceSurfaceMissing"
        }
        guard let current else {
            return "HOLD.TargetObjectMissing"
        }
        guard current.chamber == DojoRenderProjectionV1.chamberScope else {
            return "HOLD.ObjectOutsideDojoScope"
        }
        guard request.operation == .setNext else {
            return "HOLD.OperationUnsupported"
        }
        guard request.authority == "compose" else {
            return "HOLD.AuthorityCeilingInsufficient"
        }
        guard current.authority == "compose" || current.authority == "record" else {
            return "HOLD.ObjectAuthorityInsufficient"
        }
        guard request.expectedVersion == current.version else {
            return "HOLD.ExpectedVersionMismatch"
        }
        guard let next = DojoRenderProjectionV1.stripNext(request.value),
              next == request.value.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return "HOLD.NextMustBePlainSentence"
        }
        return nil
    }

    private func plainNext(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func receiptID(for request: FieldOperationRequestV0) -> String {
        "FIELD-OP-RECEIPT-V0-\(request.id)"
    }

    private func result(
        receipt: FieldOperationReceiptV0,
        current: FieldObjectV0?
    ) -> FieldOperationResultV0 {
        let rows = current.map { [$0.renderRow()] } ?? []
        return FieldOperationResultV0(
            object: current,
            receipt: receipt,
            projection: DojoRenderProjectionV1.project(rows: rows)
        )
    }
}
