#!/bin/sh
# Perfiles de pantallas.   Uso: setup-monitors.sh [tres|laptop|auto]
#
#   tres   -> 3 pantallas: HDMI izquierda HORIZONTAL (2560x1440@144 en +0+0),
#             DP medio PRIMARIO 2560x1440@120 en +2560+0,
#             eDP laptop 1920x1080@165 en +5120+180 (centrado vertical vs los de 1440 de alto).
#   laptop -> solo eDP (1920x1080@165, primario, en 0x0); HDMI y DP apagados.
#   auto   -> detecta: si HDMI y DP estan conectados usa 'tres', si no 'laptop'.
#
# Sin argumento: usa el ultimo perfil guardado (~/.config/i3/.display-mode); si no hay, 'auto'.
# NOTA: este script NO reinicia i3 (lo lanza i3 con exec_always); el menu es quien reinicia.

STATE="$HOME/.config/i3/.display-mode"

is_connected() { xrandr | grep -q "^$1 connected"; }

# Apagar cualquier salida DisplayLink/evdi (adaptador USB) que aparezca
for o in $(xrandr | awk '/^DVI-I-[0-9].* connected/{print $1}'); do
    xrandr --output "$o" --off 2>/dev/null
done

profile_tres() {
    xrandr --output HDMI-1-0 --mode 2560x1440 --rate 144 --rotate normal --pos 0x0 \
           --output DP-1-0 --primary --mode 2560x1440 --rate 120 --rotate normal --pos 2560x0 \
           --output eDP --mode 1920x1080 --rate 165 --rotate normal --pos 5120x180
}

profile_laptop() {
    xrandr --output HDMI-1-0 --off \
           --output DP-1-0 --off \
           --output eDP --primary --mode 1920x1080 --rate 165 --rotate normal --pos 0x0
}

MODE="$1"
[ -z "$MODE" ] && { [ -f "$STATE" ] && MODE=$(cat "$STATE") || MODE=auto; }

if [ "$MODE" = "auto" ]; then
    if is_connected HDMI-1-0 && is_connected DP-1-0; then MODE=tres; else MODE=laptop; fi
fi

case "$MODE" in
    tres)   profile_tres ;;
    laptop) profile_laptop ;;
    *)      profile_laptop ;;   # fallback seguro
esac

# Guardar el perfil aplicado para que el autoarranque lo respete
echo "$MODE" > "$STATE"
