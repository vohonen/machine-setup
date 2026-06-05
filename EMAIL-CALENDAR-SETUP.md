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

- [x] **Stop adding events in Proton NOW.**
- [x] ~~Export the `.ics`~~ **Dead end (2026-06-05): export is paywalled now too** — calendar
      settings only show a paid "share calendar" upsell, no export. Decision: skip the bulk
      import; **manually re-create the important events** on the Google side one-by-one
      (makes the Phase 2 import + spot-check steps N/A).

## Phase 2 — Work Google Calendar

- [x] [calendar.google.com](https://calendar.google.com) (work account) → gear → **Settings →
      Add calendar → Create new calendar** → name **"Personal"**. Give it a distinct color.
      *(Done 2026-06-05 — confirmed synced to the Mac.)*
- [x] ~~Import the `.ics`~~ N/A — no Proton export (see Phase 1). Re-create important events
      manually instead; **ongoing** until the backlog is in.
- [x] **Notifications don't carry over from Proton.** Settings → Personal →
      "Event notifications" → set your default reminder(s). *(Done 2026-06-05: 30 min prior.)*
- [x] Sharing (decided 2026-06-05): personal events must **block availability** for colleagues —
      secondary calendars are invisible to "Find a time" until shared. Settings → Personal →
      "Access permissions for events" → made available for the org as **"See only free/busy
      (hide details)"**. *(Done 2026-06-05.)*

## Phase 3 — Booking link

- [x] Calendar grid → **Create → Appointment schedule** → title, meeting length, bookable
      windows. Note: the schedule lives on the **primary** calendar; bookings land there too
      (can't host it on Personal). *(Done 2026-06-05.)*
- [x] In the schedule editor → **Calendars → "Check calendars for availability"** → tick
      **primary + Personal**. This is the whole point — don't skip it. *(Done 2026-06-05.)*
- [ ] Save → **Share → copy booking link** → email signature / Slack profile.
- [x] **Test from a private browser window** (as an outsider). *(Done 2026-06-05 — works,
      external booking confirmed.)*

## Phase 4 — Mac

- [x] **System Settings → Internet Accounts → Google** → sign in with the work account →
      enable **Mail + Calendars** (+ Contacts for autocomplete). First mail sync takes a while.
      (Decided 2026-06-05: work mail reads in **Apple Mail**, retiring web Gmail — it hijacks
      the keyboard. Proton mail stays in the Proton app; two mail apps is the accepted cost.)
      *(Signed in 2026-06-05; gotcha: the **Mail toggle was off** on first sign-in — Calendars
      synced, Mail didn't. If Mail looks empty, check this toggle first.)*
- [x] ~~Apple Calendar default calendar → Personal~~ **Decision reversed (2026-06-05): Mac
      keeps the work primary as default** — most events created on the Mac are meeting
      bookings. The phone gets Personal as default instead (see Phase 5); per-device defaults
      match where each kind of event is typically created.
- [x] **Apple Mail → Settings → General** → default email reader = Mail. *(Verified 2026-06-05:
      `mailto:` already resolves to Mail.app — nothing to change.)*

## Phase 5 — Phone

- [ ] Install the **Google Calendar app**, sign in with the work account. Toggle **Personal**
      on in the app's calendar list (Android: also Settings → Personal → Sync). One app to
      glance at, both calendars, native appointment-schedule support.
- [ ] **No Gmail app on the phone** (off-work protection, decided 2026-06-05). Invites land on
      the calendar directly — view and accept/decline inside the Calendar app; the inbox never
      needs opening on the phone.
- [ ] **Google Calendar app → Settings → General → Default calendar → Personal** (decided
      2026-06-05: phone defaults to Personal, Mac defaults to work primary — each device
      defaults to the kind of event typically created there).

## Phase 6 — Decommission Proton Calendar

- [ ] After the import is verified: delete the calendar in Proton (or leave as dead archive).

---

## Gotchas to remember (beyond the happy path)

1. **Invites always land on the work primary — accepted as fine (decided 2026-06-04).**
   Google routes invites by address; there's no way to make them land on the Personal calendar,
   so the work/personal toggle only separates self-created events. Few invites → not worth
   fixing (the real fix would be a separate personal Gmail; skipped). Optional, energy
   permitting: right-click a personal invite → recolor it to the Personal color.
2. **The Proton invite trap — resolved workflow (2026-06-05).** Friends who invite
   `vili.kohonen@protonmail.com` send the invite to Proton — it lands there, NOT Google, and
   free Proton has no auto-forwarding. Fix: **forward the invite email to the work address and
   accept from there** — works whenever the organizer left "guests can invite others" on
   (Google's default). If a rare event has it off, re-create manually on the Google side
   (~30 s). Give people the work address for invites where natural.
3. **The calendar dropdown is the only failure mode.** Every event dialog (Mac, phone, web) has
   a calendar selector — a personal event accidentally created elsewhere, or a work event on
   Personal, is the one thing this setup can't self-correct. Glance at it when creating events.
4. **Google account re-auth.** macOS Internet Accounts occasionally drops Google auth (password
   change, security event) — Mail/Calendar silently stop syncing. If things look stale, check
   System Settings → Internet Accounts first.
5. **Homerow check at next login** (unrelated, from the same session): resolved 2026-06-05 —
   Homerow's own "Launch at login" setting starts it headless, no window. The LaunchAgent
   workaround was unnecessary and is retired to `legacy/com.vili.homerow.plist`.
6. **AeroSpace auto-floated Mail + Calendar at first launch** (2026-06-05). Windows opened
   mid-account-setup looked like dialogs, so AeroSpace floated them — and layout commands
   (alt-a accordion) silently no-op on floating windows; keybindings give no error. Diagnose
   from the CLI (`aerospace layout ... --window-id N` → "The window is non-tiling"), fix with
   `aerospace layout tiling --window-id N`, then flatten + re-apply layout. One-time event per
   app; intentionally NOT forcing tiling in on-window-detected (it would tile compose windows
   and settings panels too).

## Repo state

2026-06-04 session files all committed. 2026-06-05 session (this doc + aerospace.toml:
Calendar→ws4 pin, alt-c launcher) committed same day. Still untracked and unrelated:
`nvim-tests/`.

## Remaining (all deferred by choice, no date pressure)

- Re-create important Proton events by hand on the Personal calendar (export was paywalled).
- Phone: Google Calendar app, Personal toggle, default calendar → Personal, no Gmail app.
- Booking link → email signature / Slack profile.
