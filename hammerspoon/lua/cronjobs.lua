local u = require("lua.utils")
local wu = require("lua.window-utils")
local c = hs.caffeinate.watcher
local env = require("lua.environment-vars")

---@return string three chars representing the day of the week (English)
local function getWeekday() return tostring(os.date()):sub(1, 3) end

--------------------------------------------------------------------------------

-- keep the iMac display brightness low when projector is connected
ProjectorScreensaverWatcher = c
	.new(function(event)
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
	end)
	:start()

--------------------------------------------------------------------------------
-- BACKUP / MAINTENANCE

-- on Mondays shortly before 10:00, open #fg-organisation Slack Channel
JourfixeTimer = hs.timer
	.doAt("09:59", "01d", function()
		if not (getWeekday() == "Mon" and u.screenIsUnlocked()) then return end
		hs.execute("open 'slack://channel?team=T010A5PEMBQ&id=CV95T641Y'")
		hs.alert.show("Jour Fix" .. "e")
	end)
	:start()

-- SOME MAINTENANCE TASKS
-- - Backup Vault, Dotfiles, Bookmarks, & browser extension list
-- - Reload Hammerspoon Annotations (EmmyLua Spoon)
-- - Check for low battery of connected bluetooth devices
BiweeklyTimer = hs.timer
	.doAt("02:00", "01d", function()
		if env.isAtOffice or (getWeekday() ~= "Wed" and getWeekday() ~= "Sat") then return end

		hs.loadSpoon("EmmyLua")

		-- BACKUPS
		-- stylua: ignore start
		hs.task.new("./helpers/bookmark-bkp.sh", function(exitCode, _, stdErr)
			local msg = exitCode == 0 and "✅ Bookmark Backup successful." or "⚠️ Bookmark Backup failed: " .. stdErr
			u.notify(msg)
		end):start()
		hs.task.new("./helpers/dotfile-bkp.sh", function(exitCode, _, stdErr)
			local msg = exitCode == 0 and "✅ Dotfile Backup successful." or "⚠️ Dotfile Backup failed: " .. stdErr
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

---@nodiscard
---whether device has been idle
---@param mins number Time idle
---@return boolean
local function idleMins(mins)
	local minutesIdle = hs.host.idleTime() / 60
	return minutesIdle > mins
end

-- Between 1:00 and 6:00, check every 10 min if device has been idle for 40
-- minutes. If so, alert and wait for another minute. If still idle then, quit
-- video apps.
SleepTimer = hs.timer
	.doEvery(10 * 60, function()
		if not (u.betweenTime(1, 6) and idleMins(40) and env.isProjector() and u.screenIsUnlocked()) then return end
		hs.alert.show("💤 SleepTimer in 1 min if idle.")

		u.runWithDelays(61, function()
			if not idleMins(1) then return end
			u.notify("💤 SleepTimer triggered.")

			-- 1. no need to quit IINA since it autoquits
			-- 2. close browser tabs running YouTube (not using full name for youtube short-urls)
			-- 3. close leftover fullscreen spaces created by apps running in fullscreen
			u.quitApp { "YouTube", "Twitch", "CrunchyRoll", "Netflix", "Tagesschau" }
			u.closeTabsContaining("youtu")
			closeFullscreenSpaces()
		end)
	end)
	:start()
