#!/usr/bin/env bash
# Active input source, abbreviated to initials ("Finnish Tex" -> FT).
FULL="$(defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null \
  | awk -F'"' '/KeyboardLayout Name/{print $4; exit}')"
ABBR="$(awk '{for(i=1;i<=NF;i++) printf "%s", toupper(substr($i,1,1))}' <<<"$FULL")"
sketchybar --set "$NAME" label="${ABBR:-?}"
