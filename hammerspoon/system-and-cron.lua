require("menubar")
require("utils")
require("window-management")

repoSyncFrequencyMin = 15
--------------------------------------------------------------------------------

function gitDotfileSyncCallback(exitCode, _, stdErr)
	if exitCode == 0 then
		log ("dotfiles sync ("..deviceName()..") ✅", "$HOME/dotfiles/Cron Jobs/sync.log")
	else
		notify("⚠️️ dotfiles "..stdErr)
		log ("dotfiles sync ("..deviceName()..") ⚠️: "..stdErr, "$HOME/dotfiles/Cron Jobs/sync.log")
	end
end
gitDotfileSync = hs.task.new(os.getenv("HOME").."/dotfiles/git-dotfile-backup.sh", gitDotfileSyncCallback)

function gitVaultBackupCallback(exitCode, _, stdErr)
	if exitCode == 0 then
		log ("vault backup 🟪", "$HOME/dotfiles/Cron Jobs/sync.log")
	else
		notify("⚠️️ vault "..stdErr)
		log ("vault backup ⚠️: "..stdErr, "$HOME/dotfiles/Cron Jobs/sync.log")
	end
end
gitVaultBackup = hs.task.new(os.getenv("HOME").."/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main Vault/Meta/git vault backup.sh", gitVaultBackupCallback)

repoSyncTimer = hs.timer.doEvery(repoSyncFrequencyMin * 60, function ()
	if not gitDotfileSync:isRunning() then gitDotfileSync:start() end
	if isIMacAtHome() and (not gitVaultBackup:isRunning()) then gitVaultBackup:start() end
end)
repoSyncTimer:start()

function pullsyncCallback(exitCode, _, stdErr)
	if exitCode == 0 then
		log ("pull sync ("..deviceName()..") ✅", "$HOME/dotfiles/Cron Jobs/sync.log")
	else
		notify("⚠️ pull sync "..stdErr)
		log ("pull sync ("..deviceName()..") ⚠️: "..stdErr, "$HOME/dotfiles/Cron Jobs/sync.log")
	end
end
pullSync = hs.task.new(os.getenv("HOME").."/dotfiles/pull-sync-repos.sh", pullsyncCallback)

--------------------------------------------------------------------------------

function setDarkmode (toDark)
	local darkStr
	if toDark then darkStr = "true"
	else darkStr = "false" end
	hs.osascript.applescript([[
		tell application "System Events"
			tell appearance preferences
				if (dark mode is not ]]..darkStr..[[) then tell application id "com.runningwithcrayons.Alfred" to run trigger "toggle-dark-mode" in workflow "de.chris-grieser.dark-mode-toggle"
			end tell
		end tell
	]])
	log("Dark Mode: "..darkStr, "$HOME/dotfiles/Cron Jobs/some.log")
end

-- these watchers aren't super reliable though :(
function systemShutDown (eventType)
	if not(eventType == hs.caffeinate.watcher.systemWillSleep or eventType == hs.caffeinate.watcher.systemWillPowerOff or eventType == hs.caffeinate.watcher.screensDidSleep or eventType == hs.caffeinate.watcher.screensDidLock) then return end
	if gitDotfileSync:isRunning() then return end
	gitDotfileSync:start()
	gitDotfileSync:waitUntilExit()
end
shutDownWatcher = hs.caffeinate.watcher.new(systemShutDown)
shutDownWatcher:start()

hotkey(hyper, "end", function ()
	if gitDotfileSync:isRunning() then
		notify("currently syncing…")
		return
	end
	gitDotfileSync:start()
	gitDotfileSync:waitUntilExit()
	notify("✅ dotfiles sync")
end)

function systemWake (eventType)
	if not(eventType == hs.caffeinate.watcher.systemDidWake) then return end

	reloadAllMenubarItems()
	hs.shortcuts.run("Send Reminders due today to Drafts")
	if appIsRunning("Obsidian") and appIsRunning("Discord") then
		hs.urlevent.openURL("obsidian://advanced-uri?vault=Main%20Vault&commandid=obsidian-discordrpc%253Areconnect-discord")
	end

	if isIMacAtHome() then homeModeLayout()
	elseif isAtOffice() then officeModeLayout() end

	-- set darkmode if waking between 6:00 and 19:00
	local timeHours = hs.timer.localTime() / 60 / 60
	if timeHours < 19 and timeHours > 6 then
		setDarkmode(false)
	end

	pullSync:start()
end
wakeWatcher = hs.caffeinate.watcher.new(systemWake)
wakeWatcher:start()

-- redundancy: daily morning run
if isIMacAtHome() then
	dailyMorningTimer = hs.timer.doAt("06:10", "01d", function()
		setDarkmode(false)
	end, false)
	dailyMorningTimer:start()
end
