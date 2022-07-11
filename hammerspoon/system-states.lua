require("menubar")
require("utils")
require("window-management")

firstWakeOfTheDay = true
--------------------------------------------------------------------------------

repoSyncFrequencyMin = 15
function dotfileRepoGitSync ()
	local output, success = hs.execute('zsh "$HOME/Dotfiles/git-dotfile-backup.sh"')
	if not(success) then
		notify("⚠️⚠️⚠️ "..output)
		hs.execute('echo "dotfile Repo Git Sync ERROR $(date "+%Y-%m-%d %H:%M")" >> "$HOME/Dotfiles/Cron Jobs/frequent.log"')
	else
		notify ("✅ Dotfile Repo Sync successful.")
		hs.execute('echo "dotfile Repo Git Sync success $(date "+%Y-%m-%d %H:%M")" >> "$HOME/Dotfiles/Cron Jobs/frequent.log"')
	end
end
repoSyncTimer = hs.timer.doEvery(repoSyncFrequencyMin * 60, dotfileRepoGitSync)
repoSyncTimer:start()
--------------------------------------------------------------------------------

function systemWake (eventType)
	if (eventType == hs.caffeinate.watcher.systemDidWake) then return end

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

	if firstWakeOfTheDay then
		local output, success = hs.execute('zsh "$HOME/Dotfiles/pull-sync-repos.sh"')
		if not(success) then
			notify("⚠️⚠️⚠️ "..output)
		else
			notify ("✅ Pull Sync successful.")
		end
		firstWakeOfTheDay = false
	end
end
wakeWatcher = hs.caffeinate.watcher.new(systemWake)
wakeWatcher:start()

-- reset firstWake variable
firstWakeTimer = hs.timer.doAt("12:10", "12h", function()
	firstWakeOfTheDay = true
end, false)
firstWakeTimer:start()

-- redundancy: daily morning run
if isIMacAtHome() then
	hs.timer.doAt("06:10", "01d", function()
		systemWake()
		hs.execute('echo "Hammer-Morning $(date "+%Y-%m-%d %H:%M")" >> "$HOME/Dotfiles/Cron Jobs/some.log"')
	end, false)
end
