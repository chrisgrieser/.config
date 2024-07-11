local M = {} -- persist from garbage collector

local env = require("modules.environment-vars")
local u = require("modules.utils")
local wu = require("modules.window-utils")
local c = hs.caffeinate.watcher
--------------------------------------------------------------------------------

-- force reminders sync on startup
if u.isSystemStart() then
	u.openApps("Reminders")
	u.whenAppWinAvailable("Reminders", function() u.app("Reminders"):hide() end)
	u.runWithDelays(6, function() u.quitApps("Reminders") end)
end

--------------------------------------------------------------------------------

-- turn off display
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
		u.runWithDelays({ 0, 2 }, function()
			if env.isProjector() then wu.iMacDisplay:setBrightness(0) end
		end)
	end
end):start()

-- notify every full hour
M.timer_clock = hs.timer
	.doEvery(60, function()
		local isFullHour = os.date("%M") == "00"
		if isFullHour and u.screenIsUnlocked() and not env.isProjector() then
			local hour = tostring(os.date("%H:%M"))
			hs.alert(hour, 2)
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- BACKUP / MAINTENANCE

-- 1. save macOS preferences via `mackup`
-- 2. bookmark backup
-- 3. reminder backup
M.timer_nightlyMaintenance = hs.timer
	.doAt("01:00", "01d", function()
		if os.date("%a") == "Sun" then hs.loadSpoon("EmmyLua") end

		-- GUARD
		local isSunTueThuSat = os.date("%w") % 2 == 0
		if isSunTueThuSat then return end

		local _, success = hs.execute("saveprefs_mackup", true)
		u.notify(success and "✅ mackup saved" or "⚠️ mackup failed")

		M.task_bookmarksBackup = hs.task
			.new("./helpers/bookmark-bkp.sh", function(code, _, stderr)
				local msg = code == 0 and "✅ Bookmark Backup successful"
					or "⚠️ Bookmark Backup failed: " .. stderr
				u.notify(msg)
			end)
			:start()

		M.task_reminderBackup = hs.task
			.new("./helpers/reminders-bkp.sh", function(code, _, stderr)
				local msg = code == 0 and "✅ Reminder Backup successful"
					or "⚠️ Reminder Backup failed: " .. stderr
				u.notify(msg)
			end)
			:start()
	end, true)
	:start()

--------------------------------------------------------------------------------
-- SLEEP TIMER

-- Between 0:00 and 7:00, check every x min if device has been idle for y
-- minutes. If so, alert and wait for z secs. If still idle then, quit
-- all video apps.
local config = {
	betweenHours = { 0, 7 },
	checkIntervalMins = 10,
	idleMins = 45,
	timeToReactSecs = 60,
}

M.timer_sleepAutoVideoOff = hs.timer
	.doEvery(config.checkIntervalMins * 60, function()
		-- GUARD
		local isNight = u.betweenTime(config.betweenHours[1], config.betweenHours[2])
		local isIdle = (hs.host.idleTime() / 60) > config.idleMins
		if not (isNight and isIdle and u.screenIsUnlocked()) then return end

		local alertMsg = ("💤 Will sleep in %ss if idle."):format(config.timeToReactSecs)
		hs.alert(alertMsg, 4)
		u.runWithDelays(config.timeToReactSecs, function()
			-- GUARD
			local userDidSth = hs.host.idleTime() < config.timeToReactSecs
			if userDidSth then return end

			u.notify("💤 SleepTimer triggered")
			u.closeAllTheThings()
		end)
	end)
	:start()

--------------------------------------------------------------------------------
return M
