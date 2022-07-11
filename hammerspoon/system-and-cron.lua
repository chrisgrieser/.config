require("menubar")
require("utils")
require("window-management")

firstWakeOfTheDay = true
--------------------------------------------------------------------------------

repoSyncFrequencyMin = 15
function dotfileRepoGitSync ()
	local output, success = hs.execute('zsh "$HOME/Dotfiles/git-dotfile-backup.sh"')
	if success then
		notify("dotfile sync ✅")
		log ("dotfile sync ✅", "$HOME/Dotfiles/Cron Jobs/frequent.log")
	else
		notify("⚠️️ "..output)
		log ("dotfile sync ⚠️: "..output, "$HOME/Dotfiles/Cron Jobs/frequent.log")
	end
end
repoSyncTimer = hs.timer.doEvery(repoSyncFrequencyMin * 60, dotfileRepoGitSync)
repoSyncTimer:start()

function pullSync()
	local output, success = hs.execute('zsh "$HOME/Dotfiles/pull-sync-repos.sh"')
	if not(success) then
		notify("⚠️ "..output)
	else
		notify("✅ pull sync success")
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
		log("Hammer-Morning ✅", "$HOME/Dotfiles/Cron Jobs/some.log")
	end, false)
	dailyMorningTimer:start()
end
