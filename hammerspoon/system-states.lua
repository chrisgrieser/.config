require("menubar")
require("utils")
require("window-management")

function systemWake (eventType)
	if (eventType == hs.caffeinate.watcher.screensDidWake) then

		reloadAllMenubarItems()
		if appIsRunning("Obsidian") and appIsRunning("Discord") then
			hs.urlevent.openURL("obsidian://advanced-uri?vault=Main%20Vault&commandid=obsidian-discordrpc%253Areconnect-discord")
		end
		if isIMacAtHome() then homeModeLayout() end
		hs.shortcuts.run("Send Reminders due today to Drafts")

		-- run darkmode toggle between 6:00 and 19:00
		local timeHours = hs.timer.localTime() / 60 / 60
		if timeHours < 19 and timeHours > 6 then
			hs.applescript ([[
				tell application "System Events"
					tell appearance preferences
						if (dark mode is true) then tell application id "com.runningwithcrayons.Alfred" to run trigger "toggle-dark-mode" in workflow "de.chris-grieser.dark-mode-toggle"
					end tell
				end tell
			]])
		end

	end
end
wakeWatcher = hs.caffeinate.watcher.new(systemWake)
wakeWatcher:start()

-- redundancy
hs.timer.doAt("06:10", "01d", function()
	systemWake()
	if not(isIMacAtHome()) then return end

	hs.execute("echo Hammer-Morning\\ $(date '+%Y-%m-%d %H:%M') >> '/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/Cron Jobs/some.log'")
end, false)
