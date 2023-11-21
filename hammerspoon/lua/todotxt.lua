local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")

--------------------------------------------------------------------------------
-- REMINDERS -> TODOTXT

---@async
local function remindersToTodotxt()
	-- run as task so it's not blocking
	M.task_pushReminder = hs.task
		.new("./helpers/push-todays-reminders-to-tot.js", function(exitCode, stdout, stderr)
			if stdout == "" then return end
			local msg = exitCode == 0 and "✅ Added reminders to Tot: " .. stdout
				or "⚠️ Reminder-to-Tot failed: " .. stderr
			u.notify(msg)
		end, nil, { env.todotxtPath })
		:start()
end

-- TRIGGERS
-- 1. systemstart
if u.isSystemStart() then remindersToTodotxt() end

-- 2. Every morning
M.timer_morning = hs.timer.doAt("07:00", "01d", remindersToTodotxt, true):start()

-- 3. On wake
local c = hs.caffeinate.watcher
M.caff_wake = c.new(function(event)
	if env.isProjector() then return end
	if M.recentlyWoke then return end
	M.recentlyWoke = true

	local woke = event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock
	if woke then u.runWithDelays(10, remindersToTodotxt) end -- wait for sync

	u.runWithDelays(2.5, function() M.recentlyWoke = false end)
end):start()

--------------------------------------------------------------------------------
return M
