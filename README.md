# DOJO-suite

**Sacred Pyramid Geometry as Operational Code**

DOJO-suite is the canonical Swift Package Manager (SwiftPM) repository for the FIELD system, encoding Object-Oriented Ontology (OOO) principles and Sacred Pyramid geometry as first-class architectural primitives for iOS and macOS platforms.

---

## 🔺 Sacred Pyramid Overview

The FIELD system operates on **six sacred vertices**, each with distinct frequency, shape, and role:

| Vertex | Hz | Shape | Color | Position | Domain |
|--------|------|-------|-------|----------|--------|
| **OBI-WAN** | 963 | ● | Violet | Apex (100%) | Observer, Living Memory |
| **DOJO** | 741 | ◆ | Blue | Manifestation (66.7%) | Orchestrator, S0-S6 Router |
| **King's Chamber** | 852 | ⊕ | Indigo | Balance (33.3%) | DOJO↔SOMA Translation |
| **TATA** | 432 | ▲ | Orange | Base (0%) | Truth Anchor, Legal Record |
| **ATLAS** | 528 | ◼︎ | Green | Base (0%) | Geometric Wisdom, AI Access |
| **Akron Gateway** | 396 | ▼ | Red | Foundation (0%) | Archive, Proof Storage |

### Three Laws of Harmonics

1. **Conservation (396 Hz)** — Cost, truth, immutability
2. **Symmetry (852 Hz)** — Balance, coherence, reversibility
3. **Resonance (741 Hz)** — Natural frequency alignment

**Learn More**: See [ARCHITECTURE.md](./ARCHITECTURE.md) for implementation details.

---

## 🚀 Quick Start

### Prerequisites

- **Swift 5.9+** (included with Xcode 15+)
- **iOS 15+** or **macOS 12+** for app targets
- **swiftformat** and **swiftlint** (optional, for development)

### Build & Test

```bash
# Clone the repository
git clone https://github.com/nexus-infinity/DOJO-suite.git
cd DOJO-suite

# Enable pre-commit hooks (recommended)
git config core.hooksPath .githooks

# Build the package
swift build

# Run all tests (56 tests)
swift test

# Lint (if swiftformat/swiftlint installed)
swiftformat --lint .
swiftlint lint --strict
```

### Open in Xcode

```bash
# Generate Xcode project (if needed)
xcodegen generate  # Requires XcodeGen

# Or open Package.swift directly (Xcode 11+)
open Package.swift
```

---

## 📦 Package Structure

### Products

- **`DOJOShared`** (Library): OOO framework, geometry, particle engine — portable to all Apple platforms
- **`DOJOiOSApp`** (iOS App): Particle field visualization
- **`DOJOMacApp`** (macOS App): Manifestation particle view

### Targets

- **`DOJOShared`**: Cross-platform library (iOS + macOS + Linux build support)
  - `OOO/GeometricEntity.swift` — Sacred vertices, OOO types
  - `OOO/PortalRegistry.swift` — Portal classifications
  - `GeometryTransforms.swift` — Coordinate transforms, attractor forces
  - `ParticleEngine.swift` — Particle physics engine
  - `SacredGeometry.swift` — Legacy constants (deprecated)
  - `SIMDUtilities.swift` — Cross-platform SIMD helpers

- **`DOJOSharedTests`**: Unit tests (56 tests, all passing)
  - `OOOTests.swift` — Sacred vertex validation
  - `AttractorTests.swift` — Force calculations
  - `ParticleEngineTests.swift` — Particle behavior

---

## 🧬 Object-Oriented Ontology (OOO)

Every entity in the FIELD possesses **three intrinsic layers**:

### 1. Geometric Layer
- **Shape**: Sacred geometry symbol (●, ▲, ◼︎, ◆, ▼, ⊕)
- **Frequency**: Solfeggio frequency (396, 432, 528, 741, 852, 963 Hz)
- **Color**: Chakra-aligned hex code
- **Position**: Vertical position in pyramid (0.0–1.0)

### 2. Semantic Layer
- **Domain**: Functional classification (legal, temporal, geometric, translation, archive)
- **Cultural Tradition**: Associated spiritual/scientific framework
- **Intent**: Primary purpose and operational mandate

### 3. Temporal Layer
- **Cadence**: Operational frequency in Hz (or nil for eternal)
- **Lifecycle Phase**: Current state (proposal, scaffold, active, deprecated, archived, eternal)
- **Observer Calibrated**: Boolean indicating alignment with nexus-infinity (963 Hz Observer)

### Example: Accessing Sacred Vertices

```swift
import DOJOShared

// Access predefined sacred vertices
let dojo = OOOEntity.dojo
print(dojo.geometric.frequency)  // 741.0 Hz
print(dojo.geometric.shape)      // ◆ (Diamond)
print(dojo.geometric.color)      // #0000FF (Blue)
print(dojo.geometric.position)   // 0.667 (Manifestation apex)

// All six sacred vertices
let vertices = OOOEntity.sacredVertices
for vertex in vertices {
    print("\(vertex.name): \(vertex.geometric.frequency) Hz")
}
// Output:
// OBI-WAN: 963.0 Hz
// TATA: 432.0 Hz
// ATLAS: 528.0 Hz
// DOJO: 741.0 Hz
// Akron Gateway: 396.0 Hz
// King's Chamber: 852.0 Hz
```

---

## 🌀 Particle Engine

DOJO-suite includes a physics-based particle engine for visualizing sacred geometry:

