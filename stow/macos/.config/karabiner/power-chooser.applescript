-- Power chooser — bound to Ctrl+Alt+P via Karabiner (see karabiner.json).
-- Touch ID MacBooks have no working Ctrl+Power dialog (the power-button combos
-- date from Macs with real power/eject keys), so this recreates the useful part.
-- A list instead of `display dialog` buttons: dialogs max out at 3 buttons, and
-- a list is fully keyboard-driven anyway — ↑/↓ select, Enter runs, Esc cancels.
tell application "System Events"
	activate
	set choice to choose from list {"Sleep", "Restart", "Shut Down"} ¬
		with title "Power" with prompt "Leaving the machine?" ¬
		default items {"Sleep"} OK button name "Go"
end tell
if choice is false then return -- Esc / Cancel
set choice to item 1 of choice
if choice is "Sleep" then
	tell application "System Events" to sleep
else if choice is "Restart" then
	tell application "System Events" to restart
else if choice is "Shut Down" then
	-- Graceful, like Restart: asks every app to quit, prompts only for unsaved work.
	tell application "System Events" to shut down
end if
