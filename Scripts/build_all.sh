#!/bin/bash
set -e

echo "🔨 Building the complete DOJO Suite Swift package..."
cd "$(dirname "$0")/.."

swift build --configuration release

echo "✅ Build complete"
