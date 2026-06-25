#!/bin/sh
# Menu rofi para cambiar de perfil de pantallas.
THEME="$HOME/.config/rofi/catppuccin-mocha.rasi"

choice=$(printf '%s\n' \
    "  3 monitores" \
    "  Solo laptop" \
    "  Auto (detectar)" \
    | rofi -dmenu -i -p "Pantallas" -theme "$THEME")

case "$choice" in
    *"3 monitores"*)     "$HOME/.config/i3/setup-monitors.sh" tres ;;
    *"Solo laptop"*)     "$HOME/.config/i3/setup-monitors.sh" laptop ;;
    *"Auto"*)            "$HOME/.config/i3/setup-monitors.sh" auto ;;
    *) exit 0 ;;
esac

# Reiniciar i3 reacomoda workspaces y relanza polybar segun las pantallas activas.
i3-msg restart >/dev/null 2>&1
