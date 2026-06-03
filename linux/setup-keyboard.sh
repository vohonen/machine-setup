#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Install the custom Finnish-TeX xkb symbols file (kotoistus layout).
sudo cp fi /usr/share/X11/xkb/symbols/fi

# Caps Lock -> Escape (GNOME). Harmless if not on GNOME.
if command -v dconf >/dev/null; then
  dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:swapescape']" || true
fi

echo "Installed xkb 'fi' symbols + caps:swapescape. Log out/in (or run: setxkbmap fi)."