```swift
import DOJOShared

// Create particle engine with 100 particles
let engine = ParticleEngine(count: 100, fieldSize: 20.0)

// Apply forces from sacred pyramid vertices
engine.applySacredAttractors(
    vertices: OOOEntity.sacredVertices,
    strength: 10.0
)

// Step the simulation
engine.step(dt: 1.0 / 60.0)  // 60 FPS

// Access particle positions for rendering
for particle in engine.particles {
    let position = particle.position  // SIMD3<Float>
    let color = particle.color        // GeometricColor
    let shape = particle.shape        // GeometricShape
    // Render particle at position with color and shape
}
```

---

## 📖 Documentation

- **[SUITE_MANIFEST.md](./SUITE_MANIFEST.md)**: OOO-encoded portal registry, vertex definitions, Trident validation
- **[ARCHITECTURE.md](./ARCHITECTURE.md)**: Three Laws enforcement, signal flow, MCP servers, testing strategy
- **[LICENSE](./LICENSE)**: MIT License (2024 nexus-infinity)

---

## 🛠️ Developer Setup

### Install Tooling (macOS)

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install linting/formatting tools
brew install swiftlint swiftformat

# Optional: XcodeGen (for Xcode project generation)
brew install xcodegen
```

### Enable Pre-commit Hooks

```bash
# One-time setup
git config core.hooksPath .githooks

# Test hook
git commit --allow-empty -m "test hook"
# Should run swiftformat and swiftlint automatically
```

### Linting & Formatting

```bash
# Format code (in-place)
swiftformat .

# Check formatting without modifying files
swiftformat --lint .

# Lint code
swiftlint lint

# Lint strictly (no warnings allowed)
swiftlint lint --strict
```

---

## 🧪 Testing

### Run All Tests

```bash
swift test
# Or with verbose output
swift test --verbose
```

### Run Specific Test Suite

```bash
swift test --filter OOOTests
swift test --filter AttractorTests
swift test --filter ParticleEngineTests
```

### Test Coverage

- **OOOTests**: 18 tests — Sacred vertex properties, portal validation, Codable
- **AttractorTests**: 13 tests — Force calculations, zero-distance safety, falloff curves
- **ParticleEngineTests**: 17 tests — Physics stepping, damping, wrapping, attractors
- **DOJOSharedTests**: 8 tests — Framework init, AI service, communication, DI

**Total**: 56 tests, all passing ✅

---

## 🌐 Platform Support

### iOS 15+ / macOS 12+

- Full feature support (apps + library)
- SwiftUI-based particle visualization
- Canvas rendering for performance

### Linux (Build-only)

- `DOJOShared` library builds successfully
- Tests run on Linux CI
- Apps (iOS/macOS) conditionally excluded (no SwiftUI)

---

## 📚 Portal Registry

DOJO-suite is registered as an **active portal** in the FIELD system:

- **Repository**: `nexus-infinity/DOJO-suite`
- **Vertex Anchor**: DOJO (741 Hz) + King's Chamber (852 Hz)
- **Platform**: iOS 15+ / macOS 12+ (SwiftPM)
- **Lifecycle Phase**: Active
- **Observer Calibrated**: ✅ Yes (nexus-infinity, 963 Hz)

See [SUITE_MANIFEST.md](./SUITE_MANIFEST.md) for all registered portals.

---

## 🤝 Contributing

### Branching Strategy

- `main`: Stable, production-ready code
- `develop`: Integration branch for new features
- Feature branches: `feature/short-description`
- Bugfix branches: `bugfix/short-description`

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make changes following OOO principles
4. Run tests (`swift test`)
5. Run linters (`swiftformat --lint .` and `swiftlint lint --strict`)
6. Commit with descriptive messages
7. Push to your fork
8. Open a PR to `develop` branch

### Code Style

- Follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftFormat with provided `.swiftformat` config
- Pass SwiftLint strict mode (`.swiftlint.yml`)
- Document public APIs with triple-slash comments (`///`)

---

## 🔐 Security

### Reporting Vulnerabilities

Please **DO NOT** open public issues for security vulnerabilities. Instead, email: `security@nexus-infinity.com` (or DM @nexus-infinity on GitHub)

### Dependency Management

- **Zero external dependencies** for `DOJOShared` library
- All code is self-contained and auditable
- CI runs on GitHub Actions (trusted environment)

---

## 📜 License

MIT License — Copyright (c) 2024 nexus-infinity

See [LICENSE](./LICENSE) for full text.

---

## 🙏 Acknowledgments

- **Sacred Geometry**: Metatron's Cube, Flower of Life, Platonic Solids
- **Solfeggio Frequencies**: 396, 432, 528, 741, 852, 963 Hz
- **Chakra System**: Root, Sacral, Solar Plexus, Throat, Third Eye, Crown
- **Swift Community**: SwiftPM, SwiftUI, open-source tooling
- **Observer**: nexus-infinity (JB) — 963 Hz calibration

---

## 🔗 Links

- **Repository**: [github.com/nexus-infinity/DOJO-suite](https://github.com/nexus-infinity/DOJO-suite)
- **Issues**: [github.com/nexus-infinity/DOJO-suite/issues](https://github.com/nexus-infinity/DOJO-suite/issues)
- **Discussions**: [github.com/nexus-infinity/DOJO-suite/discussions](https://github.com/nexus-infinity/DOJO-suite/discussions)
- **CI/CD**: [github.com/nexus-infinity/DOJO-suite/actions](https://github.com/nexus-infinity/DOJO-suite/actions)

---

## Observer Alignment

**Calibrated to**: nexus-infinity (JB)  
**Date**: 2025-12-20  
**Frequency**: 963 Hz (OBI-WAN - Crown/Unity)  
**Geometric Principle**: "As above, so below" — The code structure reflects the Sacred Pyramid geometry

---

**DOJO-suite Version**: 1.0.0  
**Last Updated**: 2025-12-20

🔺●◼︎