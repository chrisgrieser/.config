local M = {}
--------------------------------------------------------------------------------

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")

--------------------------------------------------------------------------------

local function updateCounter() hs.execute(u.exportPath .. "sketchybar --trigger update-sidenotes-count") end

SidenotesWatcher = u.aw
	.new(function(appName, event, appObj)
		-- UPDATE COUNTER IN SKETCHYBAR
		-- i.e., run on any event related to sidenotes
		if appName == "SideNotes" then updateCounter() end

		-- enlarge on startup/activatrion
		if appName == "SideNotes" and event == u.aw.launched then
			local win = appObj:mainWindow()
			wu.moveResize(win, wu.sideNotesWide)
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
if env.isAtOffice and not u.isReloading() then
	u.runWithDelays(15, function()
		moveOfficeNotesToBase()
		M.reminderToSidenotes()
	end)
end

--------------------------------------------------------------------------------

return M
