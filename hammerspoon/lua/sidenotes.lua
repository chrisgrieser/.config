require("lua.utils")

-- INFO using hs.execute("osascript -l JavaScript") instead of
-- hs.osascript.javascriptFromFile, fails on first run when Hammerspoon does not
-- have the needed permission yet

--------------------------------------------------------------------------------

-- REMINDERS -> SIDENOTES
function UpdateSidenotes()
	local _, success =
		hs.execute("osascript -l JavaScript './helpers/push-todays-reminders-to-sidenotes.js'")
	if success then
		print("🗒️ Reminder -> SideNotes")
	else
		Notify("⚠️ Reminder-to-Sidenote failed")
	end
end

SideNotesTimer = hs.timer.doAt("05:00", "01d", UpdateSidenotes)

-- MOVE OFFICE NOTES TO BASE (when loading hammerspoon in office)
local function moveOfficeNotesToBase()
	local _, success = hs.execute("osascript -l JavaScript './helpers/move-office-sidenotes-to-base.js'")
	if success then
		print("🗒️ Office Sidenotes -> Base")
	else
		Notify("⚠️ Moving Office SideNotes failed.")
	end
end

if IsAtOffice() then moveOfficeNotesToBase() end

--------------------------------------------------------------------------------

-- UPDATE COUNTER IN SKETCHYBAR
SidenotesWatcher = Aw.new(function(appName)
	if appName == "SideNotes" then -- i.e., run on any event related to sidenotes
		hs.execute("sketchybar --trigger update-sidenote-count")
	end
end):start()

-- HIDE WHEN SWITCHING TO ANY OTHER APP (HACK)
-- (since SideNotes can only be hidden on mouse click, but not on alt-tab)
SidenotesWatcher2 = Aw.new(function(appName, event)
	if appName == "SideNotes" or event ~= Aw.activated then return end
	RunWithDelays(0.2, function()
		if
			FrontAppName() ~= "SideNotes"
			and FrontAppName() ~= "Alfred"
			and FrontAppName() ~= "CleanShot X"
		then
			App("SideNotes"):hide()
		end
	end)
end):start()
