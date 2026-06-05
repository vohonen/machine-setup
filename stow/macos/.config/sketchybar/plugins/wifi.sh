#!/usr/bin/env bash
# Wi-Fi: icon only — connected (has an IP) vs not. SSID is unavailable anyway:
# macOS redacts it from CLI tools without location-services permission.
DEV="$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2; exit}')"
if [ -n "$(ipconfig getifaddr "${DEV:-en0}" 2>/dev/null)" ]; then
  sketchybar --set "$NAME" icon="󰖩"
else
  sketchybar --set "$NAME" icon="󰖪"
fi
