local u = require("lua.utils")
local aw = hs.application.watcher
--------------------------------------------------------------------------------
-- COUNTER FOR SKETCHYBAR
local function updateCounter() hs.execute(u.exportPath .. "sketchybar --trigger update-tot-count") end

-- Triggers
-- 1. App Switch
TotWatcher = aw.new(function(appName, event, tot)
	if appName ~= "Tot" then return end

	if event == aw.deactivated then
		updateCounter()
		if not u.isFront("Alfred") then tot:hide() end
	end
	if event == aw.launched then updateCounter() end -- when count has changed via sync
end):start()

-- 2. On wake
local c = hs.caffeinate.watcher
WakeTot = c.new(function(event)
	local hasWoken = event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock
	if hasWoken then updateCounter() end
end):start()

--------------------------------------------------------------------------------
-- REMINDERS -> TOT
local function remindersToTot()
	local script = "./helpers/push-todays-reminders-to-tot.js"

	-- run as task so it's non-blocking
	PushRemindersTask = hs.task
		.new(script, function(exitCode, stdout, stderr)
			if stdout == "" then return end
			local msg = exitCode == 0 and "✅ Added reminders to Tot: " .. stdout
				or "⚠️ Reminder-to-Tot failed: " .. stderr
			u.notify(msg)
		end)
		:start()

	-- FIX Reminders not properly quitting
	u.runWithDelays({ 1, 3 }, function() u.quitApp("Reminders") end)

	updateCounter()
end

-- TRIGGERS
-- 1. Systemstart
if u.isSystemStart() then
	-- with delay, to avoid importing duplicate reminders due to reminders
	-- that are not being synced yet
	u.runWithDelays(15, remindersToTot)
end

-- 2. Every morning
MorningTimerForSidenotes = hs.timer.doAt("07:00", "01d", remindersToTot, true):start()
