local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
local c = hs.caffeinate.watcher
--------------------------------------------------------------------------------

-- force reminders sync on startup
if u.isSystemStart() then
	hs.execute("open -g -a Reminders")
	u.defer(6, function() u.quitApps("Reminders") end)
	u.defer(
		10,
		function() hs.execute(u.exportPath .. "sketchybar --trigger update_reminder_count") end
	)
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

--------------------------------------------------------------------------------
-- NIGHTLY CRONJOBS

-- CONFIG all files in this directory are executed every other day at 01:00
local cronjobDir = "./system/cronjobs"

M.timer_nightlyCronjobs = hs.timer
	.doAt("01:00", "01d", function()
		-- only every other day
		local isSunTueThuSat = os.date("%w") % 2 == 0
		if isSunTueThuSat then return end

		for file in hs.fs.dir(cronjobDir) do
			if file:find("%.sh$") then
				M["cronjob_" .. file] = hs.task
					.new(cronjobDir .. "/" .. file, function(code)
						local msg = code == 0 and "✅ Cronjob: " or "❌ Cronjob failed: "
						u.notify(msg .. file)
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
-- SLEEP TIMER

-- When projector is connected, check every x min if device has been idle for y
-- minutes. If so, alert and wait for z secs. If still idle then, quit
-- all video apps.
local config = {
	checkIntervalMins = 10,
	idleMins = 45,
	timeToReactSecs = 60,
}

M.timer_sleepAutoVideoOff = hs.timer
	.doEvery(config.checkIntervalMins * 60, function()
		-- GUARD
		local isIdle = (hs.host.idleTime() / 60) > config.idleMins
		if not (env.isProjector() and isIdle and u.screenIsUnlocked()) then return end

		local alertMsg = ("💤 Will sleep in %ds if idle."):format(config.timeToReactSecs)
		hs.alert(alertMsg, 4)
		u.defer(config.timeToReactSecs, function()
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