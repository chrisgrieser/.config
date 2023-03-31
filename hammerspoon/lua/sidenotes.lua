require("lua.utils")

-- INFO using hs.execute("osascript -l JavaScript") instead of
-- hs.osascript.javascriptFromFile, fails on first run when Hammerspoon does not
-- have the needed permission yet

local function updateCounter() hs.execute("sketchybar --trigger update-sidenotes-count") end
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
	updateCounter()
end

SideNotesTimer1 = hs.timer.doAt("05:00", "01d", UpdateSidenotes)
SideNotesTimer2 = hs.timer.doAt("05:30", "01d", UpdateSidenotes) -- redundancy for safety

-- MOVE OFFICE NOTES TO BASE (when loading hammerspoon in office)
local function moveOfficeNotesToBase()
	local _, success = hs.execute("osascript -l JavaScript './helpers/move-office-sidenotes-to-base.js'")
	if success then
		print("🗒️ Office Sidenotes -> Base")
	else
		Notify("⚠️ Moving Office SideNotes failed.")
	end
	updateCounter()
end

if IsAtOffice() then moveOfficeNotesToBase() end

--------------------------------------------------------------------------------

-- UPDATE COUNTER IN SKETCHYBAR
SidenotesWatcher = Aw.new(function(appName)
	-- i.e., run on any event related to sidenotes
	if appName == "SideNotes" then updateCounter() end
end):start()

-- HIDE WHEN SWITCHING TO ANY OTHER APP (HACK)
-- (since SideNotes can only be hidden on mouse click, but not on alt-tab)
SidenotesWatcher2 = Aw.new(function(appName, event)
	if appName == "SideNotes" or event ~= Aw.activated then return end
	RunWithDelays(0.15, function()
		if
			FrontAppName() ~= "SideNotes"
			and FrontAppName() ~= "Alfred"
			and FrontAppName() ~= "CleanShot X"
			and FrontAppName() ~= "Espanso"
		then
			-- INFO if sidenotes glitches, it is the "Hot Side" setting causing
			-- glitches when mouse is close, not Hammerspoon
			App("SideNotes"):hide()
		end
	end)
end):start()
