#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# 1. Homebrew (already present on this machine, but keep idempotent for fresh Macs)
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. packages
brew bundle --file=Brewfile

# 3. dotfiles (idempotent symlinks)
brew list stow >/dev/null 2>&1 || brew install stow
# back up a pre-existing real ~/.zprofile so stow can own it (fresh Macs ship one)
if [ -f "$HOME/.zprofile" ] && [ ! -L "$HOME/.zprofile" ]; then
  mv "$HOME/.zprofile" "$HOME/.zprofile.pre-stow"
fi
stow -d stow -t "$HOME" common macos

# 4. nvim config (submodule, symlinked by stow in step 3)
git submodule update --init --recursive

# 5. keyboard layout (copy - macOS wants a real file, not a symlink)
mkdir -p "$HOME/Library/Keyboard Layouts"
cp macos/Finnish-TeX.keylayout "$HOME/Library/Keyboard Layouts/"

# 6. system defaults
bash macos/macos-defaults.sh

# 7. git identity + aliases
git config --global user.name  "Vili Kohonen"
git config --global user.email "vili.kohonen@protonmail.com"
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.st status

cat <<'EOF'

MANUAL STEPS (cannot be scripted reliably):
 - SSH key: ssh-keygen -t ed25519 -C "vili.kohonen@protonmail.com"
     then add ~/.ssh/config (see EXECUTION-PLAN Phase 4), ssh-add --apple-use-keychain,
     and paste the public key into GitHub.
 - Settings > Keyboard > Input Sources: add "Finnish TeX", set as primary (after log out/in).
 - Settings > Keyboard > Keyboard Shortcuts > Modifier Keys: Caps Lock -> Escape.
 - Grant AeroSpace Accessibility permission on first launch.
 - Settings > Internet Accounts: add Google -> enable Mail; Mail > Settings > General > default reader.
EOF
