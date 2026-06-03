# Finish the macOS setup — your remaining steps

Run these from a **fresh, normal terminal** (not inside Claude). Everything that didn't need your
password / GitHub / a GUI is already done; this is the rest. Do them roughly in order.

---

## 1. SSH key → GitHub

`~/.ssh/config` is already written. Generate the key (you'll be prompted for a passphrase — pick one;
it gets stored in Keychain so you never retype it):

```sh
ssh-keygen -t ed25519 -C "vili.kohonen@protonmail.com" -f ~/.ssh/id_ed25519
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub        # public key now on your clipboard
```

Paste it into GitHub → **Settings → SSH and GPG keys → New SSH key**. Then verify:

```sh
ssh -T git@github.com                 # expect: "Hi vohonen! You've successfully authenticated..."
```

---

## 2. Push the repo to GitHub

⚠️ **Order matters, and don't run `./bootstrap.sh` or `git submodule update` before finishing 2a+2b.**
The nvim-config fixes (Skim viewer + treesitter migration) are in a **local-only** submodule commit
(`80fd05a`); the parent still points at the old upstream commit. Pushing the submodule first, then
bumping the pointer, is what makes them permanent. A premature `submodule update` would discard them.

First create an **empty** repo `vohonen/machine-setup` on github.com (no README, no .gitignore).
Then:

```sh
# a) push the nvim-config fixes to their own remote
cd ~/machine-setup/stow/common/.config/nvim
git remote set-url origin git@github.com:vohonen/nvim-config.git
git push origin master                # pushes 80fd05a (Skim viewer + treesitter main migration)

# b) record the new submodule pointer in the parent repo
cd ~/machine-setup
git add stow/common/.config/nvim
git commit -m "bump nvim-config: skim viewer + treesitter main migration"

# c) push the parent repo
git remote add origin git@github.com:vohonen/machine-setup.git
git push -u origin main
```

(Optional: to push nvim edits straight from future fresh clones, change the submodule URL in
`.gitmodules` from `https://` to `git@github.com:vohonen/nvim-config.git` and commit it.)

---

## 3. MacTeX (~5 GB, needs your password)

The only Brewfile package not yet installed:

```sh
brew install --cask mactex
```

After it finishes, open a new shell and confirm the binaries are on PATH:

```sh
which latexmk tlmgr        # should resolve under /Library/TeX/texbin
```

---

## 4. System Settings toggles (GUI — can't be scripted)

- **Keyboard → Input Sources:** add **Finnish TeX**, set it primary → **log out and back in**.
- **Keyboard → Keyboard Shortcuts → Modifier Keys:** Caps Lock → **Escape**.
- **AeroSpace:** launch it once and grant **Accessibility** permission when prompted.
- **Skim → Settings → Sync** (for VimTeX inverse search, PDF→source):
  - enable **"Check for file changes"**
  - **Preset:** Custom
  - **Command:** `nvim`
  - **Arguments:** `--headless -c "VimtexInverseSearch %line '%file'"`
  - (Forward search, source→PDF, needs no config — VimTeX calls Skim's `displayline`.)
- **Internet Accounts → Google:** sign in, enable **Mail**. Then **Mail → Settings → General →**
  set as default email reader.

---

## 5. Verify the keyboard layout on-device

This is the one genuinely uncertain part of the custom layout. With **Finnish TeX** active, check:

- `$ \ { } ^ ~` at base/shift; `å ä ö` correct; `< > |` on the key **left of Z**;
  `å` on the key **left of 1**; Cmd+C / Cmd+V work; Caps Lock acts as Escape.
- Hold `j`/`k` — repeat should be fast.

**If `å` and the angle brackets are on the wrong keys** (the two ISO keycodes are the likely bug):

```sh
# swap the `50:` and `10:` entries in macos/gen_keylayout.py, then:
python3 ~/machine-setup/macos/gen_keylayout.py
cp ~/machine-setup/macos/Finnish-TeX.keylayout ~/Library/Keyboard\ Layouts/
# log out and back in
```

---

## Already handled (FYI / if you hit it again)

- **Alacritty "cannot verify" Gatekeeper block** — fixed by clearing the quarantine flag
  (`xattr -dr com.apple.quarantine /Applications/Alacritty.app`); the installer now does this
  automatically. If any *other* app shows the same dialog, run the same command on its `.app`.
- Old `~/.zprofile` backed up to `~/.zprofile.pre-stow`.
