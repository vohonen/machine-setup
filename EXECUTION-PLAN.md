# macOS setup — execution plan (cold-start runbook)

**Read this first.** This is the actionable runbook. `macos-setup.md` (sibling file) is the
design/rationale doc by an earlier session; this file supersedes it where they differ and bakes in
everything a fresh session needs to build the repo end-to-end **without internet to re-derive
configs**. The four source repos were inspected on 2026-06-02 and the relevant contents are embedded
below verbatim, so you do NOT need to re-clone them to write the files (you DO need internet at
execution time for `brew bundle`, cloning `nvim-config`, and pushing to GitHub).

## Resolved decisions (from the user, do not re-ask)

- **Scope:** build it *in total* — create the full repo AND run the full install (incl. MacTeX and
  GUI casks). Hand off only the steps that physically require the user (password prompts,
  accessibility/Input-Source GUI toggles, GitHub key paste).
- **Git identity:** `user.name = "Vili Kohonen"`, `user.email = "vili.kohonen@protonmail.com"`.
  GitHub username is `vohonen` (handle plays on first/sur-name; the `k`/`v` difference is intentional,
  NOT a typo). Use the protonmail address for git config **and** the SSH key comment.
- **Font:** use **`font-jetbrains-mono-nerd-font`**, NOT `font-hack-nerd-font`. The Alacritty config
  hardcodes `JetBrainsMono Nerd Font`; Hack would break the terminal font + nvim-tree icons.
- **VimTeX viewer:** the shared `nvim-config` repo hardcodes `zathura`. Make it OS-conditional
  (sioyek on macOS, zathura on Linux) — see Phase 6 — so Linux keeps working.
- **Repo layout:** `machine-setup` is a **monorepo** holding shell/wm/keylayout/alacritty/sioyek
  configs, all stow-symlinked so editing a dotfile in `$HOME` edits the repo directly.
  **`nvim-config` stays its own repo, included as a git submodule** at `stow/common/.config/nvim`
  (keeps its standalone cross-platform use; one recursive clone brings it along). See the
  "Editing & syncing configs" section for the day-to-day loop.

## Machine state as of 2026-06-02 (verified)

- Apple Silicon (arm64), macOS 25.4. Homebrew already at `/opt/homebrew`, git + Xcode CLT present.
- **No** existing `~/.zshrc`, `~/.bashrc`, `~/.gitconfig`, `~/.config`, or `~/.ssh` — clean slate,
  nothing to clobber.
