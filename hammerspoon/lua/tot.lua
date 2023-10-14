local u = require("lua.utils")
local aw = hs.application.watcher

local g = {} -- persist from garbage collector
--------------------------------------------------------------------------------
-- COUNTER FOR SKETCHYBAR
local function updateCounter() hs.execute(u.exportPath .. "sketchybar --trigger update-tot-count") end

-- Triggers: App Switch
g.aw_tot = aw.new(function(appName, event, _)
	if appName == "Tot" and (event == aw.deactivated or event == aw.launched) then
		updateCounter()
	end
end):start()

--------------------------------------------------------------------------------
-- REMINDERS -> TOT
---@async
local function remindersToTot()
	if not u.appRunning("Tot") then return end

	-- run as task so it's not blocking
	g.task_pushReminder = hs.task
		.new("./helpers/push-todays-reminders-to-tot.js", function(exitCode, stdout, stderr)
			updateCounter()
			if stdout == "" then return end
			local msg = exitCode == 0 and "✅ Added reminders to Tot: " .. stdout
				or "⚠️ Reminder-to-Tot failed: " .. stderr
			u.notify(msg)
		end)
		:start()

	-- FIX Reminders not properly quitting
	u.runWithDelays({ 1, 3 }, function() u.quitApps("Reminders") end)
end

-- TRIGGERS
-- 1. Systemstart
if u.isSystemStart() then
	-- with delay, to avoid importing duplicate reminders due to reminders
	-- that are not being synced yet
	u.runWithDelays(15, remindersToTot)
end

-- 2. Every morning
g.timer_morning = hs.timer.doAt("07:00", "01d", remindersToTot, true):start()

-- 3. On wake
local c = hs.caffeinate.watcher
g.caff_wake = c.new(function(event)
	local woke = event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock
	if woke then u.runWithDelays(10, remindersToTot) end
end):start()

--------------------------------------------------------------------------------
return nil, g
