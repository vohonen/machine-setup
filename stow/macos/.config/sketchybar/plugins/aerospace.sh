#!/usr/bin/env bash
# Redraw one workspace pill ($1 = workspace id, $NAME = sketchybar item).
# Focused -> yellow highlight; occupied -> dim pill with app icons; empty -> hidden.
WS="$1"
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
ICON_MAP="$HOME/.config/sketchybar/plugins/icon_map.sh"

icons=""
while IFS= read -r app; do
  [ -n "$app" ] && icons+="${icons:+ }$("$ICON_MAP" "$app")"
done < <(aerospace list-windows --workspace "$WS" --format '%{app-name}' 2>/dev/null | sort -u)

if [ "$WS" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" drawing=on \
    background.color=0xffeece61 \
    icon.color=0xff222222 label.color=0xff222222
elif [ -n "$icons" ]; then
  sketchybar --set "$NAME" drawing=on \
    background.color=0x28ffffff \
    icon.color=0xffd8dee9 label.color=0xffd8dee9
else
  sketchybar --set "$NAME" drawing=off
fi

if [ -n "$icons" ]; then
  sketchybar --set "$NAME" label="$icons" label.drawing=on
else
  sketchybar --set "$NAME" label.drawing=off
fi
