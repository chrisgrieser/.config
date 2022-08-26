require("utils")
require("window-management")
require("dark-mode")
require("layouts")

--------------------------------------------------------------------------------
-- CONFIG
dotfileLocation = os.getenv("HOME").."/dotfiles"
vaultLocation = os.getenv("HOME").."/Main Vault"
dotfileIcon ="⏺"
vaultIcon = "🟪"
repoSyncFrequencyMin = 30

--------------------------------------------------------------------------------

-- calling with "--submodules" also updates submodules
gitDotfileScript = dotfileLocation.."/git-dotfile-sync.sh"
function gitDotfileSync(arg)
	if gitDotfileSyncTask and gitDotfileSyncTask:isRunning() then return end

	gitDotfileSyncTask = hs.task.new(gitDotfileScript, function (exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
		stdErr = stdErr:gsub("\n", " –– ")
		if exitCode == 0 then
			log (dotfileIcon.." ✅ dotfiles sync ("..deviceName()..")", "./logs/sync.log")
		else
			notify(dotfileIcon.."⚠️️ dotfiles "..stdErr)
			log (dotfileIcon.."⚠️ dotfiles sync ("..deviceName().."): "..stdErr, "./logs/sync.log")
		end
	end, {arg}):start()
end

gitVaultScript = vaultLocation.."/Meta/git-vault-sync.sh"
function gitVaultSync()
	if gitVaultSyncTask and gitVaultSyncTask:isRunning() then return end

	gitVaultSyncTask = hs.task.new(gitVaultScript, function (exitCode, _, stdErr)
		stdErr = stdErr:gsub("\n", " –– ")
		if exitCode == 0 then
			log (vaultIcon.."✅ vault sync ("..deviceName()..")", "./logs/sync.log")
		else
			notify(vaultIcon.."⚠️️ vault "..stdErr)
			log (vaultIcon.."⚠️ vault sync ("..deviceName().."): "..stdErr, "./logs/sync.log")
		end
	end):start()
end

repoSyncTimer = hs.timer.doEvery(repoSyncFrequencyMin * 60, function ()
	gitDotfileSync()
	gitVaultSync()
end)
repoSyncTimer:start()

-- manual sync for Alfred: `hammerspoon://sync-repos`
hs.urlevent.bind("sync-repos", function()
	gitDotfileSync()
	gitVaultSync()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)

--------------------------------------------------------------------------------

function screenSleep (eventType)
	if not(eventType == hs.caffeinate.watcher.screensDidSleep or eventType == hs.caffeinate.watcher.screensDidLock) then return end

	log ("💤 sleep ("..deviceName()..")", "./logs/sync.log")
	log ("💤 sleep ("..deviceName()..")", "./logs/some.log")
	gitDotfileSync()
end
shutDownWatcher = hs.caffeinate.watcher.new(screenSleep)
shutDownWatcher:start()

--------------------------------------------------------------------------------
-- SYSTEM WAKE/START
function officeWake (eventType)
	if not(eventType == hs.caffeinate.watcher.screensDidWake) then return end
	officeModeLayout()
	reloadAllMenubarItems()
	gitDotfileSync("--submodules")
	gitVaultSync()
end

function homeWake (eventType)
	if not(eventType == hs.caffeinate.watcher.systemDidWake) then return end
	local currentTimeHours = hs.timer.localTime() / 60 / 60

	if isProjector() then movieModeLayout()
	else homeModeLayout() end

	if currentTimeHours < 20 and currentTimeHours > 6 then
		hs.shortcuts.run("Send Reminders due today to Drafts")
		setDarkmode(false)
	else
		setDarkmode(true)
	end

	reloadAllMenubarItems()
	gitDotfileSync("--submodules")
	gitVaultSync()

	runDelayed(1, function() twitterrificAction("scrollup") end)
end
if isIMacAtHome() or isAtMother() then
	wakeWatcher = hs.caffeinate.watcher.new(homeWake)
elseif isAtOffice() then
	wakeWatcher = hs.caffeinate.watcher.new(officeWake)
end
wakeWatcher:start()

function systemStart()
	-- prevent commit spam when updating hammerspoon config regularly
	local _, isReloading = hs.execute('[[ -e "./is-reloading" ]]')
	if isReloading then
		hs.execute("rm ./is-reloading")
		return
	else
		gitDotfileSync("--submodules")
		gitVaultSync()
	end
end

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

biweeklyTimer = hs.timer.doAt("02:00", "02d", function()
	hs.osascript.applescript([[
		tell application id "com.runningwithcrayons.Alfred"
			run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
			run trigger "backup-dotfiles" in workflow "de.chris-grieser.terminal-dotfiles" with argument "no sound"
		end tell
	]])
	log ("🕝2️⃣ biweekly ("..deviceName()..")", "./logs/some.log")
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
	dailyEveningTimer:start()
	sleepTimer:start()
	sleepTimer2:start()
	biweeklyTimer:start()
	projectorScreensaverWatcher:start()
end

if isAtMother() then
	dailyEveningTimer:start()
	sleepTimer:start()
	sleepTimer2:start()
end

