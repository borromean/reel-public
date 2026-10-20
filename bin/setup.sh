#!/bin/sh
# Optional extras for Reel, run once after cloning it:
#   bin/setup.sh
# installs numpy (multi-mic recordings, cutting and splitting) and fetches
# DeepFilterNet into bin/ (denoised listening copies). Reel itself needs only
# Python 3: python3 transcribe.py
set -e
cd "$(dirname "$0")/.."
command -v python3 >/dev/null || { echo "python3 is missing — on a Mac, run: xcode-select --install" >&2; exit 1; }
python3 -c 'import sys; sys.exit(sys.version_info < (3, 9))' \
  || { echo "Reel needs Python 3.9 or newer; python3 is $(python3 --version 2>&1)" >&2; exit 1; }
echo "== numpy (multi-mic recordings, cutting and splitting)"
if python3 -c 'import numpy' 2>/dev/null; then
  echo "   already there"
else
  # Homebrew's Python refuses plain pip installs (PEP 668); try the polite ways first, then brew's own numpy.
  python3 -m pip install --user numpy 2>/dev/null || python3 -m pip install --user --break-system-packages numpy 2>/dev/null \
    || { command -v brew >/dev/null && brew install numpy; } \
    || echo "!! numpy could not be installed — Reel runs, but multi-mic support is off until it is"
fi
python3 -c 'import numpy' 2>/dev/null && echo "   numpy ok ($(python3 --version))" || echo "   numpy still missing for $(command -v python3)"
echo "== DeepFilterNet (denoised listening copies)"
if [ -x bin/deep-filter ]; then echo "   already there"
else sh bin/fetch-deepfilter.sh || echo "   (not fetched — the denoised copies are optional)"
fi
echo
echo "Done. Start Reel with:  python3 transcribe.py"
echo "Then paste your ElevenLabs API key into ⚙ SETTINGS on the page that opens."
