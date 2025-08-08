local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
local c = hs.caffeinate.watcher
--------------------------------------------------------------------------------

-- force reminders sync on startup
if u.isSystemStart() then
	print("📅 Syncing Reminders")
	hs.execute("open -g -a Reminders") -- `-g` to open in background
	u.defer(10, function()
		u.quitApps("Reminders")
		hs.execute(u.exportPath .. "sketchybar --trigger update_reminder_count")
	end)
end

--------------------------------------------------------------------------------

-- turn off display if
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

-- Show clock every full hour
M.timer_clock = hs.timer
	.doEvery(60, function()
		local isFullHour = os.date("%M") == "00"
		if isFullHour and u.screenIsUnlocked() and not env.isProjector() then
			local hour = tostring(os.date("%H:%M"))
			hs.alert(hour, 2)
		end
	end)
	:start()

-- Reminder to go to Finesse Bistro
-- M.timer_finesseBistro = hs.timer
-- 	.doAt("12:00", "01d", function()
-- 		local dayOfWeek = tostring(os.date("%a"))
-- 		local isWeekday = hs.fnutils.contains({ "Mon", "Tue", "Wed", "Thu" }, dayOfWeek)
-- 		if isWeekday and env.isAtHome and u.screenIsUnlocked() then
-- 			local msg = "🍴 Go to Finesse Bistro"
-- 			hs.alert(msg, 4)
-- 			print(msg)
-- 		end
-- 	end)
-- 	:start()

--------------------------------------------------------------------------------
-- NIGHTLY CRONJOBS

-- CONFIG all `.sh` files in this directory are executed every other day at 01:00
local cronjobDir = "./system/cronjobs"

M.timer_nightlyCronjobs = hs.timer
	.doAt("01:00", "01d", function()
		if os.date("%w") % 2 == 0 then return end -- only every other day

		for file in hs.fs.dir(cronjobDir) do
			local jobfile = cronjobDir .. "/" .. file
			if file:find("%.sh$") and u.isExecutable(jobfile) then
				M["cronjob_" .. file] = hs.task
					.new(jobfile, function(code)
						if code == 0 then
							print("✅ Cronjob: " .. file)
						else
							u.notify("❌ Cronjob failed: " .. file)
						end
					end)
					:start()
			end
		end
	end, true)
	:start()

--------------------------------------------------------------------------------

-- EMMYLUA UPDATER
-- HACK technically only needed once every hammerspoon update, but since there
-- is no good API to detect updates, we just run it weekly instead.
M.timer_emmyluaUpdater = hs.timer
	.doAt("01:30", "01d", function()
		if os.date("%a") == "Sun" then hs.loadSpoon("EmmyLua") end
	end)
	:start()

--------------------------------------------------------------------------------

-- UPTIME CHECK
local maxUptimeDays = 50
M.timer_uptime = hs.timer
	.doAt("01:30", "01d", function()
		local stdout = hs.execute("uptime") or ""
		local uptimeDays = tonumber(stdout:match("up (%d+) days,") or 0)
		if uptimeDays > maxUptimeDays then
			u.createReminder("🖥️ Uptime is over " .. maxUptimeDays .. " days")
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- SLEEP TIMER

-- When projector is connected, check every x min if device has been idle for y
-- minutes. If so, alert and wait for z secs. If still idle then, quit
-- all video apps.
local config = {
	checkIntervalMins = 10,
	idleMins = 45,
	timeToReactSecs = 90,
}

M.timer_sleepAutoVideoOff = hs.timer
	.doEvery(config.checkIntervalMins * 60, function()
		local isIdle = (hs.host.idleTime() / 60) > config.idleMins
		if not env.isProjector() or not isIdle or not u.screenIsUnlocked() then return end

		local alertMsg = ("💤 Will sleep in %ds if idle."):format(config.timeToReactSecs)
		hs.alert(alertMsg, 4)
		u.defer(config.timeToReactSecs, function()
			local userDidSth = hs.host.idleTime() < config.timeToReactSecs
			if userDidSth then return end

			u.notify("💤 SleepTimer triggered")
			u.closeAllTheThings()
		end)
	end)
	:start()

--------------------------------------------------------------------------------
return M
