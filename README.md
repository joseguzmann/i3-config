# i3 config — Catppuccin Mocha (Legion, 3 monitores)

Configuración personal de **i3** con tema **Catppuccin Mocha**, barra **Polybar**,
compositor **picom**, lanzador **rofi** y manejo de **perfiles de pantalla** para
una Lenovo Legion (GPU híbrida AMD Radeon 680M + NVIDIA RTX 3060), Debian 12.

Este repo es a la vez la carpeta `~/.config/i3` y la **fuente de verdad** de los
configs relacionados (polybar/picom/rofi/wallpaper), que se enlazan a sus rutas
reales con `install.sh`.

## Qué incluye

```
~/.config/i3/
├── config                      # i3 (tema, gaps, keybinds, asignación de workspaces)
├── setup-monitors.sh           # perfiles de pantalla (tres / laptop / auto) con xrandr
├── display-menu.sh             # menú rofi para cambiar de perfil (Mod+p)
├── polybar/{config.ini,launch.sh}   # barra, una por monitor (tray solo en el primario)
├── picom/picom.conf            # esquinas redondeadas, sombras, blur, transparencia
├── rofi/{catppuccin-mocha.rasi,config.rasi}
├── wallpapers/catppuccin-mocha.png
├── scripts/generate-wallpaper.sh    # regenera el wallpaper con ImageMagick
└── install.sh                  # enlaza todo a ~/.config y ~/.wallpapers
```

## Setup en una máquina nueva

```sh
# 1. Clonar EN la ruta de i3
git clone git@github.com:joseguzmann/i3-config.git ~/.config/i3

# 2. Dependencias (Debian/Ubuntu)
sudo apt install -y i3 polybar picom rofi feh imagemagick x11-xserver-utils

# 3. Fuente con iconos (FiraCode Nerd Font) en ~/.local/share/fonts y luego:
fc-cache -f

# 4. Enlazar polybar/picom/rofi/wallpaper a sus rutas reales
~/.config/i3/install.sh

# 5. Entrar a i3 (o recargar)
i3-msg restart
```

> `install.sh` es idempotente y hace backup de cualquier archivo real previo.

## Monitores

Tres pantallas nativas (sin DisplayLink): izquierda **HDMI-1-0**, medio
**DP-1-0** (primario), laptop **eDP**. Workspaces: **1-3 → izquierda**,
**4-6 → medio**, **7-10 → laptop**.

- **`Mod+p`** abre un menú con perfiles: **3 monitores / Solo laptop / Auto**.
- El perfil elegido se guarda en `~/.config/i3/.display-mode` (no versionado) y el
  autoarranque lo respeta. `auto` detecta qué hay conectado.
- El monitor del medio es 2K 240Hz por **USB-C→DP**, pero el puerto entrega solo
  2 carriles DP → máximo estable **120Hz** a 1440p (240Hz deja la pantalla negra).

Editar el layout = editar `setup-monitors.sh` (función `profile_tres` / `profile_laptop`).

## Notas de tema

- **Polybar multi-monitor:** `screenchange-reload = false` en `config.ini`. Con
  `true` las 3 barras se recargan a la vez al cambiar de pantalla y se matan entre
  sí (sobrevive solo una); `launch.sh` ya relanza en cada `i3-msg restart` y mete
  un `sleep`/`disown` entre lanzamientos para que no compitan.
- **Wallpaper:** diseño **centrado/simétrico** a propósito, porque `feh --bg-fill`
  recorta distinto en cada monitor. Regenerar con `scripts/generate-wallpaper.sh`.

## Atajos principales

| Atajo            | Acción                                  |
|------------------|------------------------------------------|
| `Mod+Return`     | Terminal                                 |
| `Mod+d`          | rofi (lanzador)                          |
| `Mod+p`          | Menú de perfiles de pantalla             |
| `Mod+i`          | Alternar teclado ES/US                   |
| `Mod+h/j/k/l`    | Mover el foco                            |
| `Mod+Shift+h/j/k/l` | Mover ventana                         |
| `Mod+Tab`        | Workspace anterior (back_and_forth)      |
| `Mod+1..0`       | Ir a workspace                           |
| `Mod+Shift+r`    | Reiniciar i3 (reaplica monitores+barras) |

## Mantenerlo con IA

Ver [`CLAUDE.md`](CLAUDE.md): al abrir Claude Code en `~/.config/i3`, se le instruye
mantener este repo actualizado y hacer commit/push conforme se mejora el setup.
