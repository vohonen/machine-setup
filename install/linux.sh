#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# 1. packages
sudo apt update && xargs -a apt-packages.txt sudo apt install -y
command -v stow >/dev/null || sudo apt install -y stow

# 2. dotfiles (idempotent symlinks)
stow -d stow -t "$HOME" common linux

# 3. nvim config (submodule, symlinked by stow in step 2)
git submodule update --init --recursive

# 4. keyboard layout (custom Finnish-TeX xkb + caps:swapescape)
bash linux/setup-keyboard.sh

# 5. git identity + aliases
git config --global user.name  "Vili Kohonen"
git config --global user.email "vili.kohonen@protonmail.com"
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.st status

cat <<'EOF'

MANUAL STEPS:
 - SSH key: ssh-keygen -t ed25519 -C "vili.kohonen@protonmail.com"; add the public key to GitHub.
 - Log out / back in for the keyboard layout to take effect.
EOF
