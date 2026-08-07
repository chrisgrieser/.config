local M = {} -- persist from garbage collector

local env = require("meta.environment")
local timerAt = hs.timer.doAt
local timerEverySecs = hs.timer.doEvery

---FORCE REMINDERS SYNC ON STARTUP----------------------------------------------
if U.isSystemStart() then
	print("📅 Syncing Reminders")
	hs.execute("open -g -a Reminders") -- `-g` to open in background
	U.defer({ 5, 15 }, function() U.quitApps("Reminders") end)
end

---CLOCK------------------------------------------------------------------------
-- Show clock every full hour
M.timer_clock = timerEverySecs(60, function()
	local isFullHour = os.date("%M") == "00"
	if isFullHour and U.screenIsUnlocked() and not env.hasProjector() then
		local hour = tostring(os.date("%H:%M"))
		hs.alert(hour, 3)
	end
end):start()

-- MAINTENANCE------------------------------------------------------------------
do
	local cronjobDir = "./system/cronjobs" -- CONFIG

	local function runEveryFileIn(dir)
		for file in hs.fs.dir(dir) do
			if file == "." or file == ".." then goto continue end -- special UNIX locations
			local ext = file:match("%.%w+$")
			if ext ~= ".sh" and ext ~= ".applescript" then goto continue end
			local jobfile = dir .. "/" .. file
			if not U.isExecutableFile(jobfile) then
				print("⚠️ " .. jobfile .. " is not executable.")
				goto continue
			end
			local task = hs.task.new
			M["cronjob_" .. file] = task(jobfile, function(code, stdout, stderr)
				local output = (stdout .. "\n" .. stderr):gsub("%s+$", "")
				local fileShort = file:gsub("%.%w+$", "")
				local msg = "🕑 " .. fileShort .. (output ~= "" and ": " .. output or "")
				if code ~= 0 then return U.notify("❌ " .. msg) end
				print(msg)
			end):start()
			::continue::
		end
	end

	M.timer_hourlyCronjobs = timerEverySecs(
		3600,
		function() runEveryFileIn(cronjobDir .. "/hourly") end
	):start()

	M.timer_biweeklyCronjobs = timerAt("01:00", "01d", function()
		if os.date("%w") % 3 == 0 then runEveryFileIn(cronjobDir .. "/biweekly") end
	end, true):start()
end

---LUA TYPINGS FOR HAMMERSPOON--------------------------------------------------

-- URI for Justfile
hs.urlevent.bind("update-emmylua-types", function() hs.loadSpoon("EmmyLua") end)

---UPTIME CHECK-----------------------------------------------------------------
local maxUptimeDays = 30 -- CONFIG
M.timer_uptime = timerAt("01:30", "01d", function()
	local stdout = hs.execute("uptime") or ""
	local uptimeDays = tonumber(stdout:match("up (%d+) days,") or 0)
	if uptimeDays > maxUptimeDays then
		U.createReminderToday("🖥️ Uptime is over " .. maxUptimeDays .. " days")
	end
end):start()

--------------------------------------------------------------------------------
return M
