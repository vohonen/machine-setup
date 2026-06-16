brew "neovim"
brew "git"
brew "coreutils"
brew "gnu-sed"
brew "stow"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "duti"                       # set default apps per filetype (PDF->Skim, text/code->nvim)
brew "node"                       # nvim-treesitter / some LSPs need it (Ubuntu README installs node)
brew "tree-sitter-cli"            # nvim-treesitter `main` builds parsers via the tree-sitter CLI
                                  # (the `tree-sitter` lib formula no longer ships the binary)

tap "nikitabobko/tap"             # AeroSpace lives in this tap, not homebrew/cask
tap "FelixKratz/formulae"         # sketchybar
brew "sketchybar"                 # status bar: AeroSpace workspace overview (config stowed)
cask "font-sketchybar-app-font"   # app-icon ligatures used in the workspace pills
cask "alacritty"
cask "aerospace"
cask "firefox"
cask "slack"
cask "spotify"
cask "proton-pass"
cask "skim"                       # VimTeX PDF viewer; native arm64 w/ SyncTeX (sioyek is deprecated + Intel-only)
cask "mactex"                     # ~5GB; needs sudo/GUI; this is the slow one
cask "font-jetbrains-mono-nerd-font"   # matches alacritty.toml (NOT font-hack)
cask "karabiner-elements"          # Caps Lock = Esc on tap / Ctrl on hold (config stowed; needs GUI permission grants)
cask "homerow"                     # keyboard "cursor"; its own "Launch at login" setting starts it headless (LaunchAgent hack retired to legacy/)
# Optional (uncomment if wanted): cask "maccy"  (clipboard history)
