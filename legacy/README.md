# Legacy — retired config, kept just in case

Things that were built, then turned out to be unnecessary. Not stowed, not installed
by any script. Each entry says why it existed and why it was retired, so it can be
revived if the original problem ever comes back.

## com.vili.homerow.plist

LaunchAgent that launched Homerow at login and force-hid its settings window via
System Events (Homerow ignores `open -j`). Built because Homerow appeared to open
its window on every login when started as a Login Item.

Retired 2026-06-05: Homerow's own **Launch at login** setting (the
`com.superultra.HomerowLauncher` helper) starts it in the background with no window —
the original window-on-login was a one-off, likely first-run behavior. Keybindings
work without ever opening the app.

To revive: symlink (or copy) into `~/Library/LaunchAgents/`, log out/in, and turn
OFF "Launch at login" inside Homerow so they don't double-launch. First login shows
a one-time "wants to control System Events" prompt — click Allow.
