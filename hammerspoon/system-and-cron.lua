require("menubar")
require("utils")
require("window-management")
--------------------------------------------------------------------------------
-- SYNC
repoSyncFrequencyMin = 20
gitDotfileScript = os.getenv("HOME").."/dotfiles/git-dotfile-sync.sh"
gitVaultScript = os.getenv("HOME").."/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main Vault/Meta/git vault backup.sh"

function gitDotfileSync(arg)
	if arg then arg = {arg}
	else arg = {} end

	hs.task.new(gitDotfileScript, function (exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
		stdErr = stdErr:gsub("\n", " –– ")
		if exitCode == 0 then
			log ("✅ dotfiles sync ("..deviceName()..")", "./logs/sync.log")
		else
			notify("⚠️️ dotfiles "..stdErr)
			log ("⚠️ dotfiles sync ("..deviceName().."): "..stdErr, "./logs/sync.log")
		end
	end, arg):start()
end

function gitVaultBackup()
	hs.task.new(gitVaultScript, function (exitCode, _, stdErr)
		stdErr = stdErr:gsub("\n", " –– ")
		if exitCode == 0 then
			log ("🟪 vault sync ("..deviceName()..")", "./logs/sync.log")
		else
			notify("⚠️️ vault "..stdErr)
			log ("⚠️ vault sync ("..deviceName().."): "..stdErr, "./logs/sync.log")
		end
	end):start()
end


repoSyncTimer = hs.timer.doEvery(repoSyncFrequencyMin * 60, function ()
	gitDotfileSync()
	if isIMacAtHome() then gitVaultBackup() end
end)
repoSyncTimer:start()
--------------------------------------------------------------------------------

function screenSleep (eventType)
	if not(eventType == hs.caffeinate.watcher.screensDidSleep or eventType == hs.caffeinate.watcher.screensDidLock) then return end

	log ("💤 sleep ("..deviceName()..")", "./logs/sync.log")
	log ("💤 sleep ("..deviceName()..")", "./logs/some.log")
	gitDotfileSync()
end
shutDownWatcher = hs.caffeinate.watcher.new(screenSleep)
shutDownWatcher:start()

function systemWake (eventType)
	if not(eventType == hs.caffeinate.watcher.systemDidWake or eventType == hs.caffeinate.watcher.screensDidWake) then return end

	if appIsRunning("Obsidian") and appIsRunning("Discord") then
		hs.urlevent.openURL("obsidian://advanced-uri?vault=Main%20Vault&commandid=obsidian-discordrpc%253Areconnect-discord")
	end

	if isIMacAtHome() and isProjector() then movieModeLayout()
	elseif isIMacAtHome and not(isProjector()) then homeModeLayout() end

	-- set light mode if waking between 6:00 and 19:00
	local currentTimeHours = hs.timer.localTime() / 60 / 60
	if currentTimeHours < 20 and currentTimeHours > 6 then
		setDarkmode(false)
	else
		setDarkmode(true)
	end
	-- get reminders after 6:00
	if currentTimeHours > 6 then
		hs.shortcuts.run("Send Reminders due today to Drafts")
	end

	reloadAllMenubarItems()
	gitDotfileSync("wake")

	twitterrificScrollUp()
end
wakeWatcher = hs.caffeinate.watcher.new(systemWake)
wakeWatcher:start()

--------------------------------------------------------------------------------
-- OFFICE
function screenWake (eventType)
	if not(eventType == hs.caffeinate.watcher.screensDidWake or hs.caffeinate.watcher.screensaverWillStop) then return end
	officeModeLayout()
	reloadAllMenubarItems()
	gitDotfileSync("wake")
end
screenWakeWatcher = hs.caffeinate.watcher.new(screenWake)
if isAtOffice() then screenWakeWatcher:start() end

--------------------------------------------------------------------------------
-- CRONJOBS AT HOME

function sleepYouTube ()
	-- abort on delayed run
	local currentTimeHours = hs.timer.localTime() / 60 / 60
	if currentTimeHours < 2.9 and currentTimeHours > 5.1 then return end

	killIfRunning("YouTube")
	hs.osascript.applescript([[
		tell application "Brave Browser"
			if ((count of window) is not 0)
				if ((count of tab of front window) is not 0)
					set currentTabUrl to URL of active tab of front window
					if (currentTabUrl contains "youtu") then close active tab of front window
				end if
			end if
		end tell
	]])
	log ("😴 sleepTimer ("..deviceName()..")", "./logs/some.log")
end
sleepTimer = hs.timer.doAt("03:00", "01d", sleepYouTube, true)
sleepTimer2 = hs.timer.doAt("05:00", "01d", sleepYouTube, true)

biiweeklyTimer = hs.timer.doAt("02:00", "03d", function()
	hs.osascript.applescript([[
		tell application id "com.runningwithcrayons.Alfred"
			run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
			run trigger "backup-dotfiles" in workflow "de.chris-grieser.terminal-dotfiles" with argument "no sound"
		end tell
	]])
	log ("🕝2️⃣ biweekly ("..deviceName()..")", "./logs/some.log")
end, true)

catchTimer = hs.timer.doAt("02:00", "12h", function()
	openIfNotRunning("Catch")
	runDelayed(10, function () killIfRunning("Catch") end)
	log ("🫴 Catch Torrents ("..deviceName()..")", "./logs/some.log")
end, true)

dailyEveningTimer = hs.timer.doAt("21:00", "01d", function ()
	setDarkmode(true)
end)

function projectorScreensaverStop (eventType)
	if isProjector() and (eventType == hs.caffeinate.watcher.screensaverDidStop or eventType == hs.caffeinate.watcher.screensaverDidStart) then
		iMacDisplay:setBrightness(0)
	end
end
projectorScreensaverWatcher = hs.caffeinate.watcher.new(projectorScreensaverStop)

if isIMacAtHome() then
	catchTimer:start()
	dailyEveningTimer:start()
	sleepTimer:start()
	sleepTimer2:start()
	biiweeklyTimer:start()
	projectorScreensaverWatcher:start()
end

--------------------------------------------------------------------------------
-- DARK MODE
function toggleDarkMode ()
	hs.osascript.applescript([[
		if application "Brave Browser" is not running then
			launch
			delay 3
		end if
		set openBlank to false
		tell application "Brave Browser"
			if ((count of window) is 0) then
				set openBlank to true
			else
				if ((URL of active tab of front window) starts with "chrome://") then set openBlank to true
			end if
			if (openBlank)
				open location "https://example.com/"
				delay 2
			end if
		end tell

		# toggle dark mode
		tell application "System Events"
			tell appearance preferences to set dark mode to not dark mode
		end tell

		if (openBlank)
			tell application "Brave Browser" to close active tab of front window
		end if

		# Make Highlights.app get the same mode as the OS mode (if running)
		tell application "System Events"
			tell appearance preferences to set isDark to dark mode
			if (isDark is false) then
				set targetView to "Default"
			else
				set targetView to "Night"
			end if

			set highlightsRunning to ((name of processes) contains "Highlights")
			if (highlightsRunning is true) then
				tell process "Highlights"
					set frontmost to true
					click menu item targetView of menu of menu item "PDF Appearance" of menu "View" of menu bar 1
				end tell
			end if
		end tell
	]])
end

function isDarkMode()
	local _, isDark = hs.osascript.applescript('tell application "System Events" to return dark mode of appearance preferences')
	return isDark
end

function setDarkmode (toDark)
	if not(isDarkMode()) and toDark then toggleDarkMode() end
	if isDarkMode() and not(toDark) then toggleDarkMode() end
	log("🌒 Dark Mode: "..(isDarkMode()).." ("..deviceName()..")", "./logs/some.log")
end

function manualToggleDarkmode()
	toggleDarkMode()
	log ("🌒 Manual Toggle Darkmode ("..deviceName()..")", "./logs/some.log")
end

-- `hammerspoon://toggle-darkmode` for toggling via Shortcuts
hs.urlevent.bind("toggle-darkmode", function()
	manualToggleDarkmode()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)

-- f13 = del (via) karabiner elements
hotkey({}, "f13", manualToggleDarkmode)
