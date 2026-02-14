# DOJO-suite Models Directory

## Structure
- `GGUF/` - llama.cpp quantized models (4-13GB each)
- `CoreML/` - Apple Neural Engine optimized models
- `manifests/` - JSON configs mapping apps to models

## Model Placement
1. Download GGUF models from HuggingFace
2. Place in `GGUF/` directory
3. Update manifest if needed
4. Test with: `swift test --filter ModelLoaderTests`

## Download Models
```bash
# Example: Download field-llama3-8b
huggingface-cli download misterJB/field-llama3-8b-GGUF \
  field-llama3-8b-Q4_K_M.gguf \
  --local-dir Models/GGUF/
```

## Supported Quantizations
- Q4_K_M: 4-bit (4.5GB, fastest)
- Q5_K_M: 5-bit (7GB, balanced)
- Q8_0: 8-bit (13GB, highest quality)
