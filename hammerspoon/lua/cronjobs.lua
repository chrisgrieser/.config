require("lua.utils")
require("lua.window-utils")
require("lua.dark-mode")
require("lua.layouts")
local caff = hs.caffeinate.watcher

---@return string three-char string representing the day of the week (English)
local function getWeekday() return tostring(os.date()):sub(1, 3) end

--------------------------------------------------------------------------------

-- keep the iMac display brightness low when projector is connected
ProjectorScreensaverWatcher = caff
	.new(function(event)
		if u.isAtOffice() then return end
		if
			event == caff.screensaverDidStop
			or event == caff.screensaverDidStart
			or event == caff.screensDidWake
			or event == caff.systemDidWake
			or event == caff.screensDidSleep
		then
			u.runWithDelays(1, function()
				if u.isProjector() then IMacDisplay:setBrightness(0) end
			end)
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- BACKUP / MAINTENANCE

-- on Mondays shortly before 10:00, open #fg-organisation Slack Channel
JourfixeTimer = hs.timer
	.doAt("09:59", "01d", function()
		if getWeekday() ~= "Mon" then return end
		hs.execute("open 'slack://channel?team=T010A5PEMBQ&id=CV95T641Y'")
	end)
	:start()

-- Backup Vault, Dotfiles, Bookmarks, and browser extension list
-- Reload Hammerspoon Annotations (Emmylua Spoon)
-- Check for low battery of connected bluetooth devices
BiweeklyTimer = hs.timer
	.doAt("02:00", "01d", function()
		if u.isAtOffice() or (getWeekday() ~= "Wed" and getWeekday() ~= "Sat") then return end

		PeripheryBatteryCheck("SideNotes")
		hs.loadSpoon("EmmyLua")

		-- backups
		-- stylua: ignore start
		local isodate = os.date("%Y-%m-%d")
		hs.execute( 'cp -f "$HOME/Library/Application Support/Vivaldi/Default/Bookmarks" "$DATA_DIR/Backups/Browser-Bookmarks/' .. isodate .. "'")
		hs.task.new("./helpers/dotfile-bkp.sh", function(exitCode, _, stdErr)
			local msg = exitCode == 0 and "✅ Dotfile Backup successful." or "⚠️ Dotfile Backup failed: " .. stdErr
			u.notify(msg)
		end)
		u.applescript( [[ tell application id "com.runningwithcrayons.Alfred" to run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound" end tell ]])

		-- stylua: ignore end
	end, true)
	:start()

--------------------------------------------------------------------------------

local function closeFullscreenSpaces()
	local allSpaces = hs.spaces.allSpaces()
	if not allSpaces then return end
	for _, spaces in pairs(allSpaces) do
		for _, spaceId in pairs(spaces) do
			if hs.spaces.spaceType(spaceId) == "fullscreen" then
				hs.spaces.removeSpace(spaceId)
			end
		end	
	end
end

local function sleepMovieApps()
	if not u.idleMins(30) then return end

	-- no need to quit IINA since it autoquits
	u.quitApp { "YouTube", "Twitch", "CrunchyRoll", "Netflix", "Tagesschau" }

	-- close leftover fullscreen spaces
	closeFullscreenSpaces()

	-- close browser tabs running YouTube
	u.applescript([[
		tell application "Vivaldi"
			if ((count of window) is not 0)
				if ((count of tab of front window) is not 0)
					set currentTabUrl to URL of active tab of front window
					if (currentTabUrl contains "youtu") then close active tab of front window
				end if
			end if
		end tell
	]])
end

if u.isAtHome() or u.isAtMother() then
	-- yes my sleep rhythm is abnormal
	SleepTimer0 = hs.timer.doAt("02:00", "01h", sleepMovieApps, true):start()
	SleepTimer1 = hs.timer.doAt("03:00", "01d", sleepMovieApps, true):start()
	SleepTimer2 = hs.timer.doAt("04:00", "01d", sleepMovieApps, true):start()
	SleepTimer3 = hs.timer.doAt("05:00", "01d", sleepMovieApps, true):start()
	SleepTimer4 = hs.timer.doAt("06:00", "01d", sleepMovieApps, true):start()
end
