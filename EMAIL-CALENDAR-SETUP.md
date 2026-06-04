# Email + calendar consolidation — runbook

Decision (2026-06-04): the **work Google account** (`vili.kohonen@longtermrisk.org`, paid
Workspace) becomes the single calendar source of truth. Proton Calendar retires — its only
"dynamic" export path (share-via-link) needs a paid plan AND Google only re-fetches external
ICS feeds every ~8–24 h, which is too stale to drive a booking link. Proton Mail (free plan)
stays in the Proton web/desktop app; Apple Mail would need Bridge = paid plan ($3.99/mo annual,
revisit only if two mail apps gets annoying — then also add `cask "protonmail-bridge"`).

Everything below is GUI work — do it in order, tick as you go.

---

## Phase 1 — Migrate off Proton Calendar (one-time)

- [ ] **Stop adding events in Proton NOW.** The export is a snapshot; anything added after
      won't come along.
- [ ] [calendar.proton.me](https://calendar.proton.me) → hover your calendar in the sidebar →
      **⋮ → Export** (or Settings → Calendars → Export). Save the `.ics`.

## Phase 2 — Work Google Calendar

- [ ] [calendar.google.com](https://calendar.google.com) (work account) → gear → **Settings →
      Add calendar → Create new calendar** → name **"Personal"**. Give it a distinct color.
- [ ] **Settings → Import & export → Import** → the `.ics` → destination: **Personal**.
- [ ] **Spot-check the import** before trusting it: recurring events, all-day events, and one
      event on each side of a DST switch (ICS timezone handling is the usual casualty).
- [ ] **Notifications don't carry over from Proton.** Settings → Personal →
      "Event notifications" → set your default reminder(s).
- [ ] Optional sharing: Personal is **private to you by default**. If colleagues should see
      details (you said fine): Settings → Personal → "Share with specific people or groups".

## Phase 3 — Booking link

- [ ] Calendar grid → **Create → Appointment schedule** → title, meeting length, bookable
      windows. Note: the schedule lives on the **primary** calendar; bookings land there too
      (can't host it on Personal).
- [ ] In the schedule editor → **Calendars → "Check calendars for availability"** → tick
      **primary + Personal**. This is the whole point — don't skip it.
- [ ] Save → **Share → copy booking link** → email signature / Slack profile.
- [ ] **Test from a private browser window** (as an outsider). If external people can't book,
      a Workspace admin needs to loosen Calendar external-sharing settings — small org, quick fix.

## Phase 4 — Mac

- [ ] **System Settings → Internet Accounts → Google** → sign in with the work account →
      enable **Mail + Calendars** (+ Contacts for autocomplete). First mail sync takes a while.
- [ ] **Apple Calendar → Settings → General → Default Calendar → Personal** (hand-created
      events are usually personal; work meetings arrive as invites onto the primary anyway).
- [ ] **Apple Mail → Settings → General** → default email reader = Mail.

## Phase 5 — Phone

- [ ] Install the **Google Calendar app**, sign in with the work account. Toggle **Personal**
      on in the app's calendar list (Android: also Settings → Personal → Sync). One app to
      glance at, both calendars, native appointment-schedule support.

## Phase 6 — Decommission Proton Calendar

- [ ] After the import is verified: delete the calendar in Proton (or leave as dead archive).

---

## Gotchas to remember (beyond the happy path)

1. **Invites always land on the work primary — accepted as fine (decided 2026-06-04).**
   Google routes invites by address; there's no way to make them land on the Personal calendar,
   so the work/personal toggle only separates self-created events. Few invites → not worth
   fixing (the real fix would be a separate personal Gmail; skipped). Optional, energy
   permitting: right-click a personal invite → recolor it to the Personal color.
2. **The Proton invite trap.** Friends who invite `vili.kohonen@protonmail.com` to events send
   the invite to Proton — it lands in Proton Mail/Calendar, NOT Google, and free Proton has no
   auto-forwarding. Give people the **work address** for invites instead; if one slips into
   Proton, manually re-create it on the Google side.
3. **The calendar dropdown is the only failure mode.** Every event dialog (Mac, phone, web) has
   a calendar selector — a personal event accidentally created elsewhere, or a work event on
   Personal, is the one thing this setup can't self-correct. Glance at it when creating events.
4. **Google account re-auth.** macOS Internet Accounts occasionally drops Google auth (password
   change, security event) — Mail/Calendar silently stop syncing. If things look stale, check
   System Settings → Internet Accounts first.
5. **Homerow check at next login** (unrelated, from the same session): no window should appear —
   it now launches via `~/Library/LaunchAgents/com.vili.homerow.plist` (`open -gj`), the Login
   Item is gone. If a window still shows, turn OFF "Launch at login" inside Homerow's own
   settings (it would be double-launching).

## Repo state (commit when happy)

Uncommitted from this session: `Brewfile` (homerow + spotify casks),
`install/macos.sh` (manual-steps notes), `stow/macos/Library/LaunchAgents/com.vili.homerow.plist`.
Plus pre-existing dirty files (`Finnish-TeX.keylayout`, `gen_keylayout.py`, `karabiner.json`,
`nvim-tests/`, alacritty `.bak`).
