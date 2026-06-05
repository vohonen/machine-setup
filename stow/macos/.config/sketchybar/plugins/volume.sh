#!/usr/bin/env bash
# volume_change passes the new level in $INFO; query on startup/forced runs.
VOL="${INFO:-$(osascript -e 'output volume of (get volume settings)')}"
if [ "$(osascript -e 'output muted of (get volume settings)')" = "true" ]; then
  sketchybar --set "$NAME" icon="󰝟" label="mute"
  exit 0
fi
case "$VOL" in
  [5-9][0-9]|100) icon="󰕾" ;;
  [1-4][0-9])     icon="󰖀" ;;
  *)              icon="󰕿" ;;
esac
sketchybar --set "$NAME" icon="$icon" label="${VOL}%"
