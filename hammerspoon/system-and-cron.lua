require("menubar")
require("utils")
require("window-management")
--------------------------------------------------------------------------------
-- SYNC
repoSyncFrequencyMin = 15
gitDotfileScript = os.getenv("HOME").."/dotfiles/git-dotfile-sync.sh"
gitVaultScript = os.getenv("HOME").."/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main Vault/Meta/git vault backup.sh"

function gitDotfileSync(arg)
	if arg then arg = {arg}
	else arg = {} end

	hs.task.new(gitDotfileScript, function (exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
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
		if exitCode == 0 then
			log ("🟪 vault sync ("..deviceName()..")", "./logs/sync.log")
		else
			notify("⚠️️ vault "..stdErr)
			log ("⚠️ vault sync ("..deviceName().."): "..stdErr, "./logs/sync.log")
		end
	end):start()
end

--------------------------------------------------------------------------------
-- TRIGGERS

repoSyncTimer = hs.timer.doEvery(repoSyncFrequencyMin * 60, function ()
	gitDotfileSync()
	if isIMacAtHome() then gitVaultBackup() end
end)
repoSyncTimer:start()

function screenSleep (eventType)
	if not(eventType == hs.caffeinate.watcher.screensDidSleep or eventType == hs.caffeinate.watcher.screensDidLock) then return end

	log ("💤 sleep ("..deviceName()..")", "./logs/sync.log")
	log ("💤 sleep ("..deviceName()..")", "./logs/some.log")
	gitDotfileSync()
end
shutDownWatcher = hs.caffeinate.watcher.new(screenSleep)
shutDownWatcher:start()

function systemWake (eventType)
	if not(eventType == hs.caffeinate.watcher.systemDidWake) then return end

	if isIMacAtHome() and isProjector() then movieModeLayout()
	elseif isIMacAtHome and not(isProjector()) then homeModeLayout() end

	-- set light mode if waking between 6:00 and 19:00
	local currentTimeHours = hs.timer.localTime() / 60 / 60
	if currentTimeHours < 19 and currentTimeHours > 6 then
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
end
wakeWatcher = hs.caffeinate.watcher.new(systemWake)
wakeWatcher:start()

-- Office Wake
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

biiweeklyTimer = hs.timer.doAt("05:00", "03d", function()
	hs.osascript.applescript([[
		tell application id "com.runningwithcrayons.Alfred"
			run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
			run trigger "backup-dotfiles" in workflow "de.chris-grieser.terminal-dotfiles" with argument "no sound"
			run trigger "re-index-doc-search" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
		end tell
	]])
	log ("2️⃣ biweekly ("..deviceName()..")", "./logs/some.log")
end, true)

dailyMorningTimer = hs.timer.doAt("06:30", "01d", function()
	setDarkmode(false)
	openIfNotRunning("Catch")
	runDelayed(10, function () killIfRunning("Catch") end)
	log ("🌻 daily morning ("..deviceName()..")", "./logs/some.log")
end, true)

if isIMacAtHome() then
	dailyMorningTimer:start()
	sleepTimer:start()
	sleepTimer2:start()
	biiweeklyTimer:start()
end
