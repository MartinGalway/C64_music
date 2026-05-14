#!/usr/bin/env bash
# Assemble a source file with KickAssembler and optionally wrap the PRG into
# a .d64 disk image. Output lands in build/out/.
#
# Usage:
#   ./build/build.sh                        # builds src/harness/main.asm
#   ./build/build.sh src/harness/main.asm   # explicit target
#   ./build/build.sh src/harness/main.asm --d64   # also produce .d64
#
# Toolchain paths assume the layout recorded in the project README / memory.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Java: /usr/bin/java on macOS is a stub that errors without a full JRE.
# Prefer Homebrew OpenJDK; fall back to whatever /usr/libexec/java_home finds.
if [[ -x "/opt/homebrew/opt/openjdk/bin/java" ]]; then
  JAVA="/opt/homebrew/opt/openjdk/bin/java"
elif JAVA_HOME_PATH=$(/usr/libexec/java_home 2>/dev/null) && [[ -x "$JAVA_HOME_PATH/bin/java" ]]; then
  JAVA="$JAVA_HOME_PATH/bin/java"
else
  echo "error: no usable Java runtime found. Install via 'brew install openjdk'." >&2
  exit 1
fi

# KickAssembler: prefer the vendored jar in this repo (self-contained build);
# fall back to known local installs if vendor/ is absent.
if [[ -f "vendor/KickAss.jar" ]]; then
  KICKASS_JAR="vendor/KickAss.jar"
elif [[ -f "/Users/dwestbury/Documents/Source Code/C64 Assembly/KickAssembler/KickAss.jar" ]]; then
  KICKASS_JAR="/Users/dwestbury/Documents/Source Code/C64 Assembly/KickAssembler/KickAss.jar"
elif [[ -f "/Users/dwestbury/Documents/KickAssembler/KickAss.jar" ]]; then
  KICKASS_JAR="/Users/dwestbury/Documents/KickAssembler/KickAss.jar"
else
  echo "error: KickAss.jar not found. Run: curl -o vendor/KickAssembler.zip https://theweb.dk/KickAssembler/KickAssembler.zip && unzip vendor/KickAssembler.zip -d vendor/" >&2
  exit 1
fi

VICE_BIN="/Users/dwestbury/Documents/Tech_Stuff/Electronics/Commodore Projects/C64 Emulation/vice-arm64-sdl2-3.9/bin"
C1541="$VICE_BIN/c1541"

SRC="${1:-src/harness/main.asm}"
MAKE_D64="${2:-}"

if [[ ! -f "$SRC" ]]; then
  echo "error: source file not found: $SRC" >&2
  echo "hint: the harness entry point has not been written yet — see src/harness/" >&2
  exit 1
fi

OUT_DIR="$REPO_ROOT/build/out"
mkdir -p "$OUT_DIR"

BASE="$(basename "${SRC%.*}")"
PRG="$OUT_DIR/${BASE}.prg"

echo "==> Assembling $SRC"
echo "    java:    $JAVA"
echo "    kickass: $KICKASS_JAR"
# -odir must be absolute: KickAss resolves relative -odir against the source
# file's directory, not CWD.
"$JAVA" -jar "$KICKASS_JAR" "$SRC" -odir "$OUT_DIR" -debugdump

if [[ ! -f "$PRG" ]]; then
  echo "error: expected output $PRG was not produced" >&2
  exit 1
fi

echo "==> PRG:  $PRG"

if [[ "$MAKE_D64" == "--d64" ]]; then
  if [[ ! -x "$C1541" ]]; then
    echo "error: c1541 not found or not executable at $C1541" >&2
    exit 1
  fi
  D64="$OUT_DIR/${BASE}.d64"
  DISK_NAME="${BASE:0:16}"
  echo "==> Wrapping into $D64"
  "$C1541" -format "${DISK_NAME},01" d64 "$D64" \
           -write "$PRG" "${BASE}" >/dev/null
  echo "==> D64:  $D64"
fi

echo "done."
