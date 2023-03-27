require("lua.utils")

-- INFO using hs.execute("osascript -l JavaScript") instead of
-- hs.osascript.javascriptFromFile, fails on first run when Hammerspoon does not
-- have the needed permission yet

--------------------------------------------------------------------------------

-- REMINDERS -> SIDENOTES
function UpdateSidenotes()
	local _, success =
		hs.execute("osascript -l JavaScript './helpers/push-todays-reminders-to-sidenotes.js'")
	if not success then Notify("⚠️ Reminder-to-Sidenote failed") end
end

SideNotesTimer = hs.timer.doAt("05:00", "01d", UpdateSidenotes)


--------------------------------------------------------------------------------

hs.execute("osascript -l JavaScript './helpers/.js'")
