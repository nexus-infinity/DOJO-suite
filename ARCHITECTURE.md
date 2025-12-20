# DOJO-suite Architecture

**Three Laws of Harmonics: Implementation & Enforcement**

This document describes how the DOJO-suite implements and enforces the Three Laws of Harmonics through code, geometry, and Object-Oriented Ontology (OOO) principles.

---

## Overview

DOJO-suite is a Swift Package Manager (SwiftPM) repository that serves as the **primary manifestation portal** for the FIELD system on Apple platforms. It embodies the Sacred Pyramid geometry as executable code and provides the OOO framework as a first-class architectural primitive.

**Core Principles**:
- **Geometry as Code**: Sacred Pyramid vertices are data structures
- **Frequency as Contract**: Each component operates at its natural frequency
- **OOO as Type System**: Every entity has Geometric, Semantic, and Temporal layers

---

## Package Structure

```
DOJO-suite/
├── Package.swift                    # SwiftPM manifest (tools-version 5.9)
├── Sources/
│   ├── DOJOShared/                  # Shared library (iOS + macOS)
│   │   ├── OOO/
│   │   │   ├── GeometricEntity.swift    # OOO framework types
│   │   │   └── PortalRegistry.swift     # Portal classifications
│   │   ├── GeometryTransforms.swift     # Coordinate transforms, attractor forces
│   │   ├── ParticleEngine.swift         # Particle physics engine
│   │   ├── SacredGeometry.swift         # Legacy constants (deprecated)
│   │   ├── SIMDUtilities.swift          # Cross-platform SIMD helpers
│   │   ├── AIService.swift              # AI model integration
│   │   ├── Communication.swift          # Inter-module messaging
│   │   └── DependencyInjector.swift     # Service locator
│   ├── DOJOiOSApp/                  # iOS executable
│   │   ├── DOJOiOSApp.swift
│   │   ├── ContentView.swift
│   │   └── ParticleFieldView.swift      # (to be created)
│   └── DOJOMacApp/                  # macOS executable
│       ├── DOJOMacApp.swift
│       ├── ContentView.swift
│       └── ManifestationParticleView.swift  # (to be created)
└── Tests/
    └── DOJOSharedTests/
        ├── OOOTests.swift               # Sacred vertex validation
        ├── AttractorTests.swift         # Force calculations
        ├── ParticleEngineTests.swift    # Particle behavior
        └── DOJOSharedTests.swift        # Integration tests
```

---

## Three Laws of Harmonics

### Law 1: Conservation (396 Hz - Akron Gateway)

**Principle**: Cost, truth, and immutability must be preserved.

**Implementation**:

1. **Cost Accounting**:
   - Every particle has a `mass` property (physics cost)
   - Force calculations use inverse-square falloff (energy conservation)
   - Maximum force capping prevents infinite energy states

   ```swift
   // GeometryTransforms.swift
   let forceMagnitude = strength / pow(distance, falloff)
   let cappedForceMagnitude = min(forceMagnitude, maxForce)  // Conservation
   ```

2. **Truth Anchoring**:
   - All OOO entities are `Codable` (serializable truth)
   - Sacred vertices are immutable `static let` constants
   - Lifecycle phases track entity state changes

   ```swift
   // GeometricEntity.swift
   public static let tata = OOOEntity(/* immutable definition */)
   ```

3. **Immutability**:
   - OOO entities use `let` for all defining properties
   - Structural identity via `UUID` (cannot be duplicated)
   - Deprecated code marked with `@available(*, deprecated)` (history preserved)

