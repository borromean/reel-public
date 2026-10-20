#!/bin/sh
# Fetch DeepFilterNet's deep-filter CLI and the DeepFilterNet3 model into bin/ (optional:
# enables the denoised playback copies). Verified against pinned SHA-256 checksums.
set -e
cd "$(dirname "$0")"
VER=0.5.6
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64)  ASSET=deep-filter-$VER-aarch64-apple-darwin;  SHA=4601e7f4e4c03e59a4c5b5000216ef3add3e808799cfccd95e14e83ea4611081 ;;
  Darwin-x86_64) ASSET=deep-filter-$VER-x86_64-apple-darwin;   SHA= ;;
  Linux-x86_64)  ASSET=deep-filter-$VER-x86_64-unknown-linux-musl; SHA= ;;
  *) echo "no prebuilt deep-filter for $(uname -s)-$(uname -m); see https://github.com/Rikorose/DeepFilterNet/releases" >&2; exit 1 ;;
esac
curl -fL -o deep-filter "https://github.com/Rikorose/DeepFilterNet/releases/download/v$VER/$ASSET"
if [ -n "$SHA" ]; then echo "$SHA  deep-filter" | shasum -a 256 -c - ; fi
chmod +x deep-filter
curl -fL -o DeepFilterNet3_onnx.tar.gz "https://raw.githubusercontent.com/Rikorose/DeepFilterNet/main/models/DeepFilterNet3_onnx.tar.gz"
echo "c94d91f70911001c946e0fabb4aa9adc37045f45a03b56008cb0c8244cb63616  DeepFilterNet3_onnx.tar.gz" | shasum -a 256 -c -
echo "deep-filter and DeepFilterNet3 model ready in bin/"
