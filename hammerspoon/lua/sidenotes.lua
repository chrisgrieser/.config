local M = {}
--------------------------------------------------------------------------------

local u = require("lua.utils")
local wu = require("lua.window-utils")
local env = require("lua.environment-vars")

--------------------------------------------------------------------------------

local function updateCounter() hs.execute(u.exportPath .. "sketchybar --trigger update-sidenotes-count") end

SidenotesWatcher = u.aw
	.new(function(appName, event, appObj)
		-- UPDATE COUNTER IN SKETCHYBAR
		-- i.e., run on any event related to sidenotes
		if appName == "SideNotes" then updateCounter() end

		-- enlarge on startup/activatrion
		if appName == "SideNotes" and (event == u.aw.launched or event == u.aw.activated) then
			local win = appObj:mainWindow()
			wu.moveResize(win, wu.sideNotesWide)
		end

		-- HIDE WHEN SWITCHING TO ANY OTHER APP
		-- (HACK since SideNotes can only be hidden on mouse click, but not on alt-tab)
		if appName ~= "SideNotes" and event == u.aw.activated then
			u.runWithDelays(0.05, function()
				-- INFO if sidenotes glitches, it is the "Hot Side" setting causing
				-- glitches when mouse is close, not Hammerspoon
				if u.isFront { "SideNotes", "Alfred", "CleanShot X", "Espanso" } then return end
				local app = u.app("SideNotes")
				if app then app:hide() end
			end)
		end
	end)
	:start()

--------------------------------------------------------------------------------

-- MOVE OFFICE NOTES TO BASE (when loading hammerspoon in office)
-- run as task so it's non-blocking
local function moveOfficeNotesToBase()
	local script = "./helpers/move-office-sidenotes-to-base.js"
	if PushOfficeNotesTask and PushOfficeNotesTask:isRunning() then return end

	PushOfficeNotesTask = hs.task
		.new(script, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print("🗒️ Office Sidenotes -> Base")
			else
				u.notify("⚠️ Moving Office-SideNotes failed: " .. stdErr)
			end
		end)
		:start()

	updateCounter()
end

--------------------------------------------------------------------------------

-- REMINDERS -> SIDENOTES
-- run as task so it's non-blocking
function M.reminderToSidenotes()
	local script = "./helpers/push-todays-reminders-to-sidenotes.js"
	if PushRemindersTask and PushRemindersTask:isRunning() then return end

	PushRemindersTask = hs.task
		.new(script, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print("🗒️ Reminder -> SideNotes")
			else
				u.notify("⚠️ Reminder-to-Sidenote failed: " .. stdErr)
			end
		end)
		:start()

	updateCounter()
	-- FIX Reminders not properly quitting here
	u.runWithDelays({ 1, 2, 3 }, function() u.quitApp("Reminders") end)
end

--------------------------------------------------------------------------------

-- INITIALIZE
-- with delay, to avoid importing duplicate reminders due to reminders
-- not being synced yet
if env.isAtOffice then
	u.runWithDelays(15, function()
		moveOfficeNotesToBase()
		M.reminderToSidenotes()
	end)
end

--------------------------------------------------------------------------------

return M
