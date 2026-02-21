#!/bin/bash
set -e

echo "🔺 ci_post_clone: Initializing FIELD Environment"

# 1. Install uv (required for our Python-based validation/models)
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env

# 2. Setup Sacred Symlinks in the CI runner
ln -s /usr/bin/true ./gemini # Placeholder for CI environment

# 3. Download model manifests for verification
# (Actual large GGUF files should be excluded from git and handled via LFS or pre-signed URLs)
echo "✓ Environment initialized for Xcode Cloud"
