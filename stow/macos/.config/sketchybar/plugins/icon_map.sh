#!/usr/bin/env bash
# App name -> sketchybar-app-font ligature. Trimmed to apps we actually run;
# names verified against the official map (github.com/kvndrsslr/sketchybar-app-font).
case "$1" in
  "Alacritty")                       echo ":alacritty:" ;;
  "Firefox")                         echo ":firefox:" ;;
  "Slack")                           echo ":slack:" ;;
  "Mail")                            echo ":mail:" ;;
  "Spotify")                         echo ":spotify:" ;;
  "Skim" | "Preview")                echo ":preview:" ;;
  "Finder")                          echo ":finder:" ;;
  "System Settings")                 echo ":gear:" ;;
  *)                                 echo ":default:" ;;
esac
