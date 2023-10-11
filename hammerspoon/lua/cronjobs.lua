local u = require("lua.utils")
local wu = require("lua.window-utils")
local c = hs.caffeinate.watcher
local env = require("lua.environment-vars")

---@return string three chars representing the day of the week (English)
local function getWeekday() return tostring(os.date("%a")) end

--------------------------------------------------------------------------------

-- keep the iMac display brightness low when projector is connected
ProjectorScreensaverWatcher = c.new(function(event)
	if env.isAtOffice then return end
	if
		event == c.screensaverDidStop
		or event == c.screensaverDidStart
		or event == c.screensDidWake
		or event == c.systemDidWake
		or event == c.screensDidSleep
	then
		u.runWithDelays({ 0, 1, 3 }, function()
			if env.isProjector() then wu.iMacDisplay:setBrightness(0) end
		end)
	end
end):start()

-- on Mondays shortly before 10:00, open #fg-organisation Slack Channel
JourFixeTimer = hs.timer
	.doAt("09:59", "01d", function()
		if not (getWeekday() == "Mon" and u.screenIsUnlocked()) then return end
		hs.execute("open 'slack://channel?team=T010A5PEMBQ&id=CV95T641Y'")
		hs.alert.show("Jour Fix" .. "e")
	end)
	:start()

--------------------------------------------------------------------------------
-- BACKUP / MAINTENANCE

-- - Backup Vault, Dotfiles, Bookmarks
local function backup()
	-- stylua: ignore start
	hs.task.new("./helpers/bookmark-bkp.sh", function(exitCode, _, stdErr)
		local msg = exitCode == 0 and "✅ Bookmark Backup successful" or "⚠️ Bookmark Backup failed: " .. stdErr
		u.notify(msg)
	end):start()
	hs.task.new("./helpers/dotfile-bkp.sh", function(exitCode, _, stdErr)
		local msg = exitCode == 0 and "✅ Dotfile Backup successful" or "⚠️ Dotfile Backup failed: " .. stdErr
		u.notify(msg)
	end):start()
	u.applescript([[tell application id "com.runningwithcrayons.Alfred" to run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"]])
	-- stylua: ignore end
end

NightlyMaintenanceTimer = hs.timer
	.doAt("01:00", "01d", function()
		local weekday = getWeekday()
		if weekday == "Sun" then hs.loadSpoon("EmmyLua") end
		if weekday == "Tue" or weekday == "Fri" or weekday == "Sun" then backup() end
	end, true)
	:start()

--------------------------------------------------------------------------------
-- SLEEP TIMER

local function closeFullscreenSpaces()
	local allSpaces = hs.spaces.allSpaces()
	if not allSpaces then return end
	for _, spaces in pairs(allSpaces) do
		for _, spaceId in pairs(spaces) do
			if hs.spaces.spaceType(spaceId) == "fullscreen" then hs.spaces.removeSpace(spaceId) end
		end
	end
end

---whether device has been idle
---@nodiscard
---@param mins number Time idle
---@return boolean
local function idleMins(mins)
	local minutesIdle = hs.host.idleTime() / 60
	return minutesIdle > mins
end

-- Between 0:00 and 7:00, check every 10 min if device has been idle for 30
-- minutes. If so, alert and wait for another minute. If still idle then, quit
-- video apps.
local config = {
	betweenHours = { 0, 7 },
	checkIntervalMins = 10,
	idleMins = 30,
	timeToReactSecs = 60,
}

SleepAutoVideoOffTimer = hs.timer
	.doEvery(config.checkIntervalMins * 60, function()
		local isNight = u.betweenTime(table.unpack(config.betweenHours))
		if not (isNight and idleMins(config.idleMins) and env.isProjector() and u.screenIsUnlocked()) then
			return
		end

		hs.alert.show(("💤 Will sleep in %ss if idle."):format(config.timeToReactSecs))

		u.runWithDelays(config.timeToReactSecs, function()
			if hs.host.idleTime() < config.timeToReactSecs then return end
			u.notify("💤 SleepTimer triggered")

			-- 1. close browser tabs running YouTube (not using full name for youtube short-urls)
			-- 2. close leftover fullscreen spaces created by apps running in fullscreen
			u.closeTabsContaining("youtu")
			u.quitApps(env.videoAndAudioApps)
			closeFullscreenSpaces()
		end)
	end)
	:start()
