#!/usr/bin/env bash
# Launch VICE x64sc with a PRG or D64 image produced by build.sh.
#
# Usage:
#   ./build/run.sh                          # runs build/out/main.prg
#   ./build/run.sh build/out/main.prg       # explicit path
#   ./build/run.sh build/out/wizball.d64    # disk image

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

VICE_BIN="/Users/dwestbury/Documents/Tech_Stuff/Electronics/Commodore Projects/C64 Emulation/vice-arm64-sdl2-3.9/bin"
X64SC="$VICE_BIN/x64sc"

TARGET="${1:-build/out/main.prg}"

if [[ ! -x "$X64SC" ]]; then
  echo "error: x64sc not found or not executable at $X64SC" >&2
  exit 1
fi

if [[ ! -f "$TARGET" ]]; then
  echo "error: target not found: $TARGET" >&2
  echo "hint: run ./build/build.sh first" >&2
  exit 1
fi

case "$TARGET" in
  *.prg)
    echo "==> Launching x64sc with PRG: $TARGET (autostart)"
    exec "$X64SC" -autostart "$TARGET"
    ;;
  *.d64)
    echo "==> Launching x64sc with D64: $TARGET (attach to drive 8, autostart)"
    exec "$X64SC" -autostart "$TARGET"
    ;;
  *)
    echo "error: unrecognised target type (expected .prg or .d64): $TARGET" >&2
    exit 1
    ;;
esac
