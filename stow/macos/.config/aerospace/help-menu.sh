#!/usr/bin/env bash
# Ctrl+Alt+H: open the focused app's Help menu (search field auto-focused).
# Apps without a Help menu (e.g. Alacritty has only Apple + app menus) fall
# back to plain menu-bar focus, i.e. the Ctrl+Alt+M behaviour.
osascript <<'EOF'
tell application "System Events"
  try
    click menu bar item "Help" of menu bar 1 of (first process whose frontmost is true)
  on error
    key code 46 using {control down, option down}
  end try
end tell
EOF
