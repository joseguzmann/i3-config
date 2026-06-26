# Guía para Claude Code en este repo (~/.config/i3)

Este repo es la config de **i3** + extras (polybar, picom, rofi, wallpaper) de una
**Lenovo Legion** (Debian 12, GPU híbrida AMD Radeon 680M + NVIDIA RTX 3060).
Es la fuente de verdad: los configs de polybar/picom/rofi/wallpaper viven aquí y
están **enlazados (symlink)** a sus rutas reales vía `install.sh`. Por eso editar
un archivo de este repo == editar la config viva.

## Tu trabajo al editar aquí

1. **Haz el cambio en el archivo del repo** (no en la ruta real; son el mismo inode
   por el symlink, pero edita la ruta del repo para que quede claro).
2. **Verifícalo en vivo** antes de dar por bueno: `i3-msg restart` (reaplica
   monitores y relanza barras), o relanza lo que toque (`~/.config/polybar/launch.sh`,
   `feh ... ~/.wallpapers/catppuccin-mocha.png`, etc.). Valida i3 con `i3 -C ~/.config/i3/config`.
3. **Commit + push** cuando el cambio esté probado y el usuario contento:
   ```sh
   cd ~/.config/i3 && git add -A && git commit -m "<qué cambió>" && git push
   ```
   Mensajes en español, concisos, en imperativo (p.ej. "polybar: arreglar barras
   multi-monitor", "monitores: izquierda horizontal").
4. **No hagas commit/push sin avalarlo el usuario** si el cambio es grande o estético
   y aún no lo ha visto. Para arreglos pequeños ya acordados, adelante.

## Reglas del setup (no romper)

- **Monitores:** se manejan en `setup-monitors.sh` (perfiles `tres`/`laptop`/`auto`).
  El archivo lo lanza i3 con `exec_always` SIN argumento → **nunca** metas
  `i3-msg restart` dentro de `setup-monitors.sh` (bucle infinito). El restart vive
  solo en `display-menu.sh` (menú `Mod+p`). El perfil elegido persiste en
  `.display-mode` (gitignored).
- **DP-1-0** (monitor del medio, 2K 240Hz por USB-C→DP) máximo **120Hz** estable:
  el puerto da 2 carriles DP. 240Hz deja la pantalla en negro. No subir el rate.
- **Polybar multi-monitor:** mantener `screenchange-reload = false` y el
  `sleep 0.3`/`disown` en `launch.sh`, o las barras se matan entre sí.
- **Wallpaper:** diseño centrado/simétrico (feh recorta por monitor). Regenerar con
  `scripts/generate-wallpaper.sh`, no a mano.
- **picom + GPU híbrida (AMD+NVIDIA/PRIME):** mantener `backend = "xrender"`. Con
  `backend = "glx"` picom deja en NEGRO los monitores que no maneja la GPU primaria
  (síntoma: una pantalla en negro aunque i3 tenga ventanas ahí). xrender no soporta
  blur (`blur-method = "none"`); esquinas/sombras/fade/transparencia sí funcionan.

## Seguridad

- **Nunca** manejes ni pidas la contraseña sudo del usuario. Si algo necesita sudo
  (p.ej. `apt install`), dáselo escrito para que lo corra él.

## Contexto del usuario

Programador. Le viene una **Mac** (~ago 2026); plan: replicar este flujo con
**AeroSpace** (tiling i3-like en macOS). Mantener los keybinds trasladables.
Idioma: español.
