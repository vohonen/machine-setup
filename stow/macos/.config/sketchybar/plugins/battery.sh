#!/usr/bin/env bash
batt="$(pmset -g batt)"
pct="$(grep -Eo '[0-9]+%' <<<"$batt" | head -1)"
[ -z "$pct" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }  # desktop Mac

if grep -q 'AC Power' <<<"$batt"; then
  icon="󰂄"
else
  case "${pct%\%}" in
    9*|100) icon="󰁹" ;;
    7*|8*)  icon="󰂀" ;;
    4*|5*|6*) icon="󰁾" ;;
    2*|3*)  icon="󰁻" ;;
    *)      icon="󰁺" ;;
  esac
fi
sketchybar --set "$NAME" icon="$icon" label="$pct"