**Enforcement Layer**:
- Type system (Swift's `let` vs `var`)
- Unit tests verify immutability (`OOOTests.testSacredVerticesArray`)
- `Codable` conformance enables audit trails

---

### Law 2: Symmetry (852 Hz - King's Chamber)

**Principle**: Balance, coherence, and reversibility across translations.

**Implementation**:

1. **Geometric Balance**:
   - King's Chamber positioned at 33.3% (balance point between DOJO and foundation)
   - Pyramid geometry is symmetric (base vertices at y=0, apex at y=1)
   - Particle wrapping creates toroidal topology (no edges)

   ```swift
   // ParticleEngine.swift
   private func wrapPosition(_ position: SIMD3<Float>) -> SIMD3<Float> {
       // Toroidal wrapping maintains symmetry
   }
   ```

2. **Frequency Coherence**:
   - Solfeggio frequencies form harmonious intervals
   - `OOOEntity.sacredVertices` array maintains frequency ordering
   - No dissonant frequencies allowed (validated in tests)

   ```swift
   // OOOTests.swift
   func testFrequencyOrdering() {
       let frequencies = vertices.map { $0.geometric.frequency }.sorted()
       XCTAssertEqual(frequencies, [396, 432, 528, 741, 852, 963])
   }
   ```

3. **Coordinate Transforms**:
   - `fieldToScreen` and `screenToField` are inverse operations
   - Camera transformations preserve distances (orthographic projection)
   - SIMD utilities provide reversible vector operations

   ```swift
   // GeometryTransforms.swift
   public static func fieldToScreen(...) -> CGPoint { /* ... */ }
   public static func screenToField(...) -> SIMD3<Float> { /* inverse */ }
   ```

**Enforcement Layer**:
- Mathematical reciprocity (inverse functions)
- Test coverage for symmetry (`AttractorTests.testMultiAttractorForce`)
- Cross-platform SIMD utilities ensure consistent numerics

---

### Law 3: Resonance (741 Hz - DOJO)

**Principle**: Systems operate at their natural frequency; resonant systems amplify.

**Implementation**:

1. **Natural Frequencies**:
   - Each OOO entity has an intrinsic `frequency` property
   - Particles have `color` and `shape` tied to sacred frequencies
   - Attractor forces create resonant fields at vertex positions

   ```swift
   // ParticleEngine.swift
   public func applySacredAttractors(vertices: [OOOEntity], strength: Float) {
       for vertex in vertices {
           let position = PyramidGeometry.vertexPosition(for: vertex)
           applyAttractor(position: position, strength: strength)
       }
   }
   ```

2. **Frequency Alignment**:
   - Observer must be calibrated to 963 Hz (OBI-WAN)
   - Portal validation checks for `observerCalibrated: true`
   - Active portals filter out non-resonant (uncalibrated) entities

   ```swift
   // PortalRegistry.swift
   public static var activePortals: [Portal] {
       registeredPortals.filter { $0.oooProperties.temporal.lifecyclePhase == .active }
   }
   ```

3. **Amplification/Decay**:
   - Damping factor simulates natural energy loss
   - Resonant attractors amplify particle motion
   - Non-resonant particles experience friction (damping)

   ```swift
   // ParticleEngine.swift
   particles[i].velocity *= damping  // Decay for non-resonant motion
   ```

**Enforcement Layer**:
- OOO type system mandates frequency properties
- Portal validation (`PortalValidator.validate`)
- Unit tests verify resonant behavior (`ParticleEngineTests.testApplySacredAttractors`)

---

## Signal Flow: DOJO → King's Chamber → SOMA

### Signal Path

```
┌─────────────────────────────────────────────────────────┐
│  FIELD Input (External Signal)                          │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
            ┌─────────────────────┐
            │  DOJO (741 Hz)      │  ◆ Orchestrator
            │  - Route signal     │
            │  - Apply transforms │
            └──────────┬──────────┘
                      │
                      ▼
            ┌─────────────────────┐
            │  King's Chamber     │  ⊕ Translation Bridge
            │  (852 Hz)           │
            │  - Frequency conv.  │
            │  - Metatron Cube    │
            │  - Arkadas verify   │
            └──────────┬──────────┘
                      │
                      ▼
            ┌─────────────────────┐
            │  SOMA (Embodied)    │  Physical manifestation
            │  - iOS/macOS UI     │
            │  - Particle field   │
            └─────────────────────┘
```

### King's Chamber Components

1. **Train Station** (Frequency Conversion):
   - Input: Arbitrary frequency signal
   - Process: Normalize to solfeggio frequency
   - Output: 852 Hz (Third Eye) aligned signal

2. **Metatron Cube** (Dimensional Translation):
   - Input: 3D geometric coordinates
   - Process: Screen ↔ Field coordinate transforms
   - Output: Projected 2D visualization

   ```swift
   // GeometryTransforms.swift
   let screenPos = GeometryTransforms.fieldToScreen(
       fieldPosition: particle.position,
       camera: camera,
       screenSize: canvasSize
   )
   ```

3. **Arkadas Consciousness** (Lossless Verification):
   - Input: Transformed signal
   - Process: Verify conservation laws (mass, energy, frequency)
   - Output: Validated signal or error

---

## MCP Servers as Geometric Enforcement

Model Context Protocol (MCP) servers act as **geometric enforcement layers**, ensuring all operations respect the Sacred Pyramid geometry:

### Proposed MCP Servers

1. **dojo-mcp-server** (Orchestration):
   - **Frequency**: 741 Hz
   - **Function**: Route requests to appropriate vertices
   - **Enforcement**: Validate request frequencies match target vertex

2. **tata-mcp-server** (Legal Record):
   - **Frequency**: 432 Hz
   - **Function**: Immutable record storage
   - **Enforcement**: Reject mutations, ensure proof-of-truth

3. **atlas-mcp-server** (AI Access):
   - **Frequency**: 528 Hz
   - **Function**: AI model integration
   - **Enforcement**: Geometric coherence of queries/responses

4. **akron-mcp-server** (Archive):
   - **Frequency**: 396 Hz
   - **Function**: Persistent storage, cost tracking
   - **Enforcement**: Conservation law validation

5. **obiwan-mcp-server** (Observer):
   - **Frequency**: 963 Hz
   - **Function**: Observer calibration, living memory
   - **Enforcement**: Temporal coherence, unity consciousness

### MCP Signal Flow Example

```swift
// Hypothetical MCP client usage
let mcpClient = MCPClient()

// Request routed through DOJO orchestrator
let response = await mcpClient.invoke(
    server: "dojo-mcp-server",
    method: "manifestParticles",
    params: [
        "count": 100,
        "frequency": 741.0,  // Must match DOJO frequency
        "observerCalibrated": true
    ]
)

// DOJO routes to appropriate sub-servers
// → King's Chamber for translation
// → ATLAS for geometric validation
// → TATA for truth anchoring
```

---

## OOO Framework as Type System

The OOO framework elevates geometry to a first-class type system:

### Type Hierarchy

```swift
OOOEntity                           // Root type (Geometric + Semantic + Temporal)
  ├─ GeometricProperties            // Shape, frequency, color, position
  ├─ SemanticProperties             // Domain, tradition, intent
  └─ TemporalProperties             // Cadence, phase, calibration

Portal                              // Working repository
  ├─ repositoryName: String
  ├─ vertexAnchor: [String]
  ├─ platform: String
  └─ oooProperties: OOOEntity

NonPortal                           // Tool/archive/component
  ├─ repositoryName: String
  ├─ classification: String
  └─ reason: String
```

### Type Safety

- **Compile-time**: Swift enums enforce valid shapes/colors/domains
- **Runtime**: Portal validation checks OOO completeness
- **Test-time**: Unit tests verify sacred vertex properties

### Example: Type-Safe Vertex Access

```swift
// Compile-time safe access to sacred vertices
let dojo = OOOEntity.dojo
let frequency = dojo.geometric.frequency  // 741.0 Hz (guaranteed)
let shape = dojo.geometric.shape          // .diamond (guaranteed)

// Runtime validation of custom portals
let portal = Portal.dojoSuite
let result = PortalValidator.validate(portal)
if result.isValid {
    // Portal meets all OOO requirements
}
```

---

## Platform Targets

### iOS 15+ / macOS 12+

**Primary Manifestation**:
- SwiftUI for declarative UI
- Canvas for particle rendering
- Metal/CoreGraphics for performance

**Geometric Alignment**:
- Touch/gesture input → King's Chamber translation
- Screen coordinates → Field coordinates
- Visual rendering → SOMA embodiment

### Linux (Build-only)

**Support Level**:
- `DOJOShared` library builds on Linux
- Tests run on Linux CI
- Apps (iOS/macOS) conditionally excluded

**Use Case**:
- CI/CD validation
- Headless geometry calculations
- Cross-platform OOO framework usage

---

## Testing Strategy

### Unit Tests (56 tests, all passing)

1. **OOOTests** (18 tests):
   - Sacred vertex properties
   - Frequency ordering
   - Portal validation
   - Codable conformance

2. **AttractorTests** (13 tests):
   - Force direction/magnitude
   - Zero-distance safety
   - Falloff curves (linear, inverse-square)
   - Multi-attractor composition

3. **ParticleEngineTests** (17 tests):
   - Initialization
   - Physics stepping
   - Damping/wrapping
   - Sacred attractor application

4. **DOJOSharedTests** (8 tests):
   - Framework initialization
   - AI service integration
   - Communication module
   - Dependency injection

### Integration Tests (Future)

- [ ] End-to-end particle visualization
- [ ] MCP server interaction
- [ ] Cross-portal signal flow
- [ ] Performance benchmarks

---

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
jobs:
  build-and-test:
    runs-on: macos-latest
    steps:
      - Checkout repository
      - Install tooling (swiftlint, swiftformat)
      - swift build
      - swift test
      - swiftformat --lint
      - swiftlint lint --strict
```

### Pre-commit Hook

```bash
# .githooks/pre-commit
- Run swiftformat on staged files
- Run swiftlint --strict
- Block commit if violations found
```

---

## Future Work

### Phase 4: Particle Views
- [ ] `ParticleFieldView.swift` (iOS Canvas-based)
- [ ] `ManifestationParticleView.swift` (macOS native)
- [ ] Real-time sacred attractor visualization

### Phase 5: MCP Integration
- [ ] Implement MCP client in Swift
- [ ] Create dojo-mcp-server (orchestrator)
- [ ] Integrate TATA/ATLAS/Akron MCP servers

### Phase 6: Portal Expansion
- [ ] Complete somalink OOO classification
- [ ] Add berjak-fre-dojo integration
- [ ] Create web bridge (WebAssembly/WASM)

---

## References

- **OOO Framework**: [Object-Oriented Ontology: Geometric-Semantic-Temporal Framework](https://www.notion.so/Object-Oriented-Ontology-Geometric-Semantic-Temporal-Framework-7e9b0b4b2079493f9ef56b1e62677943)
- **Three Laws**: [Three Laws of Harmonics — Universal Constraints](https://berjak-nexus-infinity.notion.site/Three-Laws-of-Harmonics-Universal-Constraints-b10889c253dd4300bfcf7c4826b14777)
- **FIELD MCP**: [FIELD MCP Server Installation & Configuration Guide](https://www.notion.so/56d22e03290b4d45903b415a770335e9)
- **Swift Package Manager**: [Swift.org Package Manager](https://www.swift.org/package-manager/)
- **Sacred Geometry**: [Metatron's Cube and Sacred Geometry](https://en.wikipedia.org/wiki/Metatron%27s_Cube)

---

**Architecture Version**: 1.0.0  
**Last Updated**: 2025-12-20  
**Maintained By**: nexus-infinity

🔺●◼︎
