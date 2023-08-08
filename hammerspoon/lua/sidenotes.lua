local M = {}
--------------------------------------------------------------------------------

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")

--------------------------------------------------------------------------------

local function updateCounter() hs.execute(u.exportPath .. "sketchybar --trigger update-sidenotes-count") end

-- update counter in sketchybar
-- enlarge on startup
SidenotesWatcher = u.aw
	.new(function(appName, event, sidenotes)
		if appName ~= "SideNotes" then return end

		updateCounter() -- i.e., run on any event related to sidenotes
		if event == u.aw.launched then wu.moveResize(sidenotes:mainWindow(), wu.sideNotesWide) end
	end)
	:start()

--------------------------------------------------------------------------------

-- MOVE OFFICE NOTES TO BASE (when loading hammerspoon in office)
-- run as task so it's non-blocking
local function moveOfficeNotesToBase()
	if not u.appRunning("SideNotes") then u.openApps("SideNotes") end
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
function M.reminderToSidenotes()
	if not u.appRunning("SideNotes") then u.openApps("SideNotes") end

	local script = "./helpers/push-todays-reminders-to-sidenotes.js"
	if PushRemindersTask and PushRemindersTask:isRunning() then return end

	-- run as task so it's non-blocking
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
-- TRIGGERS

-- 1. Systemstart
if not u.isReloading() then
	-- with delay, to avoid importing duplicate reminders due to reminders
	-- that are not being synced yet
	u.runWithDelays(15, M.reminderToSidenotes)
	if env.isAtOffice then u.runWithDelays({ 10, 20, 30, 40 }, moveOfficeNotesToBase) end
end

-- 2. Every morning (safety redundancy)
MorningTimerForSidenotes = hs.timer
	.doAt("07:00", "01d", M.reminderToSidenotes , true)
	:start()

--------------------------------------------------------------------------------

return M
