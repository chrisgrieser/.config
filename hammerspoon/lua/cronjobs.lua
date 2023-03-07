require("lua.utils")
require("lua.window-management")
require("lua.dark-mode")
require("lua.layouts")
local caff = hs.caffeinate.watcher
--------------------------------------------------------------------------------

UnlockWatcher = caff
	.new(function(event)
		if event ~= caff.screensDidUnlock then return end
		SyncAllGitRepos()
		RunWithDelays(0.5, SelectLayout)
	end)
	:start()

-- keep the iMac display brightness low when projector is connected
ProjectorScreensaverWatcher = caff
	.new(function(eventType)
		if IsAtOffice() then return end
		if eventType == caff.screensaverDidStop or eventType == caff.screensaverDidStart then
			RunWithDelays(1, function()
				if IsProjector() then IMacDisplay:setBrightness(0) end
			end)
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- BACKUP / MAINTENANCE

-- Backup Vault, Dotfiles, Bookmarks, and browser extension list
-- Reload Hammerspoon Annotations (Emmylua Spoon)
-- Check for low battery of connected bluetooth devices
BiweeklyTimer = hs.timer
	.doAt("02:00", "02d", function()
		if IsAtOffice() then return end

		PeripheryBatteryCheck("Drafts")
		hs.loadSpoon("EmmyLua")
		Applescript([[
			tell application id "com.runningwithcrayons.Alfred"
				run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
				run trigger "backup-dotfiles" in workflow "de.chris-grieser.terminal-dotfiles"
			end tell
		]])
		hs.execute(
			'cp -f "$HOME/Library/Application Support/Vivaldi/Default/Bookmarks" "$DATA_DIR/Backups/Browser-Bookmarks.bkp"'
		)
		hs.execute([[
			ls -1 "$HOME/Library/Application Support/Vivaldi/Default/Extensions/" |
			sed "s|^|https://chrome.google.com/webstore/detail/|" \
			> "$DOTFILE_FOLDER/browser-extension-configs/list-of-extensions.txt"
		]])
	end, true)
	:start()

--------------------------------------------------------------------------------

local function sleepMovieApps()
	local minutesIdle = hs.host.idleTime() / 60
	if minutesIdle < 30 then return end

	-- no need to quit IINA it autoquits
	QuitApp { "YouTube", "Twitch", "CrunchyRoll", "Netflix" }

	-- close browser tabs running YouTube
	Applescript([[
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

if IsIMacAtHome() or IsAtMother() then
	-- yes my sleep rhythm is abnormal
	SleepTimer0 = hs.timer.doAt("02:00", "01d", sleepMovieApps, true):start()
	SleepTimer1 = hs.timer.doAt("03:00", "01d", sleepMovieApps, true):start()
	SleepTimer2 = hs.timer.doAt("04:00", "01d", sleepMovieApps, true):start()
	SleepTimer3 = hs.timer.doAt("05:00", "01d", sleepMovieApps, true):start()
	SleepTimer4 = hs.timer.doAt("06:00", "01d", sleepMovieApps, true):start()
end
