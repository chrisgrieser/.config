local M = {}
--------------------------------------------------------------------------------

local u = require("lua.utils")
local wu = require("lua.window-utils")

--------------------------------------------------------------------------------

local function updateCounter() hs.execute("sketchybar --trigger update-sidenotes-count") end

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
		wu.moveResize(win, wu.sideNotesWide)
	end
end):start()

--------------------------------------------------------------------------------

-- REMINDERS -> SIDENOTES
function M.reminderToSidenotes()
	local _, success =
		hs.execute("osascript -l JavaScript './helpers/push-todays-reminders-to-sidenotes.js'")
	if success then
		print("🗒️ Reminder -> SideNotes")
	else
		u.notify("⚠️ Reminder-to-Sidenote failed")
	end
	updateCounter()
end

--------------------------------------------------------------------------------

return M
