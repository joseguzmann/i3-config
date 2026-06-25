#!/bin/sh
# Genera el wallpaper Catppuccin Mocha (degradado oscuro + glow central simétrico).
# El diseño es CENTRADO a propósito: con varios monitores feh --bg-fill recorta
# distinto en cada pantalla, y un diseño simétrico se ve bien en todas.
# Requiere ImageMagick (convert).
set -e

OUT="${1:-$HOME/.config/i3/wallpapers/catppuccin-mocha.png}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

convert -size 2560x1440 radial-gradient:"#28283e"-"#1e1e2e" "$TMP/base.png"
convert -size 2560x1440 radial-gradient:"#89b4fa"-"#1e1e2e" \
  -channel RGB -evaluate multiply 0.22 +channel "$TMP/glow.png"
convert -size 2560x1440 gradient:"#1e1e2e"-"#cba6f7" \
  -channel RGB -evaluate multiply 0.12 +channel "$TMP/tint.png"

convert "$TMP/base.png" "$TMP/glow.png" -compose screen -composite \
        "$TMP/tint.png" -compose screen -composite \
        -blur 0x18 \
        "$OUT"

echo "wallpaper generado en: $OUT"
