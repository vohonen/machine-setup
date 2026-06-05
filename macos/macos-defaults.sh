#!/usr/bin/env bash
set -euo pipefail

# key repeat - biggest vim QoL win
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# menu bar: auto-hide (sketchybar replaces it; hover the top edge to reveal the real one)
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# Keyboard access to the auto-hidden menu bar (defaults are unreachable on Finnish layout):
#   Ctrl+Alt+M = move focus to menu bar (reveals it; arrows/letters to navigate)  [hotkey 7]
# parameters = [ascii, keycode, modifier-mask]; Ctrl+Alt = 262144 + 524288 = 786432
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 7 \
  '<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>109</integer><integer>46</integer><integer>786432</integer></array></dict></dict>'
# Help-menu search lives in aerospace.toml (ctrl-alt-h) instead: the "Show Help menu"
# symbolic hotkey (98) is dispatched to the frontmost app and races the auto-hidden
# menu bar's reveal animation -> works ~1 in 10. Disable it so nothing conflicts.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 98 \
  '<dict><key>enabled</key><false/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>104</integer><integer>4</integer><integer>786432</integer></array></dict></dict>'
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
killall Finder || true
