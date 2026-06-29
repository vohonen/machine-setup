# Keymap cheat sheet

Quick reference for the macOS setup: AeroSpace, the keyboard layer (Karabiner + Finnish TeX),
and how the system clipboard flows through Neovim. Source of truth is always the config files —
this file just summarizes them:

- `stow/macos/.config/aerospace/aerospace.toml`
- `stow/macos/.config/karabiner/karabiner.json`
- `macos/gen_keylayout.py` (→ `Finnish-TeX.keylayout`)
- `stow/common/.config/nvim/lua/{options,keymaps}.lua`

The modifier philosophy: **Cmd = macOS GUI layer · Alt/Option = AeroSpace · Ctrl = inside the
terminal (nvim, shell, fzf, …) · Ctrl+Alt = system escape hatches (menu bar)**.

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
| `Alt+E` | Mail (E-mail) | 4 |
| `Alt+M` | Spotify (Music) | 5 |

### Navigation

| Key | Action |
|---|---|
| `Alt+H/J/K/L` | focus window left / down / up / right (within the workspace) |
| `Alt+Shift+H/J/K/L` | drag the focused window in that direction |
| `Alt+1…7` | go to workspace N (only 7 workspaces — `Alt+8/9/0` are free for typing `[ ] { }`) |
| `Alt+Shift+1…7` | throw the focused window to workspace N |
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

### Service mode

Enter with `Alt+Shift+S`, press one key, auto-returns to main mode:

| Key | Action |
|---|---|
| `Esc` | reload AeroSpace config |
| `R` | flatten the workspace tree (**r**eset a messy layout) |
| `B` | **b**alance / equalize all window sizes (moved off `Alt+0`) |
| `F` | float ↔ tiled toggle |
| `Backspace` | close every window except the current one |
| `H/J/K/L` | merge focused window into the neighbor's container |

### Recipe — three terminals: swap the ends, then stack two on the left

Starting point: three terminals `A B C` (left → right), e.g. in a horizontal accordion.
Goal: swap A and C, then put C and B stacked vertically in the left half with A taking the
full-height right pane.

```
Alt+V              # accordion → tiles, so all three are visible side by side
Alt+H (repeat)     # focus the leftmost terminal (A)
Alt+Shift+L ×2     # carry A past the center to the far right     → B C A
Alt+H              # focus the center window (C, the old rightmost)
Alt+Shift+H       # push C to the far left                        → C B A   (swap done)
Alt+L              # focus the center window (B)
Alt+Shift+S, H     # service mode: join-with left → C and B stack vertically
                   # in the left half; A grows to the full right half
Alt+Shift+S, B     # (optional) equalize sizes (service mode)
```

Why it works: `move` (`Alt+Shift+H/L`) *swaps* the window with its neighbor, so two hops
carry it across the row. `join-with` creates a nested container, and AeroSpace forces nested
containers to the **opposite orientation** of their parent (default normalization) — joining
two side-by-side windows therefore stacks them. If the pair ends up as an accordion instead
of a visible stack, focus one of them and hit `Alt+V`. To undo the nesting: `Alt+Shift+S`,
`R` (flatten).

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
Alt+Shift+7        # throw it to ws 7
Alt+7              # follow it
Alt+Shift+.        # if ws 7 isn't on monitor B yet, send the workspace there
```

Then `Alt+1` = terminal on A, `Alt+7` = terminal on B, `Alt+Tab` bounces between them.

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

Brackets sit on four adjacent number-row keys via Option:
**`⌥8 ⌥9 ⌥0 ⌥+` = `[ ] { }`** — that's why AeroSpace uses only 7 workspaces, so `Alt+8/9/0`
stay free for typing.

| Key | Plain | Shift | Option |
|---|---|---|---|
| left of `1` | `@` | `Å` | `å` |
| `8` / `9` | `8` / `9` | `(` / `)` | `[` / `]` |
| `0` | `0` | `=` | `{` |
| `+`/`?` key (right of 0) | `+` | `?` | `}` |
| key right of that (`´`) | `{` | `}` | `` ` `` |
| right of `P` | `$` | `<` | `>` |
| key right of that | `\` | `^` | `~` |
| left of `Z` | `<` | `>` | `\|` |

`{`/`}` are also still reachable on `Alt+7` and the `´` key (plain/shift); `\` lives plain on
the key right of the `P`-row. `@` was moved to a plain keypress because AeroSpace's `Alt+2`
shadows the standard Finnish `Option+2`.

**Changing the layout is the canonical way to remap keys — keep Karabiner minimal.** The
`.keylayout` is *generated*, so edit the `M` dict in `macos/gen_keylayout.py` (do **not**
hand-edit `Finnish-TeX.keylayout`), then:

```shell
python3 macos/gen_keylayout.py
cp macos/Finnish-TeX.keylayout ~/"Library/Keyboard Layouts/"
# then log out and back in (macOS caches layouts at login;
# re-adding the input source in System Settings also forces a reload)
```

Watch for AeroSpace `Alt+<key>` bindings that would capture an `Option+key` combo before the
layout can emit the character — that's why `balance-sizes` moved off `Alt+0` to service-mode
`B` when `⌥0` became `{`. The login screen loads layouts only after login, so the password
field uses plain Finnish.

---

## Menu bar (auto-hidden behind sketchybar)

The native macOS menu bar is auto-hidden; sketchybar is the everyday bar (workspaces +
focused app on the left; keyboard layout / Wi-Fi / volume / battery / clock on the right).
Three ways into the real menu bar when you need an app's menus:

| Gesture | Action |
|---|---|
| `Ctrl+Alt+M` (= `Caps+Alt+M`) | reveal + focus the **m**enu bar — arrows/letters navigate, `Enter` runs, `Esc` (tap `Caps`) returns to your window |
| `Ctrl+Alt+H` (= `Caps+Alt+H`) | **H**elp-menu search — fuzzy-find and run *any* menu item of the focused app |
| mouse to the top edge | the menu bar slides over sketchybar; moves away when you leave |

`Ctrl+Alt+M` is symbolic hotkey 7 in `macos/macos-defaults.sh` (the `Ctrl+F2` default is
fine but this is comfier). `Ctrl+Alt+H` is an AeroSpace binding that AppleScript-clicks the
real Help menu — the native "Show Help menu" hotkey is dispatched to the frontmost app and
races the auto-hide reveal animation (worked ~1 in 10), so it's disabled (hotkey 98).

Clicking the front-app item in sketchybar also triggers the `Ctrl+Alt+M` path (needs
Accessibility permission for sketchybar). Homerow can't see sketchybar items (they expose no
accessibility elements) — but once the menu bar is revealed, Homerow works on it normally.

---

## Power (sleep / shut down)

Touch ID MacBooks have no working `Ctrl+Power` dialog (those combos need a real power/eject
key), so a Karabiner binding recreates it:

| Gesture | Action |
|---|---|
| `Ctrl+Alt+P` (= `Caps+Alt+P`) | **P**ower chooser list — Sleep / Restart / Shut Down: `↑/↓` select, `Enter` runs, `Esc` cancels. Sleep is the default, so `Enter` alone = instant break |

The chooser lives in `stow/macos/.config/karabiner/power-chooser.applescript`. Restart and
Shut Down are graceful (apps get asked to quit; only unsaved work prompts). Sleep is full
system sleep — monitors go black; any key wakes.

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
