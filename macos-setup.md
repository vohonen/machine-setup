# Cross-platform machine setup (macOS + Ubuntu)

A runbook + repo plan to provision a new machine fast on either OS. The current Ubuntu config
is `github.com/vohonen/ubuntu-setup` (sibling repos `vohonen/nvim-config`, `vohonen/zathurarc`,
`vohonen/alacritty-config`); this folds both OSes into one repo.

Read "Hard constraints" before running anything on macOS. Do NOT blindly translate the Ubuntu
dotfiles; several lines are broken or Linux-only on macOS (flagged below).

## Repo & bootstrap (the vehicle — point of the whole thing)

One repo, OS-detecting bootstrap, idempotent so it can re-run on any new machine.

```
machine-setup/
  bootstrap.sh              # detects OS, runs the right installer
  Brewfile                  # macOS packages (brew bundle)
  apt-packages.txt          # Ubuntu packages (apt)
  install/
    macos.sh                # brew bundle, stow, defaults, keylayout, prints manual GUI steps
    linux.sh                # apt, stow, xkb layout, dconf load
  stow/                     # symlinked into $HOME via GNU stow
    common/   .gitconfig  .config/nvim/  .config/sioyek/
    macos/    .zshrc  .zprofile  .config/aerospace/aerospace.toml
    linux/    .bashrc  .bash_aliases
  macos/                    # copied (NOT symlinked): assets + scripts
    Finnish-TeX.keylayout   # the custom layout (generated; see gen_keylayout.py)
    gen_keylayout.py
    macos-defaults.sh
  linux/
    fi                      # custom xkb Finnish-TeX layout (Ubuntu-only)
    setup-keyboard.sh
    dconf-settings.ini
```

`bootstrap.sh`:
```sh
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
case "$(uname -s)" in
  Darwin) exec bash install/macos.sh ;;
  Linux)  exec bash install/linux.sh ;;
  *) echo "unsupported OS"; exit 1 ;;
esac
```

`install/macos.sh`:
```sh
#!/usr/bin/env bash
set -euo pipefail
# 1. Homebrew
if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
# 2. packages
brew bundle --file=Brewfile
# 3. dotfiles (idempotent symlinks)
brew list stow >/dev/null 2>&1 || brew install stow
stow -d stow -t "$HOME" common macos
# 4. keyboard layout (copy, not symlink — macOS wants a real file)
mkdir -p "$HOME/Library/Keyboard Layouts"
cp "macos/Finnish-TeX.keylayout" "$HOME/Library/Keyboard Layouts/"
# 5. system defaults
bash macos/macos-defaults.sh
echo
echo "MANUAL (GUI) STEPS — cannot be scripted reliably:"
echo " - Settings > Keyboard > Input Sources: add 'Finnish TeX', set primary (after re-login)"
echo " - Settings > Keyboard > Keyboard Shortcuts > Modifier Keys: Caps Lock -> Escape"
echo " - Settings > Internet Accounts: add Google (Gmail) -> enable Mail"
echo " - Mail > Settings > General: set as default email reader"
echo " - Grant AeroSpace accessibility permission on first launch"
echo " - ssh-keygen + add public key to GitHub (see Phase 4)"
```

`install/linux.sh` (folds in the old ubuntu-setup; concise):
```sh
#!/usr/bin/env bash
set -euo pipefail
sudo apt update && xargs -a apt-packages.txt sudo apt install -y
command -v stow >/dev/null || sudo apt install -y stow
stow -d stow -t "$HOME" common linux
bash linux/setup-keyboard.sh          # sudo cp linux/fi /usr/share/X11/xkb/symbols/; caps:swapescape
dconf load / < linux/dconf-settings.ini
```

Conventions:
- **nvim config**: add `vohonen/nvim-config` as a git submodule at `stow/common/.config/nvim`,
  or clone it in the installer. Same for sioyek config if kept separate.
- **Secrets**: never commit private keys/tokens. `.gitignore` them; generate SSH keys per machine.
- **First run on a bare Mac**: `xcode-select --install` (gets git) -> clone repo -> `./bootstrap.sh`.
- **Idempotent**: stow, `brew bundle`, and `defaults write` are all safe to re-run.

