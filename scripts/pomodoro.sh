#!/usr/bin/env bash
# Módulo polybar para gnome-pomodoro (sin ventana, todo en la barra).
# Lee el estado por D-Bus y pinta icono + tiempo restante.
#   Clic izq  -> start/stop     (lo enchufa config.ini)
#   Clic der  -> pausa/reanuda
#   Clic medio-> saltar a lo siguiente
# El servicio corre en background: i3 lo lanza con `gnome-pomodoro --no-default-window`.
#
# Iconos por escape \u (Nerd Font): si se pegan literales se pierden al guardar.

I_FOCUS=$''   # reloj
I_BREAK=$''   # café
I_PAUSE=$''   # pausa

props=$(gdbus call --session --dest org.gnome.Pomodoro \
  --object-path /org/gnome/Pomodoro \
  --method org.freedesktop.DBus.Properties.GetAll org.gnome.Pomodoro 2>/dev/null)

# Servicio caído o en reposo -> reloj apagado; un clic lo arranca.
if [ -z "$props" ]; then
  echo "%{F#6c7086}${I_FOCUS}%{F-}"
  exit 0
fi

state=$(grep -oP "(?<='State': <')[^']*" <<<"$props")
elapsed=$(grep -oP "(?<='Elapsed': <)[0-9.]+" <<<"$props")
dur=$(grep -oP "(?<='StateDuration': <)[0-9.]+" <<<"$props")
paused=$(grep -oP "(?<='IsPaused': <)(true|false)" <<<"$props")

if [ -z "$state" ] || [ "$state" = "null" ]; then
  echo "%{F#6c7086}${I_FOCUS}%{F-}"
  exit 0
fi

left=$(( ${dur%.*} - ${elapsed%.*} ))
[ "$left" -lt 0 ] && left=0
printf -v clock '%02d:%02d' $((left/60)) $((left%60))

case "$state" in
  pomodoro)    icon="$I_FOCUS"; col="#f38ba8" ;;  # foco  -> rojo
  short-break) icon="$I_BREAK"; col="#a6e3a1" ;;  # pausa -> verde
  long-break)  icon="$I_BREAK"; col="#94e2d5" ;;  # pausa larga -> teal
  *)           icon="$I_FOCUS"; col="#cdd6f4" ;;
esac
[ "$paused" = "true" ] && { icon="$I_PAUSE"; col="#6c7086"; }

echo "%{F$col}$icon%{F-} $clock"
