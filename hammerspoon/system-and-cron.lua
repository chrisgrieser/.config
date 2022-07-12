require("menubar")
require("utils")
require("window-management")

firstWakeOfTheDay = true
--------------------------------------------------------------------------------

repoSyncFrequencyMin = 15
function gitSync ()
	local output1, success1 = hs.execute('zsh "$HOME/dotfiles/git-dotfile-backup.sh"')
	if success1 then
		notify("dotfiles sync ✅")
		log ("dotfiles sync ✅", "$HOME/dotfiles/Cron Jobs/sync.log")
	else
		notify("⚠️️ dotfiles"..output1)
		log ("dotfiles sync ⚠️: "..output1, "$HOME/dotfiles/Cron Jobs/sync.log")
	end

	local output2, success2 = hs.execute('zsh "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main Vault/Meta/git vault backup.sh"')
	if success2 then
		notify("vault backup 🟪")
		log ("vault backup 🟪", "$HOME/dotfiles/Cron Jobs/sync.log")
	else
		notify("⚠️️ vault"..output2)
		log ("vault backup ⚠️: "..output2, "$HOME/dotfiles/Cron Jobs/sync.log")
	end
end
repoSyncTimer = hs.timer.doEvery(repoSyncFrequencyMin * 60, gitSync)
repoSyncTimer:start()

function pullSync()
	local output, success = hs.execute('zsh "$HOME/dotfiles/pull-sync-repos.sh"')
	if success then
		notify("pull sync ✅")
		log ("pull sync ✅", "$HOME/dotfiles/Cron Jobs/sync.log")
	else
		notify("⚠️ "..output)
		log ("pull sync ⚠️: "..output, "$HOME/dotfiles/Cron Jobs/sync.log")
	end
end

--------------------------------------------------------------------------------

function systemShutDown (eventType)
	if not(eventType == hs.caffeinate.watcher.systemWillSleep or eventType == hs.caffeinate.watcher.systemWillPowerOff) then return end
	dotfileRepoGitSync()
	firstWakeOfTheDay = true
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

	-- run darkmode toggle between 6:00 and 19:00
	local timeHours = hs.timer.localTime() / 60 / 60
	if timeHours < 19 and timeHours > 6 then
		hs.osascript.applescript([[
			tell application "System Events"
				tell appearance preferences
					if (dark mode is true) then tell application id "com.runningwithcrayons.Alfred" to run trigger "toggle-dark-mode" in workflow "de.chris-grieser.dark-mode-toggle"
				end tell
			end tell
		]])
	end

	pullSync()
end
wakeWatcher = hs.caffeinate.watcher.new(systemWake)
wakeWatcher:start()

-- redundancy: daily morning run
if isIMacAtHome() then
	dailyMorningTimer = hs.timer.doAt("06:10", "01d", function()
		systemWake()
		log("Hammer-Morning ✅", "$HOME/dotfiles/Cron Jobs/some.log")
	end, false)
	dailyMorningTimer:start()
end
