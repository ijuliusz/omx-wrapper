#!/bin/bash
# install.sh - omxplayer legacy wrapper installer for Raspberry Pi OS (trixie)
# Repo: https://github.com/ijuliusz/omx-wrapper
#
# Usage (run from the directory containing this script and the omx/ folder):
#   sudo bash install.sh
#
# This wrapper bundles a legacy-built omxplayer binary together with its
# required shared libraries (libavformat, libpango, libglib, etc.) compiled
# against trixie's glibc. It will NOT work on older releases (wheezy,
# jessie, stretch, buster, bullseye, bookworm) because those ship an older
# glibc that is missing symbols the bundled libraries require.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="/home/pi"
TARGET_OMX="$TARGET_HOME/omx"

echo "=== [1] Checking target OS version ==="
CODENAME=$(grep -E "^VERSION_CODENAME=" /etc/os-release 2>/dev/null | cut -d= -f2)

if [ "$CODENAME" != "trixie" ]; then
    echo "ERROR: this wrapper was built for Debian/Raspbian trixie."
    echo "Detected system: ${CODENAME:-unknown}"
    echo ""
    echo "The bundled libraries are linked against trixie's glibc and will"
    echo "fail with errors like 'GLIBC_x.xx not found' on older releases."
    echo "Upgrade the system to trixie first, then run this installer again."
    exit 1
fi

echo "OK - system is trixie."

echo "=== [2] Checking source files ==="
if [ ! -d "$SCRIPT_DIR/omx" ]; then
    echo "ERROR: 'omx/' directory not found in $SCRIPT_DIR"
    echo "Make sure install.sh is extracted in the same location as the omx/ folder."
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/omx/omxplayer" ] || [ ! -f "$SCRIPT_DIR/omx/omxplayer.bin" ]; then
    echo "ERROR: omx/omxplayer or omx/omxplayer.bin missing."
    exit 1
fi

echo "=== [3] Copying to $TARGET_OMX ==="
if [ -d "$TARGET_OMX" ]; then
    BACKUP="${TARGET_OMX}.bak.$(date +%Y%m%d%H%M%S)"
    echo "Existing directory $TARGET_OMX -> backing up to $BACKUP"
    mv "$TARGET_OMX" "$BACKUP"
fi

cp -a "$SCRIPT_DIR/omx" "$TARGET_HOME/"

echo "=== [4] Setting executable permissions ==="
chmod +x "$TARGET_OMX/omxplayer"
chmod +x "$TARGET_OMX/omxplayer.bin"
chown -R pi:pi "$TARGET_OMX" 2>/dev/null || true

echo "=== [5] Installing /usr/bin/omxplayer ==="
if [ -f /usr/bin/omxplayer ]; then
    BACKUP_BIN="/usr/bin/omxplayer.bak.$(date +%Y%m%d%H%M%S)"
    echo "Existing /usr/bin/omxplayer -> backing up to $BACKUP_BIN"
    cp /usr/bin/omxplayer "$BACKUP_BIN" 2>/dev/null || true
fi

cp "$TARGET_OMX/omxplayer" /usr/bin/omxplayer
chmod +x /usr/bin/omxplayer
hash -r

echo "=== [6] Verification ==="
if omxplayer -v; then
    echo ""
    echo "Done. omxplayer is working correctly."
else
    echo ""
    echo "WARNING: verification failed. Check the error above."
    echo "Previous files were backed up (see messages above)."
    exit 1
fi