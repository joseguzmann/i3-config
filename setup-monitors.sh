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
# Al final relanza polybar (serializado DESPUES del xrandr) para que las barras no
# se pisen con la reconfiguracion de salidas (arranque en frio / restart de i3).

STATE="$HOME/.config/i3/.display-mode"

is_connected() { xrandr | grep -q "^$1 connected"; }

# Espera (hasta ~8s) a que las salidas dadas reporten "connected".
# En arranque en frio los monitores externos tardan en despertar; sin esto el
# perfil 'tres' se aplica a medias y queda todo mal cuadrado.
wait_for_outputs() {
    i=0
    while [ "$i" -lt 40 ]; do
        all=1
        for o in "$@"; do is_connected "$o" || all=0; done
        [ "$all" = 1 ] && return 0
        i=$((i + 1))
        sleep 0.2
    done
    return 1
}

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

# Si llega un argumento explicito (desde el menu) ES la preferencia -> se guarda.
# Sin argumento (arranque) usamos la preferencia guardada y NO la sobrescribimos,
# para que un boot sin monitores no degrade tu eleccion 'tres' a 'laptop'.
REQUESTED="$1"
if [ -n "$REQUESTED" ]; then
    echo "$REQUESTED" > "$STATE"
    MODE="$REQUESTED"
else
    [ -f "$STATE" ] && MODE=$(cat "$STATE") || MODE=auto
fi

# Si pedimos 'tres' (o auto), esperamos a que los externos despierten antes de decidir.
if [ "$MODE" = "tres" ] || [ "$MODE" = "auto" ]; then
    wait_for_outputs HDMI-1-0 DP-1-0
fi

if [ "$MODE" = "auto" ]; then
    if is_connected HDMI-1-0 && is_connected DP-1-0; then MODE=tres; else MODE=laptop; fi
fi

# Si pedimos 'tres' pero algun externo no esta, caemos a laptop (no dejar todo roto).
if [ "$MODE" = "tres" ] && ! { is_connected HDMI-1-0 && is_connected DP-1-0; }; then
    MODE=laptop
fi

case "$MODE" in
    tres)   profile_tres ;;
    laptop) profile_laptop ;;
    *)      profile_laptop ;;   # fallback seguro
esac

# Aplicar wallpaper y barras DESPUES de fijar el xrandr (si se hace antes, en
# arranque en frio quedan mal cuadrados o las barras se matan en el restart).
WALL="$HOME/.wallpapers/catppuccin-mocha.png"
[ -f "$WALL" ] && feh --no-fehbg --bg-fill "$WALL" >/dev/null 2>&1
[ -x "$HOME/.config/polybar/launch.sh" ] && "$HOME/.config/polybar/launch.sh" >/dev/null 2>&1 &
