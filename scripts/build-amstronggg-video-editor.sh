#!/bin/bash
# Build AmstrongggVideoEditor (rebrand of Shotcut) on Windows via MSYS2.
#
# PHASE 2 ONLY. Assumes phase 1 (full dependency build) already ran once:
#   1. MSYS2 MINGW64 installed, packages installed, mlt-prebuilt extracted.
#   2. bash scripts/build-shotcut-msys2.sh  (full run, builds FFmpeg/MLT/etc.)
#      was completed at least once, so $HOME/build/src/shotcut exists and
#      all dependencies are installed in $HOME/build.
#
# This script then:
#   - copies THIS rebranded source over $HOME/build/src/shotcut
#     (WITHOUT touching git: the main script would `git reset --hard` and
#     wipe the rebrand if ACTION_GET were left on, so we force ACTION_GET=0)
#   - rebuilds ONLY Shotcut (SUBDIRS="shotcut") and re-deploys
#   - copies the installer wizard image next to the .iss file
#
# Usage (in an MSYS2 MINGW64 shell, from this repo root):
#   bash scripts/build-amstronggg-video-editor.sh
#
# Result: portable folder  $HOME/build/AmstrongggVideoEditor
#         installer script $HOME/build/amstronggg-video-editor.iss
#         (compile it with Inno Setup 6 to get the .exe installer)

set -e
REBRAND_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$HOME/build}"
SOURCE_DIR="$INSTALL_DIR/src"
CONF="$HOME/build-shotcut-amstronggg.conf"

if [ ! -d "$SOURCE_DIR/shotcut" ]; then
    echo "ERROR: $SOURCE_DIR/shotcut not found."
    echo "Run phase 1 first (see README-AMSTRONGGG.md): the full"
    echo "  bash scripts/build-shotcut-msys2.sh"
    echo "must complete at least once so all dependencies exist."
    exit 1
fi

echo "Copying rebranded source over $SOURCE_DIR/shotcut ..."
tar --exclude=.git -cf - . | (cd "$SOURCE_DIR/shotcut" && tar -xf -)

cat > "$CONF" <<EOF
INSTALL_DIR="$INSTALL_DIR"
SHOTCUT_VERSION="1.0.0"
ACTION_GET=0
ACTION_CLEAN_SOURCE=0
SUBDIRS="shotcut"
DEPLOY=1
EOF
echo "Wrote $CONF"

cd "$SOURCE_DIR/shotcut"
bash scripts/build-shotcut-msys2.sh -c "$CONF"

cp -p "$SOURCE_DIR/shotcut/packaging/windows/amstronggg-logo-64.bmp" "$INSTALL_DIR/" 2>/dev/null || true

echo
echo "DONE."
echo "Portable folder : $INSTALL_DIR/AmstrongggVideoEditor"
echo "Installer script: $INSTALL_DIR/amstronggg-video-editor.iss"
echo "Open the .iss in Inno Setup 6 and press Compile to build the installer."
