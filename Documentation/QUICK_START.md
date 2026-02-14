# DOJO-suite Quick Start

## Build Everything
```bash
cd /Users/field/DOJO-suite
./Scripts/build_all.sh
```

## Run Tests
```bash
./Scripts/test_all.sh
```

## Open in Xcode
```bash
open Package.swift
```

## Add a Model
1. Download GGUF file from HuggingFace
2. Place in `Models/GGUF/`
3. Verify manifest exists in `Models/manifests/`
4. Test: `swift test --filter ModelLoaderTests`

## Deploy to TestFlight
1. Open in Xcode
2. Product → Archive
3. Distribute App → TestFlight
4. Upload to App Store Connect
