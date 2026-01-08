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
	u.defer(10, function()
		u.quitApps("Reminders")
		hs.execute(u.exportPath .. "sketchybar --trigger update_reminder_count")
	end)
end

---TURN OFF DISPLAY IF----------------------------------------------------------
M.caff_projectorScreensaver = c.new(function(event)
	if env.isAtOffice then return end

	-- 1. screensaver starts at night
	if event == c.screensaverDidStart and u.betweenTime(22, 7) and not env.isProjector() then
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
			if env.isProjector() then wu.iMacDisplay:setBrightness(0) end
		end)
	end
end):start()

---CLOCK------------------------------------------------------------------------
-- Show clock every full hour
M.timer_clock = timerEverySecs(60, function()
	local isFullHour = os.date("%M") == "00"
	if isFullHour and u.screenIsUnlocked() and not env.isProjector() then
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

---NIGHTLY MAINTENANCE----------------------------------------------------------
do
	local cronjobDir = "./system/cronjobs" -- CONFIG

	local function runEveryFileIn(dir)
		for file in hs.fs.dir(dir) do
			local jobfile = dir .. "/" .. file
			if not u.isExecutableFile(jobfile) then goto continue end
			local task = hs.task.new
			M["cronjob_" .. file] = task(jobfile, function(code, stdout, stderr)
				local output = (stdout .. "\n" .. stderr)
					:gsub("%s+$", "")
					:gsub("^✅ ", "") -- redundant, since we add emojis here as well
					:gsub("^❌ ", "")
				local msg = "Cronjob " .. file .. (output ~= "" and ": " .. output or "")
				if code ~= 0 then return u.notify("❌ " .. msg) end
				print("✅ " .. msg)
			end):start()
			::continue::
		end
	end

	M.timer_hourlyCronjobs = timerEverySecs(3600, function()
		if not u.screenIsUnlocked() then return end
		runEveryFileIn(cronjobDir .. "/hourly")
	end):start()

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

---SLEEP TIMER------------------------------------------------------------------
-- When projector is connected, check every x min if device has been idle for y
-- minutes. If so, alert and wait for z secs. If still idle then, quit
-- all video apps.
local config = {
	checkIntervalMins = 10,
	idleMins = 50,
	timeToReactSecs = 20,
}

M.timer_sleepAutoVideoOff = timerEverySecs(config.checkIntervalMins * 60, function()
	local isIdle = (hs.host.idleTime() / 60) > config.idleMins
	if not env.isProjector() or not isIdle or not u.screenIsUnlocked() then return end

	local alertMsg = ("💤 Will sleep in %ds if idle."):format(config.timeToReactSecs)
	local alertId = hs.alert(alertMsg, config.timeToReactSecs)
	hs.sound.getByName("Submarine"):volume(0.3):play() ---@diagnostic disable-line: undefined-field

	-- remove alert earlier if user did something
	u.defer(math.ceil(config.timeToReactSecs / 2), function()
		local userDidSth = hs.host.idleTime() < (config.timeToReactSecs / 2)
		if userDidSth then hs.alert.closeSpecific(alertId) end
	end)

	-- close if user idle
	u.defer(config.timeToReactSecs, function()
		local userDidSth = hs.host.idleTime() < config.timeToReactSecs
		if userDidSth then return end

		u.notify("💤 SleepTimer triggered")
		u.closeAllFinderWins()
		u.quitFullscreenAndVideoApps()
		u.closeBrowserTabsWith("all")
	end)
end):start()

--------------------------------------------------------------------------------
return M
