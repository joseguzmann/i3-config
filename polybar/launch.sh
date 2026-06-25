#!/usr/bin/env bash
# Lanza polybar en las 3 pantallas. La barra del monitor primario lleva la
# bandeja del sistema (tray); las demás usan la variante 'sec' sin tray.

# Matar instancias previas
killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.2; done

primary=$(xrandr --query | awk '/ primary/{print $1}')

for m in $(polybar --list-monitors | cut -d: -f1); do
    if [ "$m" = "$primary" ]; then
        MONITOR=$m polybar --reload main &
    else
        MONITOR=$m polybar --reload sec &
    fi
    disown
    sleep 0.3   # evita que arranquen a la vez y compitan
done
