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
local function remindersToTot()
	if not u.appRunning("Tot") then u.openApps("Tot") end

	local script = "./helpers/push-todays-reminders-to-tot.js"
	if PushRemindersTask and PushRemindersTask:isRunning() then return end

	-- run as task so it's non-blocking
	PushRemindersTask = hs.task
		.new(script, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print("☑️ Reminder → Tot")
			else
				u.notify("⚠️ Reminder-to-Tot failed: " .. stdErr)
			end
		end)
		:start()

	updateCounter()
	-- FIX Reminders not properly quitting
	u.runWithDelays({ 1, 3 }, function() u.quitApp("Reminders") end)
end

--------------------------------------------------------------------------------
-- TRIGGERS

-- 1. Systemstart
if u.isSystemStart() then
	-- with delay, to avoid importing duplicate reminders due to reminders
	-- that are not being synced yet
	u.runWithDelays(15, remindersToTot)
end

-- 2. Every morning (safety redundancy)
MorningTimerForSidenotes = hs.timer.doAt("07:00", "01d", remindersToTot, true):start()

-- 3. On wake, update Counter
local c = hs.caffeinate.watcher
WakeTot = c.new(function(event)
	local hasWoken = event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock
	if hasWoken then updateCounter() end
end):start()

