require("utils")
require("window-management")
require("dark-mode")
require("layouts")

--------------------------------------------------------------------------------
-- CONFIG
dotfileLocation = home.."/dotfiles"
vaultLocation = home.."/Main Vault"
gitDotfileScript = dotfileLocation.."/git-dotfile-sync.sh"
gitVaultScript = vaultLocation.."/Meta/git-vault-sync.sh"
dotfileIcon ="⏺"
vaultIcon = "🟪"
repoSyncFrequencyMin = 30

--------------------------------------------------------------------------------

-- calling with "--submodules" also updates submodules
function gitDotfileSync(arg)
	if gitDotfileSyncTask and gitDotfileSyncTask:isRunning() then return end

	gitDotfileSyncTask = hs.task.new(gitDotfileScript, function (exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
		stdErr = stdErr:gsub("\n", " –– ")
		if exitCode ~= 0 then
			local stdout = hs.execute("git status --short")
			local submodulesStillDirty = stdout:match(" m ")
			if submodulesStillDirty then
				local modules = stdout:gsub(".*/", "")
				notify(dotfileIcon.."⚠️️ dotfiles submodules still dirty\n\n"..modules)
				log(dotfileIcon.." ⚠️️ dotfiles submodules still dirty ("..deviceName().."):\n"..modules)
			else
				notify(dotfileIcon.."⚠️️ dotfiles "..stdErr)
				log (dotfileIcon.." ⚠️ dotfiles sync ("..deviceName().."): "..stdErr, "./logs/sync.log")
			end
		end
	end, {arg}):start()
end

function gitVaultSync()
	if gitVaultSyncTask and gitVaultSyncTask:isRunning() then return end

	gitVaultSyncTask = hs.task.new(gitVaultScript, function (exitCode, _, stdErr)
		stdErr = stdErr:gsub("\n", " –– ")
		if exitCode ~= 0 then
			notify(vaultIcon.."⚠️️ vault "..stdErr)
			log (vaultIcon.." ⚠️ vault sync ("..deviceName().."): "..stdErr, "./logs/sync.log")
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


-- update icons for sketchybar
function updateSketchybar()
	hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; sketchybar --trigger repo-files-update")
end
dotfilesWatcher = hs.pathwatcher.new(dotfileLocation, updateSketchybar)
dotfilesWatcher:start()
vaultWatcher = hs.pathwatcher.new(vaultLocation, updateSketchybar)
vaultWatcher:start()

--------------------------------------------------------------------------------

function screenSleep (eventType)
	if eventType == hs.caffeinate.watcher.screensDidSleep then
		log ("💤 sleep ("..deviceName()..")", "./logs/some.log")
		gitDotfileSync()
	end
end
shutDownWatcher = hs.caffeinate.watcher.new(screenSleep)
shutDownWatcher:start()

--------------------------------------------------------------------------------
-- SYSTEM WAKE/START
function officeWake (eventType)
	if eventType == hs.caffeinate.watcher.screensDidUnlock then
		gitDotfileSync("--submodules")
		gitVaultSync()
		officeModeLayout() ---@diagnostic disable-line: undefined-global
	end
end

function homeWake (eventType)
	local function loggedIn()
		return hs.caffeinate.sessionProperties().kCGSessionLoginDoneKey
	end
	local screensWoke = eventType == hs.caffeinate.watcher.screensDidWake
	local systemWokeUp = eventType == hs.caffeinate.watcher.systemDidWake
	local currentTimeHours = hs.timer.localTime() / 60 / 60

	if systemWokeUp or screensWoke then
		hs.timer.waitUntil(loggedIn, function ()
			if currentTimeHours < 19 and currentTimeHours > 7 then
				hs.shortcuts.run("Send Reminders due today to Drafts")
				if not(isProjector()) then setDarkmode(false) end
			else
				setDarkmode(true)
			end
			gitDotfileSync("--submodules")
			gitVaultSync()

			-- should run after git sync, to avoid conflicts
			if isProjector() then movieModeLayout() ---@diagnostic disable-line: undefined-global
			else homeModeLayout() end ---@diagnostic disable-line: undefined-global
		end):start()

	end
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
	local minutesIdle = hs.host.idleTime() / 60
	if minutesIdle < 30 then return end

	killIfRunning("YouTube")
	killIfRunning("Twitch")
	-- no need to quit IINA, since it autoquits on finishing playback
	-- Netflix also automatically stops after some idle time
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
sleepTimer1 = hs.timer.doAt("03:00", "01d", sleepYouTube, true)
sleepTimer2 = hs.timer.doAt("04:00", "01d", sleepYouTube, true)
sleepTimer3 = hs.timer.doAt("05:00", "01d", sleepYouTube, true)

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

dailyMorningTimer = hs.timer.doAt("08:00", "01d", function ()
	setDarkmode(false)
end)

function projectorScreensaverStop (eventType)
	if isProjector() and (eventType == hs.caffeinate.watcher.screensaverDidStop or eventType == hs.caffeinate.watcher.screensaverDidStart) then
		iMacDisplay:setBrightness(0)
	end
end
projectorScreensaverWatcher = hs.caffeinate.watcher.new(projectorScreensaverStop)

if isIMacAtHome() then
	dailyMorningTimer:start()
	dailyEveningTimer:start()
	sleepTimer1:start()
	sleepTimer2:start()
	sleepTimer3:start()
	biweeklyTimer:start()
	projectorScreensaverWatcher:start()
end

if isAtMother() then
	dailyMorningTimer:start()
	dailyEveningTimer:start()
	sleepTimer1:start()
	sleepTimer2:start()
	sleepTimer3:start()
end

