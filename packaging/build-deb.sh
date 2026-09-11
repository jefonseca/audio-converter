#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
VERSION=${1:-0.0.1}
PACKAGE="audio-converter"
BUILD_DIR="$ROOT_DIR/build/deb"
STAGING_DIR="$BUILD_DIR/${PACKAGE}_${VERSION}_all"
OUTPUT="$ROOT_DIR/${PACKAGE}_${VERSION}_all.deb"

[[ $VERSION =~ ^[0-9]+(\.[0-9]+)*([+-][0-9A-Za-z.-]+)?$ ]] || {
    printf 'Error: versión Debian inválida: %s\n' "$VERSION" >&2
    exit 2
}
command -v dpkg-deb >/dev/null 2>&1 || {
    printf 'Error: no se encontró dpkg-deb.\n' >&2
    exit 1
}

rm -rf -- "$BUILD_DIR" "$OUTPUT"
install -Dm755 "$ROOT_DIR/audio-converter" \
    "$STAGING_DIR/usr/bin/audio-converter"
install -Dm644 "$ROOT_DIR/LICENSE" "$STAGING_DIR/usr/share/doc/$PACKAGE/LICENSE"
install -Dm644 "$ROOT_DIR/README.md" "$STAGING_DIR/usr/share/doc/$PACKAGE/README.md"

install -d "$STAGING_DIR/DEBIAN"
cat > "$STAGING_DIR/DEBIAN/control" <<EOF
Package: $PACKAGE
Version: $VERSION
Section: sound
Priority: optional
Architecture: all
Maintainer: audio-converter contributors
Depends: bash, ffmpeg
Recommends: zenity | kdialog
Description: simple FFmpeg audio converter
 Converts audio files from a directory to M4A with configurable codec and bitrate.
 Supports Zenity, KDialog, and terminal progress reporting.
EOF

dpkg-deb --build --root-owner-group "$STAGING_DIR" "$OUTPUT" >/dev/null
printf 'Paquete creado: %s\n' "$OUTPUT"
