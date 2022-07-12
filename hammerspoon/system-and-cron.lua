require("menubar")
require("utils")
require("window-management")

repoSyncFrequencyMin = 15
--------------------------------------------------------------------------------

function gitSync ()
	local output, success = hs.execute('zsh "$HOME/dotfiles/git-dotfile-backup.sh"')
	if success then
		log ("dotfiles sync ✅", "$HOME/dotfiles/Cron Jobs/sync.log")
	else
		notify("⚠️️ dotfiles "..output)
		log ("dotfiles sync ⚠️: "..output, "$HOME/dotfiles/Cron Jobs/sync.log")
	end

	output, success = hs.execute('zsh "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main Vault/Meta/git vault backup.sh"')
	if success then
		log ("vault backup 🟪", "$HOME/dotfiles/Cron Jobs/sync.log")
	else
		notify("⚠️️ vault "..output)
		log ("vault backup ⚠️: "..output, "$HOME/dotfiles/Cron Jobs/sync.log")
	end
end
repoSyncTimer = hs.timer.doEvery(repoSyncFrequencyMin * 60, gitSync)
repoSyncTimer:start()

function pullsyncCallback(exitCode, stdOut, stdErr)
	if exitCode == 0 then
		notify("pull sync ✅")
		log ("pull sync ✅", "$HOME/dotfiles/Cron Jobs/sync.log")
	else
		notify("⚠️ pull sync "..stdErr)
		log ("pull sync ⚠️: "..stdErr, "$HOME/dotfiles/Cron Jobs/sync.log")
	end
end

pullSyncScript = hs.task.new(os.getenv("HOME").."/dotfiles/pull-sync-repos.sh", pullsyncCallback)
function pullSync()
	-- local output, success = hs.execute('zsh "$HOME/dotfiles/pull-sync-repos.sh"')
	-- if success then
	-- 	notify("pull sync ✅")
	-- 	log ("pull sync ✅", "$HOME/dotfiles/Cron Jobs/sync.log")
	-- else
	-- 	notify("⚠️ pull sync"..output)
	-- 	log ("pull sync ⚠️: "..output, "$HOME/dotfiles/Cron Jobs/sync.log")
	-- end
	pullSyncScript:start()
end

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

function systemShutDown (eventType)
	if not(eventType == hs.caffeinate.watcher.systemWillSleep or eventType == hs.caffeinate.watcher.systemWillPowerOff) then return end
	gitSync()
end
shutDownWatcher = hs.caffeinate.watcher.new(systemShutDown)
shutDownWatcher:start()

function systemWake (eventType)
	if not(eventType == hs.caffeinate.watcher.systemDidWake) then return end

	reloadAllMenubarItems()
	hs.shortcuts.run("Send Reminders due today to Drafts")
	if appIsRunning("Obsidian") and appIsRunning("Discord") then
		hs.urlevent.openURL("obsidian://advanced-uri?vault=Main%20Vault&commandid=obsidian-discordrpc%253Areconnect-discord")
	end

	if isIMacAtHome() then
		homeModeLayout()
	elseif isAtOffice() then
		officeModeLayout()
	end

	-- set darkmode if waking between 6:00 and 19:00
	local timeHours = hs.timer.localTime() / 60 / 60
	if timeHours < 19 and timeHours > 6 then
		setDarkmode(true)
	end

	pullSync()
end
wakeWatcher = hs.caffeinate.watcher.new(systemWake)
wakeWatcher:start()

-- redundancy: daily morning run
if isIMacAtHome() then
	dailyMorningTimer = hs.timer.doAt("06:10", "01d", function()
		setDarkmode(true)
	end, false)
	dailyMorningTimer:start()
end