The phases below are the detailed spec for what `install/macos.sh` automates plus the manual
GUI steps.

## Who this is for / what I actually do

- PhD applied math; AI safety researcher. Live in the terminal and Neovim.
- Much less code now, much more LaTeX. Papers compiled **locally** in Neovim (VimTeX), preferred
  over Overleaf. SyncTeX matters.
- ~99% terminal (Alacritty) + Firefox + Slack + (now) Mail. Displays: MacBook + large monitor +
  vertical monitor (incoming); MacBook used as-is on the desk.
- Shell: zsh. No tmux. Window mgmt: **AeroSpace, flat (no workspaces)**. Launcher: Spotlight +
  AeroSpace exec keybinds. PDF: sioyek. Passwords: Proton Pass.
- Keyboard: built-in MacBook (UK keycaps, ISO) running a **custom `.keylayout`** that reproduces
  my Finnish-TeX layout (`$ \ ^ ~ { }` at base/shift). Caps Lock -> Escape.

## Decisions — resolved

1. Terminal = Alacritty (port `alacritty-config`). No tmux.
2. Window mgmt = **AeroSpace**, flat (NO workspaces), hotkey-to-app via `exec`. Does not require
   disabling SIP. No Rectangle. (Fallback if heavy: `skhd` for hotkey-to-app only.)
