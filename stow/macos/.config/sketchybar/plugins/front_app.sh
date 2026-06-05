#!/usr/bin/env bash
# Focused app: icon (app font) + name. front_app_switched passes the name in $INFO.
APP="${INFO:-$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)}"
[ -z "$APP" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }
sketchybar --set "$NAME" drawing=on \
  icon="$("$HOME/.config/sketchybar/plugins/icon_map.sh" "$APP")" \
  label="$APP"
