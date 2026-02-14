#!/bin/bash
set -e

echo "🔨 Building all 4 DOJO-suite apps..."
cd "$(dirname "$0")/.."

echo "Building DOJOShared framework..."
swift build --target DOJOShared --configuration release

echo "Building DOJO.app..."
swift build --product DOJOApp --configuration release 2>/dev/null || echo "⚠ DOJOApp not ready yet"

echo "Building Arkadas.app..."
swift build --product ArkadašApp --configuration release 2>/dev/null || echo "⚠ ArkadašApp not ready yet"

echo "Building OB1Link.app..."
swift build --product OB1LinkApp --configuration release 2>/dev/null || echo "⚠ OB1LinkApp not ready yet"

echo "Building DojoLink.app..."
swift build --product DojoLinkApp --configuration release 2>/dev/null || echo "⚠ DojoLinkApp not ready yet"

echo "✅ Build complete"
