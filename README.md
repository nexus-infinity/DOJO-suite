# DOJO-suite / Universal Framework

## Overview

DOJO-suite (Universal Framework) is a comprehensive, multi-platform project designed to support various deployment targets while maintaining a shared codebase. It includes modules for web, mobile (iOS), desktop (macOS), and other platforms, with a focus on modularity and extensive testing. The project is uniquely enhanced by an integrated AI management system that automates various aspects of development and maintenance.

### Platform Support

- **iOS & macOS**: Native Swift applications with XcodeGen project setup - see [README_XCODE.md](./README_XCODE.md)
- **Web**: React-based web applications
- **Cross-platform**: Shared components and services

## Project Structure

For a detailed overview of the project structure, please refer to the `project-structure.txt` file in the root directory. This file provides a comprehensive layout of all directories and key files in the project.

### iOS & macOS Development

The DOJO-suite includes native iOS and macOS applications built with Swift and SwiftUI:

- **Sources/DOJOShared**: Cross-platform framework (iOS + macOS) with AI services, communication, and dependency injection
- **Sources/DOJOiOSApp**: iOS application demonstrating framework integration  
- **Sources/DOJOMacApp**: macOS application demonstrating framework integration
- **Tests/DOJOSharedTests**: Unit tests for the shared framework

For complete iOS/macOS setup instructions, see [README_XCODE.md](./README_XCODE.md).

Quick start for iOS/macOS development:
```bash
# Install dependencies
brew install xcodegen swiftformat swiftlint

# Generate Xcode project
xcodegen generate

# Open in Xcode
open DOJO-suite.xcodeproj
```

## AI Management System

Our project leverages a sophisticated AI management system that enhances various aspects of the development lifecycle:

- Automated code review and optimization
- Intelligent test generation and execution
- Dynamic resource allocation and scaling
- Predictive maintenance and error detection
- Natural language processing for documentation and query handling

For detailed information on how to use and configure the AI system, please refer to the [AI_INTEGRATION.md](./AI_INTEGRATION.md) file.

## Getting Started with AI Integration

1. Initialize the AI system: `npm run ai-init`
2. Run AI-powered code review: `npm run ai-review`
3. Generate AI-enhanced tests: `npm run ai-test`
4. Create AI-generated documentation: `npm run ai-docs`
5. Perform AI-driven performance optimization: `npm run ai-optimize`
6. Conduct AI security analysis: `npm run ai-security`
7. Update the AI system: `npm run ai-update`

## Configuration

AI-specific configuration can be found in `config/ai-config.json`. Adjust these settings to fine-tune the AI system's behavior.

## Best Practices for AI Integration

- Regularly run AI-powered code reviews before submitting pull requests
- Utilize AI-generated tests to complement manual test writing
- Keep the AI configuration up-to-date as the project evolves
- Provide feedback on AI-generated content to improve system accuracy
- Integrate AI-powered documentation generation into your workflow