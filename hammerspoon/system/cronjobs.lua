local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
local c = hs.caffeinate.watcher
local timerAt = hs.timer.doAt
local timerEverySecs = hs.timer.doEvery

---FORCE REMINDERS SYNC ON STARTUP----------------------------------------------
if u.isSystemStart() then
	print("📅 Syncing Reminders")
	hs.execute("open -g -a Reminders") -- `-g` to open in background
	u.defer({ 5, 15 }, function() u.quitApps("Reminders") end)
end

---TURN OFF DISPLAY IF----------------------------------------------------------
M.caff_projectorScreensaver = c.new(function(event)
	if env.isAtOffice then return end

	-- 1. screensaver starts at night
	if event == c.screensaverDidStart and u.betweenTime(22, 7) and not env.hasProjector() then
		wu.iMacDisplay:setBrightness(0)
	end

	-- 2. screen activity while projector connected
	if
		event == c.screensaverDidStop
		or event == c.screensaverDidStart
		or event == c.screensDidWake
		or event == c.systemDidWake
		or event == c.screensDidSleep
	then
		u.defer({ 0, 2 }, function()
			if env.hasProjector() then wu.iMacDisplay:setBrightness(0) end
		end)
	end
end):start()

---CLOCK------------------------------------------------------------------------
-- Show clock every full hour
M.timer_clock = timerEverySecs(60, function()
	local isFullHour = os.date("%M") == "00"
	if isFullHour and u.screenIsUnlocked() and not env.hasProjector() then
		local hour = tostring(os.date("%H:%M"))
		hs.alert(hour, 3)
	end
end):start()

-- Reminder to go to Finesse Bistro
M.timer_finesseBistro = timerAt("12:00", "01d", function()
	local dayOfWeek = tostring(os.date("%a"))
	local isWeekday = hs.fnutils.contains({ "Mon", "Tue", "Wed", "Thu" }, dayOfWeek)
	if isWeekday and env.isAtHome and u.screenIsUnlocked() then
		local msg = "🍴 Go to Finesse Bistro"
		hs.alert(msg, 4)
		print(msg)
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
			if not u.isExecutableFile(jobfile) then
				print("⚠️ " .. jobfile .. " is not executable.")
				goto continue
			end
			local task = hs.task.new
			M["cronjob_" .. file] = task(jobfile, function(code, stdout, stderr)
				local output = (stdout .. "\n" .. stderr):gsub("%s+$", "")
				local fileShort = file:gsub("%.%w+$", "")
				local msg = "🕑 " .. fileShort .. (output ~= "" and ": " .. output or "")
				if code ~= 0 then return u.notify("❌ " .. msg) end
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

---UPTIME CHECK-----------------------------------------------------------------
local maxUptimeDays = 30 -- CONFIG
M.timer_uptime = timerAt("01:30", "01d", function()
	local stdout = hs.execute("uptime") or ""
	local uptimeDays = tonumber(stdout:match("up (%d+) days,") or 0)
	if uptimeDays > maxUptimeDays then
		u.createReminderToday("🖥️ Uptime is over " .. maxUptimeDays .. " days")
	end
end):start()

--------------------------------------------------------------------------------
return M
