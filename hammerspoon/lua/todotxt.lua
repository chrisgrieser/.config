local M = {} -- persist from garbage collector
local env = require("lua.environment-vars")
local u = require("lua.utils")

--------------------------------------------------------------------------------
-- REMINDERS TO TODOTXT

---@async
local function remindersToTodotxt()
	M.task_pushReminder = hs
		.task -- run as hs.task so it's not blocking
		.new("./helpers/push-todays-reminders-to-todotxt.js", function(exitCode, stdout, stderr)
			if stdout == "" then return end
			local msg = exitCode == 0 and "✅ Added todos: " .. stdout
				or "⚠️ Reminders Import failed: " .. stderr
			u.notify(msg)
		end, { env.todotxtPath })
		:start()
end

-- triggers
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
-- BACKUP

-- CONFIG
local backupFreqHours = 2

-- stylua: ignore
M.timer_todotxtBackup = hs.timer.doEvery(backupFreqHours * 3600, function()
	M.task_todotxtBackup = hs.task.new("./helpers/todotxt-bkp.sh", function(exitCode, _, stdErr)
		if exitCode ~= 0 then u.notify("⚠️ todo.txt Backup failed: " .. stdErr) end
	end):start()
end, true):start()

--------------------------------------------------------------------------------
return M
