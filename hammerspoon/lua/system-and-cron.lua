require("lua.utils")
require("lua.window-management")
require("lua.dark-mode")
require("lua.layouts")
local caff = hs.caffeinate.watcher
local timer = hs.timer.doAt

--------------------------------------------------------------------------------

-- CONFIG
local gitDotfileScript = dotfilesFolder .. "/git-dotfile-sync.sh"
local gitVaultScript = vaultLocation .. "/Meta/git-vault-sync.sh"
local dotfileIcon = "🔵"
local vaultIcon = "🟪"
local repoSyncFrequencyMin = 20

--------------------------------------------------------------------------------

-- calling with "--submodules" also updates submodules
function gitDotfileSync(arg)
	if gitDotfileSyncTask and gitDotfileSyncTask:isRunning() then return end
	if not(screenIsUnlocked()) then return end -- prevent background sync when in office

	gitDotfileSyncTask = hs.task.new(gitDotfileScript,
		function(exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
			stdErr = stdErr:gsub("\n", " –– ")
			if exitCode ~= 0 then
				local stdout = hs.execute("git status --short")
				if not (stdout) then return end
				local submodulesStillDirty = stdout:match(" m ")
				if submodulesStillDirty then
					local modules = stdout:gsub(".*/", "")
					notify(dotfileIcon .. "⚠️️ dotfiles submodules still dirty\n\n" .. modules)
				else
					notify(dotfileIcon .. "⚠️️ dotfiles " .. stdErr)
				end
			else
				print("Dotfile Sync successful.")
			end
		end, {arg}):start()
end

function gitVaultSync()
	if gitVaultSyncTask and gitVaultSyncTask:isRunning() then return end
	if not(screenIsUnlocked()) then return end -- prevent background sync when in office

	gitVaultSyncTask = hs.task.new(gitVaultScript, function(exitCode, _, stdErr)
		stdErr = stdErr:gsub("\n", " –– ")
		if exitCode ~= 0 then
			notify(vaultIcon .. "⚠️️ vault " .. stdErr)
		else
			print("Dotfile Sync successful.")
		end
	end):start()
end

repoSyncTimer = hs.timer.doEvery(repoSyncFrequencyMin * 60, function()
	gitDotfileSync()
	gitVaultSync()
end)
repoSyncTimer:start()

-- manual sync for Alfred: `hammerspoon://sync-repos`
uriScheme("sync-repos", function()
	gitDotfileSync()
	gitVaultSync()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)


-- update icons for sketchybar
local function updateSketchybar()
	hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; sketchybar --trigger repo-files-update")
end

dotfilesWatcher = hs.pathwatcher.new(dotfilesFolder, updateSketchybar)
dotfilesWatcher:start()
vaultWatcher = hs.pathwatcher.new(vaultLocation, updateSketchybar)
vaultWatcher:start()

--------------------------------------------------------------------------------

local function screenSleep(eventType)
	if eventType == caff.screensDidSleep then
		gitDotfileSync()
	end
end

shutDownWatcher = caff.new(screenSleep)
shutDownWatcher:start()

--------------------------------------------------------------------------------
-- SYSTEM WAKE/START
local function officeWake(eventType)
	if eventType == caff.screensDidUnlock then
		gitDotfileSync("--submodules")
		gitVaultSync()
		officeModeLayout()
	end
end

local function homeWake(eventType)
	runDelayed(2, function()
		if not (eventType == caff.screensDidWake or eventType == caff.systemDidWake) then return end

		if isProjector() then
			setDarkmode(true)
			movieModeLayout()
		else
			if betweenTime(7, 19) then
				setDarkmode(false)
			else
				setDarkmode(true)
			end
			gitDotfileSync("--submodules")
			gitVaultSync()
			homeModeLayout() -- should run after git sync, to avoid conflicts
		end

	end)
end

if isIMacAtHome() or isAtMother() then
	wakeWatcher = caff.new(homeWake)
elseif isAtOffice() then
	wakeWatcher = caff.new(officeWake)
end
wakeWatcher:start()

function systemStart()
	-- prevent commit spam when updating hammerspoon config regularly
	local _, isReloading = hs.execute('[[ -e "./is-reloading" ]]')
	if isReloading then
		hs.execute("rm ./is-reloading")
		notify("Config reloaded.")
	else
		if app("Finder") then app("Finder"):kill() end
		notify("Hammerspoon started.")
		gitDotfileSync("--submodules")
		gitVaultSync()
		notify("Sync finished.")
	end
end

--------------------------------------------------------------------------------
-- CRONJOBS AT HOME
-- timers not local for longevity with garbage collection
local function bkp()
	applescript [[
		tell application id "com.runningwithcrayons.Alfred"
			run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
			run trigger "backup-dotfiles" in workflow "de.chris-grieser.terminal-dotfiles" with argument "no sound"
		end tell
	]]
	hs.execute('cp -f "$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks" "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Backups/"')
	hs.loadSpoon("EmmyLua") -- so it runs not as often
end

biweeklyTimer = timer("02:00", "01d", bkp, true)

dailyEveningTimer = timer("19:00", "01d", function() setDarkmode(true) end)
dailyMorningTimer = timer("08:00", "01d", function()
	if not (isProjector()) then
		setDarkmode(false)
	end
end)

local function projectorScreensaverStop(eventType)
	if (eventType == caff.screensaverDidStop or eventType == caff.screensaverDidStart) then
		runDelayed(3, function()
			if isProjector() then
				iMacDisplay:setBrightness(0)
			end
		end)
	end
end

projectorScreensaverWatcher = caff.new(projectorScreensaverStop)

local function sleepYouTube()
	local minutesIdle = hs.host.idleTime() / 60
	if minutesIdle < 30 then return end

	killIfRunning("YouTube")
	killIfRunning("Twitch")
	killIfRunning("Netflix")
	-- no need to quit IINA, since it autoquits on finishing playback
	applescript [[
		tell application "Brave Browser"
			if ((count of window) is not 0)
				if ((count of tab of front window) is not 0)
					set currentTabUrl to URL of active tab of front window
					if (currentTabUrl contains "youtu") then close active tab of front window
				end if
			end if
		end tell
	]]
end

sleepTimer0 = timer("02:00", "01d", sleepYouTube, true)
sleepTimer1 = timer("03:00", "01d", sleepYouTube, true)
sleepTimer2 = timer("04:00", "01d", sleepYouTube, true)
sleepTimer3 = timer("05:00", "01d", sleepYouTube, true)
sleepTimer4 = timer("06:00", "01d", sleepYouTube, true)

--------------------------------------------------------------------------------

if isIMacAtHome() or isAtMother() then
	dailyMorningTimer:start()
	dailyEveningTimer:start()
	sleepTimer0:start()
	sleepTimer1:start()
	sleepTimer2:start()
	sleepTimer3:start()
	sleepTimer4:start()
	if isIMacAtHome() then
		biweeklyTimer:start()
		projectorScreensaverWatcher:start()
	end
end
