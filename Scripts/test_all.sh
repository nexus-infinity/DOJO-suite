#!/bin/bash
set -e

echo "🧪 Running all DOJO-suite tests..."
cd "$(dirname "$0")/.."

swift test --parallel

python3 Scripts/validate_observer_aligned_assistance_ontology.py

if command -v npm >/dev/null 2>&1 && [ -d web/node_modules ]; then
    npm --prefix web run type-check
else
    echo "⚠ Web type-check HOLD: run npm install in web/ to provision local dependencies"
fi

echo "✅ All tests passed"
