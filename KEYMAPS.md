# Keymap cheat sheet

Quick reference for the macOS setup: AeroSpace, the keyboard layer (Karabiner + Finnish TeX),
and how the system clipboard flows through Neovim. Source of truth is always the config files —
this file just summarizes them:

- `stow/macos/.config/aerospace/aerospace.toml`
- `stow/macos/.config/karabiner/karabiner.json`
- `macos/gen_keylayout.py` (→ `Finnish-TeX.keylayout`)
- `stow/common/.config/nvim/lua/{options,keymaps}.lua`

The modifier philosophy: **Cmd = macOS GUI layer · Alt/Option = AeroSpace · Ctrl = inside the
terminal (nvim, shell, fzf, …)**.

---

## AeroSpace

### Apps — launch *or* jump-to

If the app is already running, these focus it, which warps you to its home workspace.
New windows of these apps always teleport to their home workspace (`on-window-detected` rules).

| Key | App | Home workspace |
|---|---|---|
| `Alt+T` | Alacritty (Terminal) | 1 |
| `Alt+B` | Firefox (Browser) | 2 |
| `Alt+S` | Slack | 3 |
| `Alt+M` | Mail | 4 |

### Navigation

| Key | Action |
|---|---|
| `Alt+H/J/K/L` | focus window left / down / up / right (within the workspace) |
| `Alt+Shift+H/J/K/L` | drag the focused window in that direction |
| `Alt+1…5` | go to workspace N (wherever it currently lives) |
| `Alt+Shift+1…5` | throw the focused window to workspace N |
| `Alt+Tab` | bounce between the last two workspaces (editor ↔ browser toggle) |
| `Alt+Shift+.` / `Alt+Shift+,` | move the **whole current workspace** to the next / prev monitor |

### Layout & resize

| Key | Action |
|---|---|
| `Alt+V` | flip split orientation (**V**ary) |
| `Alt+A` | **A**ccordion layout (stacked; great for many terminals) |
| `Alt+F` | **F**ullscreen the focused window |
| `Alt+Shift+Space` | toggle float ↔ tiled |
| `Alt+,` / `Alt+.` | shrink / grow the focused window |
| `Alt+0` | equalize all window sizes |

### Service mode

Enter with `Alt+Shift+S`, press one key, auto-returns to main mode:

| Key | Action |
|---|---|
| `Esc` | reload AeroSpace config |
| `R` | flatten the workspace tree (**r**eset a messy layout) |
| `F` | float ↔ tiled toggle |
| `Backspace` | close every window except the current one |
| `H/J/K/L` | merge focused window into the neighbor's container |

### The daily loop

`Alt+T` → work → `Alt+B` to look something up → `Alt+Tab` back.

### Multiple monitors — mental model

Three facts make it click:

1. **A workspace lives on exactly one monitor at a time** (so one workspace can't span two
   screens).
2. **The app→workspace rules are not a leash.** They fire *once, at window creation*. After
   that the window is free: `Alt+Shift+N` moves it anywhere and it stays.
3. Every monitor always shows *some* workspace; `Alt+N` jumps to wherever workspace N
   currently is.

Recipe — a terminal on each external monitor:

```
Alt+T              # new terminal → lands on ws 1 (monitor A)
Alt+T              # second terminal → also ws 1
Alt+Shift+5        # throw it to ws 5
Alt+5              # follow it
Alt+Shift+.        # if ws 5 isn't on monitor B yet, send the workspace there
```

Then `Alt+1` = terminal on A, `Alt+5` = terminal on B, `Alt+Tab` bounces between them.

---

## Keyboard layer

### Caps Lock (Karabiner-Elements)

| Gesture | Acts as |
|---|---|
| tap Caps Lock | `Escape` |
| hold Caps Lock + key | `Ctrl` + key (home-row Ctrl — use this for all left-hand Ctrl chords) |

Karabiner must be running (it starts at login). Config is the stowed
`~/.config/karabiner` directory symlink.

### Finnish TeX layout — the moved keys

| Key | Plain | Shift | Option |
|---|---|---|---|
| left of `1` | `@` | `Å` | `å` |
| `+`/`?` key (right of 0) | `+` | `?` | `\` |
| key right of that | `{` | `}` | `` ` `` |
| right of `P` | `$` | `<` | `>` |
| key right of that | `\` | `^` | `~` |
| left of `Z` | `<` | `>` | `\|` |

`@` was moved to a plain keypress because AeroSpace's `Alt+2` shadows the standard Finnish
`Option+2`. To change the layout: edit `macos/gen_keylayout.py`, run it, copy the result to
`~/Library/Keyboard Layouts/`, log out and back in.

The login screen loads layouts only after login → the password field uses plain Finnish.

---

## Clipboard ↔ Neovim

`clipboard=unnamedplus` is set, so **plain `y` / `d` / `p` are the system clipboard** — no
special chords.

| Flow | Keys |
|---|---|
| nvim → other app | `yy` (or visual + `y`), then `Cmd+V` in the app |
| other app → nvim | `Cmd+C` in the app, then `p` in nvim |
| a delete clobbered your yank | the previous yank is still in register `0`: paste with `"0p` |

On Linux the same config works via `xclip` / `wl-clipboard` (in `apt-packages.txt`).
