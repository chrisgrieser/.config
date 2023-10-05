local M = {}

local env = require("lua.environment-vars")
local u = require("lua.utils")
local aw = hs.application.watcher
--------------------------------------------------------------------------------

local function updateCounter() hs.execute(u.exportPath .. "sketchybar --trigger update-tot-count") end

-- update counter in sketchybar
TotWatcher = aw.new(function(appName, _, _)
	if appName == "Tot" then updateCounter() end
end):start()

--------------------------------------------------------------------------------

-- REMINDERS -> TOT
function M.reminderToSidenotes()
	if not u.appRunning("SideNotes") then u.openApps("SideNotes") end

	local script = "./helpers/push-todays-reminders-to-sidenotes.js"
	if PushRemindersTask and PushRemindersTask:isRunning() then return end

	-- run as task so it's non-blocking
	PushRemindersTask = hs.task
		.new(script, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print("☑️ Reminder → SideNotes")
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

-- 2. Every morning (safety redundancy)
MorningTimerForSidenotes = hs.timer.doAt("07:00", "01d", M.reminderToSidenotes, true):start()

-- 3. On wake, update Sidenotes Counter
local c = hs.caffeinate.watcher
WakeSideNotes = c.new(function(event)
	local hasWoken = event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock
	if hasWoken then updateCounter() end
end):start()

--------------------------------------------------------------------------------

return M
