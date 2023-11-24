local M = {} -- persist from garbage collector

local u = require("lua.utils")
local wu = require("lua.window-utils")
local c = hs.caffeinate.watcher
local env = require("lua.environment-vars")

--------------------------------------------------------------------------------

-- keep the iMac display brightness low when projector is connected
M.caff_projectorScreensaver = c.new(function(event)
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
M.timer_JourFixe = hs.timer
	.doAt("09:59", "01d", function()
		if not (os.date("%a") == "Mon" and u.screenIsUnlocked()) then return end

		hs.alert.show("Jour Fixe") -- codespell-ignore
		local fgOrganisationChannel = "slack://channel?team=T010A5PEMBQ&id=CV95T641Y"
		hs.urlevent.openURL(fgOrganisationChannel)
	end)
	:start()

--------------------------------------------------------------------------------
-- BACKUP / MAINTENANCE

-- Backup Vault, Dotfiles, Bookmarks
M.timer_nightlyMaintenance = hs.timer
	.doAt("01:00", "01d", function()
		if os.date("%a") == "Sun" then hs.loadSpoon("EmmyLua") end

		-- GUARD
		local isSunTueThuSat = os.date("%w") % 2 == 0
		if isSunTueThuSat then return end

		-- stylua: ignore start
		M.task_bookmarksBackup = hs.task.new("./helpers/bookmark-bkp.sh", function(exitCode, _, stdErr)
			local msg = exitCode == 0 and "✅ Bookmark Backup successful" or "⚠️ Bookmark Backup failed: " .. stdErr
			u.notify(msg)
		end):start()
		M.task_dotfileBackup = hs.task.new("./helpers/dotfile-bkp.sh", function(exitCode, _, stdErr)
			local msg = exitCode == 0 and "✅ Dotfile Backup successful" or "⚠️ Dotfile Backup failed: " .. stdErr
			u.notify(msg)
		end):start()
		M.task_reminderBackup = hs.task.new("./helpers/reminders-bkp.js", function(exitCode, _, stdErr)
			local msg = exitCode == 0 and "✅ Reminder Backup successful" or "⚠️ Reminder Backup failed: " .. stdErr
			u.notify(msg)
		end):start()
		u.applescript([[tell application id "com.runningwithcrayons.Alfred" to run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"]])
		-- stylua: ignore end
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


-- Between 0:00 and 7:00, check every 10 min if device has been idle for 30
-- minutes. If so, alert and wait for another minute. If still idle then, quit
-- video apps.
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
		if not (isNight and isIdle and env.isProjector() and u.screenIsUnlocked()) then return end

		local alertMsg = ("💤 Will sleep in %ss if idle."):format(config.timeToReactSecs)
		hs.alert.show(alertMsg, 5)
		u.runWithDelays(config.timeToReactSecs, function()
			-- GUARD
			local userDidSth = hs.host.idleTime() < config.timeToReactSecs
			if userDidSth then return end

			u.closeAllFinderWins()
			u.notify("💤 SleepTimer triggered")

			-- 1. close browser tabs running YouTube (not using full name for youtube short-urls)
			-- 2. close leftover fullscreen spaces created by apps running in fullscreen
			u.closeTabsContaining("youtu")
			u.quitApps(env.videoAndAudioApps)
			closeFullscreenSpaces()
		end)
	end)
	:start()

--------------------------------------------------------------------------------
return M