- All four source repos public + reachable: `vohonen/{ubuntu-setup,nvim-config,alacritty-config,zathurarc}`.
- `/Users/vili/machine-setup/` currently contains: `macos-setup.md`, `EXECUTION-PLAN.md` (this file),
  `Finnish-TeX.keylayout`, `gen_keylayout.py`. The last two were supplied by the user and are
  **consistent** (the .keylayout is the generator's output).

## Keylayout status + the one bug to fix

`Finnish-TeX.keylayout` and `gen_keylayout.py` are done and correct in content. **Only fix:** the
generator's final lines write to a hardcoded `/mnt/user-data/outputs/...` path. When folding into the
repo, change the tail to write beside the script:

```python
import os
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Finnish-TeX.keylayout')
with open(out, 'w', encoding='utf-8') as f:
    f.write(xml)
print("written", len(xml), "bytes ->", out)
```

The installer **copies** the existing `.keylayout` (does not regenerate), so this fix only matters if
the user edits the layout later. Both files move to `macos/` in the repo (see structure).

**On-device verification (the only uncertain parts of the layout):**
- Keycodes 50 (left-of-1 → `å`) and 10 (left-of-Z → `< > |`) may be swapped on UK Apple ISO. If `å`
  and the angle brackets land on the wrong keys, swap the `50:` and `10:` entries in
  `gen_keylayout.py`, rerun it, reinstall, log out/in.
- Confirm `$ \ { } ^ ~` at base/shift, `å ä ö` correct, Cmd+C/V work, Caps→Esc.

---

## Repo structure to build

```
machine-setup/
  bootstrap.sh                 # OS-detect → install/macos.sh | install/linux.sh
  Brewfile
  apt-packages.txt             # Ubuntu side (stub ok for now; macOS is the priority)
  install/
    macos.sh
    linux.sh                   # folds in ubuntu-setup; concise
  stow/
    common/
      .config/nvim/            # GIT SUBMODULE -> vohonen/nvim-config (stow symlinks it into ~/.config/nvim)
    macos/                     # .zshrc .zprofile .zsh_aliases .config/aerospace/aerospace.toml
                               #   .config/sioyek/prefs_user.config
    linux/                     # .bashrc .bash_aliases
  macos/
    Finnish-TeX.keylayout      # MOVE the existing file here
    gen_keylayout.py           # MOVE here, after fixing the output path
    macos-defaults.sh
  linux/
    fi                         # xkb layout (copy from ubuntu-setup)
    setup-keyboard.sh
  README.md
```

Note on nvim: `vohonen/nvim-config` is a **git submodule** at `stow/common/.config/nvim`. Stow
symlinks `~/.config/nvim` → that submodule dir; the submodule keeps its own remote so it stays usable
standalone on Ubuntu. Add it once with:
`git submodule add https://github.com/vohonen/nvim-config stow/common/.config/nvim`
(switch its remote to `git@github.com:...` after SSH is set up, so you can push edits — see Phase 6).
The installer runs `git submodule update --init --recursive` instead of a separate clone.

`gitconfig`: identity + aliases are written by the installer via `git config --global` (NOT stowed) —
see step 7. So `stow/common` contains only the nvim submodule.

---

## File contents to create (verbatim)

### `bootstrap.sh`
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

### `Brewfile`
```ruby
brew "neovim"
brew "git"
brew "coreutils"
brew "gnu-sed"
brew "stow"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "node"                       # nvim-treesitter / some LSPs need it (Ubuntu README installs node)
brew "tree-sitter"

cask "alacritty"
cask "aerospace"
cask "firefox"
cask "slack"
cask "proton-pass"
cask "sioyek"
cask "mactex"                     # ~5GB; needs sudo/GUI; this is the slow one
cask "font-jetbrains-mono-nerd-font"   # matches alacritty.toml (NOT font-hack)
# Optional (uncomment if wanted): cask "maccy"  (clipboard history)
# No karabiner: custom .keylayout + native Caps→Esc cover it.
```

### `install/macos.sh`
```sh
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
stow -d stow -t "$HOME" common macos

# 4. nvim config (submodule, symlinked by stow in step 3)
git submodule update --init --recursive

# 5. keyboard layout (copy — macOS wants a real file, not a symlink)
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
```

### `stow/macos/.zprofile`
```zsh
# login shell: set up Homebrew once
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### `stow/macos/.zshrc`  (translated from ubuntu-setup/.bashrc — NOT copied; Linux-only lines dropped)
```zsh
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY APPEND_HISTORY

# vi mode + C-l to clear in both insert and command mode (matches old `set -o vi` + bind C-l)
bindkey -v
bindkey -M viins '^L' clear-screen
bindkey -M vicmd '^L' clear-screen

# BSD ls colors (no GNU dircolors on macOS); keep grep color
export CLICOLOR=1
alias grep='grep --color=auto'

autoload -Uz compinit
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
compinit

export EDITOR=nvim
export TEXMFHOME=$HOME/.texmf

# green [user] blue cwd $  — same shape as the old bash PS1
PROMPT='%F{green}[%n]%f %F{blue}%~%f $ '

[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
```

### `stow/macos/.zsh_aliases`  (ported from .bash_aliases; `open` alias DROPPED — macOS has native `open`)
```zsh
# listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# dir movement
alias cd..='cd ..'
alias cdb='cd ..; cd ..'
mkcd () { mkdir -p -- "$1" && cd -P -- "$1"; }

# misc (note: NO `alias open='xdg-open'` — macOS `open` is native and wanted)
alias so='source'
alias fl='file `ls`'
alias dt='date +"%T"'
alias filecount='ls -l | grep -v ^d | grep -v ^t | grep -v ^l | wc -l'
```

### `stow/common/.gitconfig`
Either let `install/macos.sh` write it via `git config --global` (preferred — already in the script),
or stow a static file. If stowing, the identity + the four aliases (br/ci/co/st) above. Pick one to
avoid a stow-vs-`git config` conflict; the script approach is the default here, so **do not also stow
a .gitconfig** unless you remove the git-config block from the installer.

### `stow/macos/.config/aerospace/aerospace.toml`
```toml
start-at-login = true

[mode.main.binding]
alt-t = 'exec-and-forget open -a Alacritty'
alt-b = 'exec-and-forget open -a Firefox'
alt-s = 'exec-and-forget open -a Slack'
alt-m = 'exec-and-forget open -a Mail'

alt-h = 'focus left'
alt-j = 'focus down'
alt-k = 'focus up'
alt-l = 'focus right'

alt-shift-h = 'move left'
alt-shift-j = 'move down'
alt-shift-k = 'move up'
alt-shift-l = 'move right'

[[on-window-detected]]
if.app-id = 'com.apple.systempreferences'
run = 'layout floating'
```

### `stow/macos/.config/sioyek/prefs_user.config`
Port of the zathurarc intent (clipboard + half-page d/u + yellow highlight). **sioyek's config
syntax differs from zathura — verify keys on-device.** Starting point:
```
# half-page vertical movement (zathura had: map d scroll half-down / u scroll half-up)
move_screen_down d
move_screen_up u

# selection -> system clipboard
should_use_multiple_monitors 0
highlight_color 1.0 1.0 0.0
```
(If `move_screen_*` names are wrong on the installed sioyek version, check
`/opt/homebrew/share/sioyek/prefs.config` for the canonical command names.)

### `macos/macos-defaults.sh`
```sh
#!/usr/bin/env bash
set -euo pipefail

# key repeat — biggest vim QoL win
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
killall Finder || true
```

### `stow/linux/.bashrc` and `stow/linux/.bash_aliases`
Copy verbatim from `vohonen/ubuntu-setup` (they already work on Linux). `linux/fi` and
`linux/setup-keyboard.sh` + `dconf` are the Ubuntu keyboard side — copy `fi` from ubuntu-setup; the
setup-keyboard.sh does `sudo cp linux/fi /usr/share/X11/xkb/symbols/` and sets `caps:swapescape`.
Lower priority; macOS is the active target.

---

## Phase 4 — Git + SSH (manual bits)

`git config` identity/aliases are done by `install/macos.sh`. Remaining:
```sh
ssh-keygen -t ed25519 -C "vili.kohonen@protonmail.com"
# ~/.ssh/config:
#   Host github.com
#     AddKeysToAgent yes
#     UseKeychain yes
#     IdentityFile ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```
Then paste `~/.ssh/id_ed25519.pub` into GitHub → Settings → SSH keys. Verify: `ssh -T git@github.com`.

## Phase 6 — VimTeX viewer (the one upstream edit)

In `~/.config/nvim/lua/plugins/vimtex.lua` (which is the submodule), replace the hardcoded line
`vim.g.vimtex_view_method = "zathura"` with:
```lua
vim.g.vimtex_view_method = (vim.fn.has("mac") == 1) and "sioyek" or "zathura"
```
Because it's a submodule, push in two steps (requires SSH from Phase 4):
```sh
cd ~/machine-setup/stow/common/.config/nvim
git remote set-url origin git@github.com:vohonen/nvim-config   # one-time, enables push
git commit -am "vimtex: OS-conditional viewer (sioyek on mac)"; git push
cd ~/machine-setup
git commit -am "bump nvim-config submodule"; git push           # record the new pointer
``` The
latexmk compiler block already passes `-synctex=1`, so forward search should work; inverse search
(PDF→nvim) is the fiddly part — if it fails, set
`vim.g.vimtex_callback_progpath = "/opt/homebrew/bin/nvim"`; last resort
`vimtex_view_method = "skim"` (then `brew install --cask skim`). MacTeX puts binaries on
`/Library/TeX/texbin` — confirm `latexmk`/`tlmgr` are on PATH after install (a new login shell picks
it up).

---

## Execution order (cold start)

1. Move `Finnish-TeX.keylayout` + `gen_keylayout.py` into `macos/`; fix the generator output path.
2. Create every file above. `chmod +x bootstrap.sh install/*.sh macos/*.sh`.
3. `git init`, commit. (Repo is public-safe: no secrets committed; SSH keys are generated per-machine
   and git-ignored.)
4. Set up SSH → GitHub (Phase 4), then create `vohonen/machine-setup` on GitHub and push.
5. Add the nvim submodule:
   `git submodule add git@github.com:vohonen/nvim-config stow/common/.config/nvim`, commit, push.
6. Run `./bootstrap.sh`. Expect to enter the sudo password for MacTeX and approve GUI prompts.
7. Walk the manual steps the installer prints (Input Sources, Caps→Esc, AeroSpace accessibility,
   Mail account).
8. Apply the VimTeX edit (Phase 6) and push it through the submodule.
9. Run the verification checklist below.

> On any **future machine**: `git clone --recurse-submodules git@github.com:vohonen/machine-setup`
> then `./bootstrap.sh`. The `--recurse-submodules` flag is what pulls nvim-config too.

## Editing & syncing configs (the day-to-day loop)

Because stow symlinks the dotfiles, **editing the file in `$HOME` *is* editing the repo** — there's
no copy step. Normal flow:

```sh
# edit anything (e.g. ~/.zshrc, ~/.config/aerospace/aerospace.toml) in place, then:
cd ~/machine-setup && git commit -am "tweak zsh prompt" && git push
# on another machine:
cd ~/machine-setup && git pull        # symlinks already point here, so changes are instantly live
```

**nvim is the one exception** (it's a submodule with its own remote). Edit under
`~/.config/nvim/...`, then commit/push *inside* the submodule, then bump the pointer in the parent —
see the two-step block in Phase 6. To pull others' nvim changes on another machine:
`git -C ~/machine-setup submodule update --remote --merge`.

## Verification checklist

- [ ] New terminal: prompt + vi mode + aliases load; `^L` clears in insert & command mode; no startup errors.
- [ ] `ls` colored (CLICOLOR); `grep --color` works.
- [ ] `stow` symlinks resolve; editing a repo dotfile reflects in `$HOME`.
- [ ] `ssh -T git@github.com` succeeds without re-typing the passphrase (Keychain).
- [ ] nvim launches with Nerd Font icons; `"+y` reaches the system clipboard (pbcopy).
- [ ] `.tex` compiles via VimTeX; forward search opens sioyek at the spot; inverse search jumps back.
- [ ] Finnish TeX layout: `$ \ { } ^ ~` at base/shift; `å ä ö` right; `< > |` on left-of-Z; left-of-1 = å
      (ISO keys NOT swapped); Cmd+C/V work; Caps→Esc.
- [ ] Holding j/k repeats fast.
- [ ] AeroSpace: alt-t/b/s/m jump to the right app on any monitor; alt-hjkl moves focus; SIP still on.
- [ ] Gmail loads in Apple Mail; Mail is default reader; alt-m opens it.

## Open items / risks to keep in mind

- AeroSpace is pre-1.0; a `brew upgrade` can break the config — read release notes / pin if it breaks.
- sioyek inverse search on macOS is the most likely thing to need fiddling (skim fallback exists).
- The two ISO keycodes (50/10) are the most likely layout bug; fix is a one-line swap + regen.
- `node`/`tree-sitter` added to the Brewfile to match the nvim-config Ubuntu README's needs; drop if
  Mason/treesitter install cleanly without them.
```
