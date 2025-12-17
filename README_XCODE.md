# DOJO-suite

A multi-platform framework and application suite for iOS and macOS, featuring shared components and AI integration capabilities.

## Overview

DOJO-suite is a comprehensive project that includes:

- **DOJOShared**: A cross-platform framework (iOS + macOS) providing core functionality including AI services, communication, and dependency injection
- **DOJOiOSApp**: An iOS application that demonstrates DOJOShared framework integration
- **DOJOMacApp**: A macOS application that demonstrates DOJOShared framework integration
- **DOJOSharedTests**: Unit tests for the DOJOShared framework

## Requirements

- macOS 12.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Development Tools

- [XcodeGen](https://github.com/yonaskolb/XcodeGen) - For generating Xcode projects
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) - For code formatting
- [SwiftLint](https://github.com/realm/SwiftLint) - For code linting

## Installation

### Install Development Tools

```bash
brew install xcodegen swiftformat swiftlint
```

### Generate Xcode Project

The Xcode project is generated from `project.yml` using XcodeGen:

```bash
xcodegen generate
```

This will create `DOJO-suite.xcodeproj` which you can open in Xcode.

### Set Up Git Hooks

To enable automatic code formatting and linting on commit:

```bash
git config core.hooksPath .githooks
```

## Building

### Using Xcode

1. Generate the project: `xcodegen generate`
2. Open `DOJO-suite.xcodeproj` in Xcode
3. Select a scheme (DOJOiOSApp, DOJOMacApp, or DOJOShared)
4. Choose a destination (iOS Simulator or Mac)
5. Build (⌘+B)

### Using Command Line

**Build DOJOShared framework for iOS:**
```bash
xcodebuild build \
  -project DOJO-suite.xcodeproj \
  -scheme DOJOShared \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

**Build DOJOShared framework for macOS:**
```bash
xcodebuild build \
  -project DOJO-suite.xcodeproj \
  -scheme DOJOShared \
  -destination 'platform=macOS'
```

**Build DOJOiOSApp:**
```bash
xcodebuild build \
  -project DOJO-suite.xcodeproj \
  -scheme DOJOiOSApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

**Build DOJOMacApp:**
```bash
xcodebuild build \
  -project DOJO-suite.xcodeproj \
  -scheme DOJOMacApp \
  -destination 'platform=macOS'
```

## Testing

Run tests for DOJOShared framework:

```bash
xcodebuild test \
  -project DOJO-suite.xcodeproj \
  -scheme DOJOShared \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

Or run tests from Xcode using ⌘+U.

## Code Quality

### Formatting

Format all Swift files:
```bash
swiftformat Sources Tests
```

Check formatting without making changes:
```bash
swiftformat --lint Sources Tests
```

### Linting

Run SwiftLint:
```bash
swiftlint lint
```

Run SwiftLint with strict mode:
```bash
swiftlint lint --strict
```

## Project Structure

```
DOJO-suite/
├── project.yml                 # XcodeGen configuration
├── Sources/
│   ├── DOJOShared/            # Shared framework (iOS + macOS)
│   │   ├── DOJOShared.swift
│   │   ├── AIService.swift
│   │   ├── Communication.swift
│   │   └── DependencyInjector.swift
│   ├── DOJOiOSApp/            # iOS application
│   │   ├── DOJOiOSApp.swift
│   │   └── ContentView.swift
│   └── DOJOMacApp/            # macOS application
│       ├── DOJOMacApp.swift
│       └── ContentView.swift
├── Tests/
│   └── DOJOSharedTests/       # Framework tests
│       └── DOJOSharedTests.swift
├── .swiftlint.yml             # SwiftLint configuration
├── .swiftformat               # SwiftFormat configuration
├── .githooks/
│   └── pre-commit             # Git pre-commit hook
└── .github/
    └── workflows/
        └── ci.yml             # GitHub Actions CI workflow
```

## Continuous Integration

The project uses GitHub Actions for continuous integration. On every push and pull request, the CI workflow will:

1. Install dependencies (XcodeGen, SwiftFormat, SwiftLint)
2. Generate the Xcode project
3. Build all targets (DOJOShared for iOS and macOS, DOJOiOSApp, DOJOMacApp)
4. Run tests
5. Check code formatting with SwiftFormat
6. Lint code with SwiftLint

## Contributing

1. Make sure you have all development tools installed
2. Set up git hooks: `git config core.hooksPath .githooks`
3. Generate the project: `xcodegen generate`
4. Make your changes
5. Ensure tests pass: `xcodebuild test -scheme DOJOShared ...`
6. Ensure code is formatted: `swiftformat Sources Tests`
7. Ensure code passes linting: `swiftlint lint --strict`
8. Commit your changes (pre-commit hook will run automatically)

## License

MIT License - see [LICENSE](LICENSE) file for details.

Copyright (c) 2024 nexus-infinity

## Features

### DOJOShared Framework

The shared framework provides:

- **AIService**: AI model integration and processing
- **Communication**: Cross-module messaging system
- **DependencyInjector**: Service registration and dependency management

### iOS App

SwiftUI-based iOS application demonstrating:
- Framework integration
- AI service usage
- Communication service usage
- Modern iOS UI patterns

### macOS App

SwiftUI-based macOS application demonstrating:
- Framework integration  
- AI service usage
- Communication service usage
- Native macOS UI patterns

## Troubleshooting

### Xcode Project Not Found

Make sure to generate the project first:
```bash
xcodegen generate
```

### Build Errors

1. Clean build folder: Xcode → Product → Clean Build Folder (⇧⌘K)
2. Regenerate project: `xcodegen generate`
3. Restart Xcode

### SwiftLint/SwiftFormat Not Found

Install via Homebrew:
```bash
brew install swiftlint swiftformat
```
