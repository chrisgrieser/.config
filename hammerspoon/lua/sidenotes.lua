local u = require("lua.utils")

-- INFO using hs.execute("osascript -l JavaScript") instead of
-- hs.osascript.javascriptFromFile, fails on first run when Hammerspoon does not
-- have the needed permission yet

local function updateCounter() hs.execute("sketchybar --trigger update-sidenotes-count") end
--------------------------------------------------------------------------------

-- REMINDERS -> SIDENOTES
function ReminderToSidenotes()
	local _, success =
		hs.execute("osascript -l JavaScript './helpers/push-todays-reminders-to-sidenotes.js'")
	if success then
		print("🗒️ Reminder -> SideNotes")
	else
		u.notify("⚠️ Reminder-to-Sidenote failed")
	end
	updateCounter()
end

-- MOVE OFFICE NOTES TO BASE (when loading hammerspoon in office)
local function moveOfficeNotesToBase()
	local _, success = hs.execute("osascript -l JavaScript './helpers/move-office-sidenotes-to-base.js'")
	if success then
		print("🗒️ Office Sidenotes -> Base")
	else
		u.notify("⚠️ Moving Office SideNotes failed.")
	end
	updateCounter()
end

if u.isAtOffice() then moveOfficeNotesToBase() end

--------------------------------------------------------------------------------

SidenotesWatcher = u.aw.new(function(appName, event, appObj)
	-- UPDATE COUNTER IN SKETCHYBAR
	-- i.e., run on any event related to sidenotes
	if appName == "SideNotes" then updateCounter() end

	-- HIDE WHEN SWITCHING TO ANY OTHER APP
	-- (HACK since SideNotes can only be hidden on mouse click, but not on alt-tab)
	if appName ~= "SideNotes" and event == u.aw.activated then return end
	u.runWithDelays(0.05, function()
		-- INFO if sidenotes glitches, it is the "Hot Side" setting causing
		-- glitches when mouse is close, not Hammerspoon
		if u.isFront { "SideNotes", "Alfred", "CleanShot X", "Espanso" } then return end
		local app = u.app("SideNotes")
		if app then app:hide() end
	end)

	-- enlarge on startup
	if appName == "SideNotes" and event == u.aw.launched then
		local win = appObj:mainWindow()
		MoveResize(win, SideNotesWide)
	end
end):start()

--------------------------------------------------------------------------------

SideNotesWide = { x = 0, y = 0, w = 0.35, h = 1 }

-- toggle sizes of the sidenotes window
function ToggleSideNotesSize()
	local snWin = u.app("SideNotes"):mainWindow()
	local narrow = { x = 0, y = 0, w = 0.2, h = 1 }
	local changeTo = CheckSize(snWin, narrow) and SideNotesWide or narrow
	MoveResize(snWin, changeTo)
end
