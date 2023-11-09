local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")
local aw = hs.application.watcher

--------------------------------------------------------------------------------
-- COUNTER FOR SKETCHYBAR
local function updateCounter() hs.execute(u.exportPath .. "sketchybar --trigger update-tot-count") end

-- Triggers: App Switch
M.aw_tot = aw.new(function(appName, event, _)
	if appName ~= "Tot" then return end
	if event == aw.deactivated or event == aw.launched or event == aw.terminated then
		updateCounter()
	end
end):start()

--------------------------------------------------------------------------------
-- REMINDERS -> TOT

---@async
local function remindersToTot()
	-- run as task so it's not blocking
	M.task_pushReminder = hs.task
		.new("./helpers/push-todays-reminders-to-tot.js", function(exitCode, stdout, stderr)
			if stdout == "" then return end
			local msg = exitCode == 0 and "✅ Added reminders to Tot: " .. stdout
				or "⚠️ Reminder-to-Tot failed: " .. stderr
			u.notify(msg)
		end)
		:start()

	u.runWithDelays({ 2, 4 }, updateCounter)
end

-- TRIGGERS
-- 1. Systemstart
if u.isSystemStart() then
	-- with delay, to avoid importing duplicate reminders due to reminders
	-- that are not being synced yet
	u.runWithDelays(15, remindersToTot)
end

-- 2. Every morning
M.timer_morning = hs.timer.doAt("07:00", "01d", remindersToTot, true):start()

-- 3. On wake
local c = hs.caffeinate.watcher
M.caff_wake = c.new(function(event)
	if M.recentlyWoke then return end
	M.recentlyWoke = true

	local woke = event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock
	if woke then
		u.runWithDelays(10, function()
			if not env.isProjector() then remindersToTot() end
		end)
	end

	u.runWithDelays(2.5, function() M.recentlyWoke = false end)
end):start()

--------------------------------------------------------------------------------
return M
