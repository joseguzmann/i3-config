#!/bin/sh
# install.sh — Deja este repo como fuente de verdad de la config de i3 + extras.
#
# Enlaza (symlink) los configs de polybar, picom, rofi y el wallpaper desde este
# repo hacia sus rutas reales en ~/.config y ~/.wallpapers. Así, editar el repo
# == editar la config viva (y al revés), y todo queda versionado.
#
# El propio repo ES ~/.config/i3, así que la config de i3 ya está en su sitio.
#
# Uso:  ~/.config/i3/install.sh
# Idempotente: se puede correr varias veces. Hace backup de archivos reales previos.
set -e

REPO="$HOME/.config/i3"
BACKUP="$HOME/.config/i3-backup-$(date +%s 2>/dev/null || echo bak)"

link() {
    src="$1"; dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        mkdir -p "$BACKUP"
        mv "$dst" "$BACKUP/"
        echo "  backup: $dst -> $BACKUP/"
    fi
    ln -s "$src" "$dst"
    echo "  link:   $dst -> $src"
}

echo "Enlazando configs desde $REPO ..."
link "$REPO/polybar/config.ini"          "$HOME/.config/polybar/config.ini"
link "$REPO/polybar/launch.sh"           "$HOME/.config/polybar/launch.sh"
link "$REPO/picom/picom.conf"            "$HOME/.config/picom/picom.conf"
link "$REPO/rofi/catppuccin-mocha.rasi"  "$HOME/.config/rofi/catppuccin-mocha.rasi"
link "$REPO/rofi/config.rasi"            "$HOME/.config/rofi/config.rasi"
link "$REPO/wallpapers/catppuccin-mocha.png" "$HOME/.wallpapers/catppuccin-mocha.png"

chmod +x "$REPO"/*.sh "$REPO"/polybar/launch.sh "$REPO"/scripts/*.sh 2>/dev/null || true

echo
echo "Listo. Recarga i3 con:  i3-msg restart"
[ -d "$BACKUP" ] && echo "Se guardaron archivos previos en: $BACKUP"
