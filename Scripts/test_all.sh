#!/bin/bash
set -e

echo "🧪 Running all DOJO-suite tests..."
cd "$(dirname "$0")/.."

swift test --parallel

echo "✅ All tests passed"