3. Launcher = Spotlight + AeroSpace keybinds. No Raycast.
4. PDF = sioyek (Skim only as fallback if inverse search misbehaves).
5. LaTeX = full MacTeX.
6. Keyboard = **custom `Finnish-TeX.keylayout`** (reproduces the `fi` kotoistus layout: `$` `\`
   `{` `}` `^` `~` at base/shift, standard Finnish brackets via Option). Caps -> Esc via native
   Modifier Keys. No Karabiner. Generated by `macos/gen_keylayout.py`; the `fi` xkb file stays
   Ubuntu-only.
7. Email = **Gmail in Apple Mail** (Google's browser client hijacks the keyboard; native Mail
   frees the browser). Set Mail as default; bind `alt-m`.

## Hard constraints (three Linux assumptions that break on macOS)

1. **Shell sourcing.** Ubuntu GNOME Terminal runs non-login shells reading `.bashrc`; macOS runs
   login shells. With zsh, interactive config goes in `.zshrc`.
2. **BSD userland, not GNU.** `ls --color`, `dircolors`, `sed -i`, `date -d`, `readlink -f`
   differ/absent. Use `CLICOLOR=1`, or install `coreutils gnu-sed gawk findutils` and use the
   `g`-prefixed binaries.
3. **No xkb / X11 / GTK by default.** The Ubuntu keyboard section (xkb `fi`, `dconf
   caps:swapescape`) does not port; replaced by the custom `.keylayout`. Zathura is GTK ->
   replaced by sioyek.

Lines that are broken or Linux-only on macOS — do NOT carry over:
- `source /etc/profile.d/bash_completion.sh` — file absent; errors every startup. Drop it.
- The `[ -x /usr/bin/dircolors ]` block — guard fails, colored `ls` dies. Use `CLICOLOR=1`;
  move `grep --color=auto` out of that dead block.
- `xdotool` and `xclip` from the nvim README — X11-only. Do NOT install. nvim uses
  pbcopy/pbpaste natively; sioyek forward search needs no xdotool.
- `lesspipe` line — harmless no-op, ignore.

## Phase 1 — Brewfile (installed by `brew bundle`)

```ruby
brew "neovim"
brew "git"
brew "coreutils"
brew "gnu-sed"
brew "stow"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "choose-gui"          # OPTIONAL: dmenu-style fuzzy selector for scripts
brew "starship"            # OPTIONAL: one prompt across bash+zsh, Ubuntu+Mac

cask "alacritty"
cask "aerospace"
cask "firefox"
cask "proton-pass"
cask "sioyek"
cask "mactex"
cask "font-hack-nerd-font"
cask "maccy"               # OPTIONAL clipboard history
# No karabiner-elements: the custom .keylayout covers the layout; Caps->Esc is native.
```

## Phase 2 — zsh config (`stow/macos/.zshrc`; translate `.bashrc`, don't copy it)

```zsh
eval "$(/opt/homebrew/bin/brew shellenv)"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY APPEND_HISTORY

bindkey -v
bindkey -M viins '^L' clear-screen
bindkey -M vicmd '^L' clear-screen

export CLICOLOR=1
alias grep='grep --color=auto'

autoload -Uz compinit
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
compinit

export EDITOR=nvim
export TEXMFHOME=$HOME/.texmf

PROMPT='%F{green}[%n]%f %F{blue}%~%f $ '
# eval "$(starship init zsh)"

[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases   # port .bash_aliases; watch GNU-only flags
```

## Phase 4 — Git + SSH

```sh
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.st status
git config --global user.name "Vili Vohonen"      # confirm exact form
git config --global user.email "<github-email>"   # ask me

ssh-keygen -t ed25519 -C "<github-email>"
# ~/.ssh/config:
#   Host github.com
#     AddKeysToAgent yes
#     UseKeychain yes
#     IdentityFile ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```
Add the public key to GitHub.

## Phase 5 — Neovim + Nerd Font

- `nvim-config` cloned/submoduled to `~/.config/nvim`.
- Install `font-hack-nerd-font`, set as Alacritty font (nvim-tree icons).
- Verify `"+y` reaches the system clipboard (nvim uses pbcopy/pbpaste).
- `:Mason` for language servers; `:checkhealth` to diagnose.

## Phase 6 — LaTeX + sioyek + SyncTeX

1. MacTeX via Brewfile. Confirm `latexmk`, `tlmgr` on PATH (`/Library/TeX/texbin`).
2. VimTeX viewer -> sioyek: `vim.g.vimtex_view_method = 'sioyek'`.
3. Forward search (nvim->PDF) reliable. Inverse search (PDF->nvim) is the fiddly part on macOS;
   if it fails, set `vim.g.vimtex_callback_progpath = "/opt/homebrew/bin/nvim"`; ensure latexmk
   runs `-synctex=1` (VimTeX default).
4. Port `zathurarc` keybindings into `~/.config/sioyek/prefs_user.config` (sioyek ships vim nav).
5. Fallback if inverse search keeps failing: `vimtex_view_method = 'skim'`.
(TeX symbols `$ \ { } ^ ~` are at base/shift in the custom layout, so no Option gymnastics.)

## Phase 7 — Keyboard (custom Finnish-TeX `.keylayout`)

The repo ships `macos/Finnish-TeX.keylayout`, generated from the `fi` kotoistus block by
`macos/gen_keylayout.py`. It reproduces the layout: `å` on key left of 1; `$` on base of the key
right of P; `\ ^ ~` on the next key (literal, not dead keys); `{ }` on base/shift of the key
right of `+?`; standard Finnish `{ [ ] }` on Option+7/8/9/0; pipe on Option of the `'*` key, the
left-of-Z key, and Option+Shift+i. Option acts as AltGr (both Options; macOS can't split them).

Install (done by `install/macos.sh`):
```sh
cp macos/Finnish-TeX.keylayout "$HOME/Library/Keyboard Layouts/"
# then log out / back in
```
Then: Settings -> Keyboard -> Input Sources -> add **Finnish TeX** -> set primary.
Caps -> Esc: Settings -> Keyboard -> Keyboard Shortcuts -> Modifier Keys -> Caps Lock -> Escape.

MUST verify on-device (these are the only uncertain parts):
- **The two ISO keys.** The layout assumes key code 50 = the key LEFT OF 1 (-> `å`) and code 10
  = the key LEFT OF Z (-> `< > |`). On UK Apple ISO these are easy to have backwards. If `å` and
  the angle brackets land on the wrong keys, swap codes `50` and `10` in `gen_keylayout.py` and
  regenerate (`python3 macos/gen_keylayout.py`).
- **Cmd shortcuts** (Cmd+C/V/etc.) and Cmd+Shift shortcuts work — the modifierMap routes Cmd to
  base/shift. If any feel off, that's the modifierMap to revisit.
- Rare level-3/4 dead-key diacritics (schwa, eth, thorn, dead accents) were omitted as
  non-essential. Add via Ukelele if ever needed.

To regenerate after edits: `python3 macos/gen_keylayout.py` (writes the `.keylayout`), reinstall,
log out/in. Keeping the generator in-repo means the layout is reproducible, not a binary blob.

Key repeat (biggest vim QoL win), in `macos/macos-defaults.sh`:
```sh
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
```

## Phase 8 — AeroSpace + launcher + Mail

`stow/macos/.config/aerospace/aerospace.toml`:
```toml
start-at-login = true

[mode.main.binding]
# Hotkey-to-app: raises + focuses the app on whichever monitor it lives on.
alt-t = 'exec-and-forget open -a Alacritty'
alt-b = 'exec-and-forget open -a Firefox'
alt-s = 'exec-and-forget open -a Slack'
alt-m = 'exec-and-forget open -a Mail'
# Focus movement (within tiles and across the 3 monitors).
alt-h = 'focus left'
alt-j = 'focus down'
alt-k = 'focus up'
alt-l = 'focus right'
# Move the focused window (two-up on the big screen).
alt-shift-h = 'move left'
alt-shift-j = 'move down'
alt-shift-k = 'move up'
alt-shift-l = 'move right'

[[on-window-detected]]
if.app-id = 'com.apple.systempreferences'
run = 'layout floating'
```
- Avoid macOS native (green-button) fullscreen; it fights tiling WMs.
- AeroSpace is pre-1.0; a `brew upgrade` can break config — pin or read release notes.
- Launcher: Spotlight (Cmd+Space) for the long tail; the `alt-` bindings for daily apps. Keep
  AeroSpace on Alt, Spotlight on Cmd+Space (no collision). `choose` is the dmenu primitive for
  scripts. (No good native dmenu exists; Spotlight is the lightest real option.)

Mail (Gmail in Apple Mail):
- Settings -> Internet Accounts -> Google -> sign in -> enable Mail. Gmail labels appear as
  mailboxes; threading/labels differ slightly from the web client.
- Mail -> Settings -> General -> set as default email reader.
- Core shortcuts: Cmd+N new, Cmd+R reply, Cmd+Shift+R reply-all, Cmd+Shift+F forward,
  Cmd+Shift+D send, Cmd+Shift+N get mail, Up/Down navigate the list, Space scroll, Cmd+1/2/3
  switch favorites/mailboxes.
- Honest gap: Apple Mail has NO Gmail-style single-key (j/k/e) navigation; it's arrow + Cmd. You
  can remap menu items via Settings -> Keyboard -> Keyboard Shortcuts -> App Shortcuts, but can't
  add single-key list nav. The win you're buying is the browser no longer capturing your keyboard.

## Phase 9 — macOS defaults (`macos/macos-defaults.sh`)

Beyond the key-repeat lines (Phase 7):
```sh
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
killall Finder
```
Keep extending so the machine stays reproducible.

## Verification checklist

- [ ] `./bootstrap.sh` runs clean on a fresh machine; re-running is a no-op.
- [ ] New terminal sources `.zshrc` (prompt, vi mode, aliases, `^L` clears in insert+command).
- [ ] `ls` colored; `grep --color` works; no startup errors.
- [ ] `stow` symlinks resolve; editing a repo dotfile reflects in `$HOME`.
- [ ] SSH to GitHub works without retyping passphrase (Keychain).
- [ ] Neovim launches with Nerd Font icons; `"+y` hits the system clipboard.
- [ ] `.tex` compiles via VimTeX; forward search works; inverse search jumps PDF->source.
- [ ] Finnish TeX layout selected; `$ \ { } ^ ~` at base/shift; `å ä ö` correct; `< > |` on the
      left-of-Z key; left-of-1 = å (the two ISO keys NOT swapped); Cmd+C/V work; Caps -> Esc.
- [ ] Holding j/k repeats; repeat speed fast.
- [ ] AeroSpace: alt-t/b/s/m jump to the right app on any monitor; alt-hjkl moves focus; two-up
      tiling works on the big screen; SIP still enabled.
- [ ] Gmail loads in Apple Mail; Mail is default reader; alt-m opens it.
