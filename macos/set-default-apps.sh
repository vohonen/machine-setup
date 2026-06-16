#!/usr/bin/env bash
set -euo pipefail

# Default app associations on macOS (LaunchServices), set via `duti`.
#   - PDF        -> Skim   (same viewer VimTeX drives; SyncTeX-aware)
#   - text/code  -> Neovim (via a generated wrapper app that opens nvim in Alacritty)
#
# Neovim is a terminal program, so Finder can't hand it a file directly. We build a
# minimal AppleScript "open" app that forwards the file path to Alacritty -e nvim.
# Re-runnable: the wrapper app is rebuilt from scratch each time.

ALACRITTY_APP="/Applications/Alacritty.app"
NVIM="$(command -v nvim || echo /opt/homebrew/bin/nvim)"
SKIM_ID="net.sourceforge.skim-app.skim"

APP_DIR="$HOME/Applications"
APP="$APP_DIR/Open in Neovim.app"
APP_ID="local.open-in-neovim"

command -v duti >/dev/null || brew install duti

# --- build the wrapper app ---------------------------------------------------
mkdir -p "$APP_DIR"
rm -rf "$APP"

TMP_SCPT="$(mktemp -t open-in-neovim)"
mv "$TMP_SCPT" "$TMP_SCPT.applescript"
TMP_SCPT="$TMP_SCPT.applescript"
cat > "$TMP_SCPT" <<EOF
on open theFiles
	repeat with f in theFiles
		set p to quoted form of POSIX path of f
		do shell script "open -n -a '$ALACRITTY_APP' --args -e $NVIM " & p
	end repeat
end open

on run
	do shell script "open -n -a '$ALACRITTY_APP' --args -e $NVIM"
end run
EOF

osacompile -o "$APP" "$TMP_SCPT"
rm -f "$TMP_SCPT"

PLIST="$APP/Contents/Info.plist"
plist_set() {  # key, value — set if present, else add
  /usr/libexec/PlistBuddy -c "Set :$1 $2" "$PLIST" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Add :$1 string $2" "$PLIST"
}
plist_set CFBundleIdentifier "$APP_ID"
plist_set CFBundleName "Open in Neovim"

# Extensions to route to Neovim. Many of these (.lua, .toml, dotfiles, ...) have no
# app claiming them, so macOS gives them an ephemeral "dynamic" UTI that duti CANNOT
# bind to (error -50). The robust fix is for THIS app to claim the extensions in its
# Info.plist: LaunchServices then mints a real, app-owned type and makes us the
# default for anything no other app already claims.
EXTS=(
  txt text log md markdown rst org tex bib cls sty
  sh bash zsh fish py rb pl php lua vim
  js mjs cjs ts jsx tsx json jsonc
  c h cc cpp cxx hpp hh m mm rs go java kt swift
  html htm css scss sass
  yml yaml toml ini cfg conf env
  csv tsv sql diff patch gitignore gitconfig editorconfig
)

# Declare two document types: one by parent UTI (covers conforming descendants),
# one by extension (covers the dynamic-UTI formats above). Both as "Editor".
/usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes array" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0 dict" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes array" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:0 string public.text" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:1 string public.source-code" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:1 dict" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:1:CFBundleTypeRole string Editor" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:1:CFBundleTypeExtensions array" "$PLIST"
i=0; for e in "${EXTS[@]}"; do
  /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:1:CFBundleTypeExtensions:$i string $e" "$PLIST"
  i=$((i+1))
done

# Register the freshly built app (with its claimed types) with LaunchServices.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -f "$APP"

# --- associations ------------------------------------------------------------
# PDF -> Skim
duti -s "$SKIM_ID" com.adobe.pdf all

# text / markdown / code -> Neovim wrapper, by UTI. Parent UTIs (public.text,
# public.source-code) cover conforming descendants; the named ones pin formats that
# another app may otherwise claim as default.
UTIS=(
  public.plain-text public.text public.utf8-plain-text public.utf16-plain-text
  public.source-code public.script public.shell-script public.json public.xml
  public.yaml public.make-source public.assembly-source
  net.daringfireball.markdown
  com.netscape.javascript-source public.python-script public.ruby-script
  public.perl-script public.php-script public.c-source public.c-header
  public.c-plus-plus-source public.objective-c-source com.sun.java-source
  com.apple.applescript.text public.log
)
for u in "${UTIS[@]}"; do
  duti -s "$APP_ID" "$u" all 2>/dev/null || true
done

echo "Defaults set:"
echo "  PDF            -> Skim"
echo "  text/md/code   -> Open in Neovim ($APP)"
