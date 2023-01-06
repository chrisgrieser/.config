require("lua.utils")
require("lua.window-management")
require("lua.dark-mode")
require("lua.layouts")
local caff = hs.caffeinate.watcher
local timer = hs.timer.doAt
--------------------------------------------------------------------------------

-- CONFIG
local repoSyncFreqMin = 20
local dotfileIcon = "🔵"
local vaultIcon = "🟪"
local passIcon = "🔑"

--------------------------------------------------------------------------------

-- retrieve configs from zshenv
local dotfilesFolder = getenv("DOTFILE_FOLDER")
local passwordStore = getenv("PASSWORD_STORE_DIR")
local vaultLocation = getenv("VAULT_PATH")

local gitDotfileScript = dotfilesFolder .. "/git-dotfile-sync.sh"
local gitVaultScript = vaultLocation .. "/Meta/git-vault-sync.sh"
local gitPassScript = passwordStore .. "/pass-sync.sh"

--------------------------------------------------------------------------------

local function gitDotfileSync()
	if gitDotfileSyncTask and gitDotfileSyncTask:isRunning() then return end
	if not (screenIsUnlocked()) then return end -- prevent background sync when in office

	gitDotfileSyncTask = hs.task
		.new(
			gitDotfileScript,
			function(exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
				stdErr = stdErr:gsub("\n", " –– ")
				if exitCode == 0 then
					print(dotfileIcon, "Dotfile Sync successful.")
					return
				end

				local stdout = hs.execute("git status --short")
				if not stdout then return end
				local submodulesStillDirty = stdout:match(" m ")
				if submodulesStillDirty then
					local modules = stdout:gsub(".*/", "")
					notify(dotfileIcon .. "⚠️️ dotfiles submodules still dirty\n\n" .. modules)
				else
					notify(dotfileIcon .. "⚠️️ dotfiles " .. stdErr)
				end
			end
		)
		:start()
end

local function gitVaultSync()
	if gitVaultSyncTask and gitVaultSyncTask:isRunning() then return end
	if not (screenIsUnlocked()) then return end -- prevent background sync when in office

	gitVaultSyncTask = hs.task
		.new(gitVaultScript, function(exitCode, _, stdErr)
			stdErr = stdErr:gsub("\n", " –– ")
			if exitCode == 0 then
				print(vaultIcon, "Vault Sync successful.")
				return
			end
			notify(vaultIcon .. "⚠️️ vault " .. stdErr)
		end)
		:start()
end

local function gitPassSync()
	if gitPassSyncTask and gitPassSyncTask:isRunning() then return end
	if not screenIsUnlocked() then return end -- prevent background sync when in office

	gitPassSyncTask = hs.task
		.new(gitPassScript, function(exitCode, _, stdErr)
			stdErr = stdErr:gsub("\n", " –– ")
			if exitCode == 0 then
				print(passIcon, "Password-Store Sync successful.")
				return
			end
			notify(passIcon .. "⚠️️ password-store " .. stdErr)
		end)
		:start()
end

--------------------------------------------------------------------------------

---sync all three git repos
function syncAllGitRepos()
	gitDotfileSync()
	gitPassSync()
	gitVaultSync()

	-- wait until sync is finished so sketchybar update shows success/failure
	local function updateSketchybar()
		-- https://felixkratz.github.io/SketchyBar/config/events#triggering-custom-events
		hs.execute("sketchybar --trigger repo-files-update")
		print("Updating sketchybar sync icon.")
	end
	local function noSyncInProgress()
		local dotfilesSyncing = gitDotfileSyncTask and gitDotfileSyncTask:isRunning()
		local passSyncing = gitPassSyncTask and gitPassSyncTask:isRunning()
		local vaultSyncing = gitVaultSyncTask and gitVaultSyncTask:isRunning()
		return not (dotfilesSyncing or vaultSyncing or passSyncing)
	end

	hs.timer.waitUntil(noSyncInProgress, updateSketchybar):start()
end

repoSyncTimer = hs.timer.doEvery(repoSyncFreqMin * 60, syncAllGitRepos):start()

-- manual sync for Alfred: `hammerspoon://sync-repos`
uriScheme("sync-repos", function()
	syncAllGitRepos()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)

--------------------------------------------------------------------------------

shutDownWatcher = caff
	.new(function(eventType)
		if eventType == caff.screensDidSleep then syncAllGitRepos() end
	end)
	:start()

wakeWatcher = caff
	.new(function(eventType)
		if isAtOffice() and eventType == caff.screensDidUnlock then
			syncAllGitRepos()
			officeModeLayout()
			sketchybarPopup("show")
		elseif not (isAtOffice()) and (eventType == caff.screensDidWake or eventType == caff.systemDidWake) then
			runWithDelays(1, function()
				sketchybarPopup("show")
				if isProjector() then
					setDarkmode(true)
					movieModeLayout()
				else
					syncAllGitRepos()
					local toDark = betweenTime(7, 19)
					homeModeLayout() -- should run after git sync, to avoid conflicts
					setDarkmode(toDark)
				end
			end)
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- CRONJOBS AT HOME

biweeklyTimer = timer("02:00", "02d", function()
	applescript([[
		tell application id "com.runningwithcrayons.Alfred"
			run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
			run trigger "backup-dotfiles" in workflow "de.chris-grieser.terminal-dotfiles"
		end tell
	]])
	hs.execute(
		'cp -f "$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks" "$DATA_DIR/Backups/Browser-Bookmarks.bkp"'
	)
	hs.loadSpoon("EmmyLua") -- so it runs not as often
end, true)

-- timers not local for longevity with garbage collection
dailyEveningTimer = timer("19:00", "01d", function() setDarkmode(true) end)
dailyMorningTimer = timer("08:00", "01d", function()
	if not (isProjector()) then setDarkmode(false) end
end)

projectorScreensaverWatcher = caff.new(function(eventType)
	if eventType == caff.screensaverDidStop or eventType == caff.screensaverDidStart then
		runWithDelays(2, function()
			if isProjector() then iMacDisplay:setBrightness(0) end
		end)
	end
end)

local function sleepMovieApps()
	local minutesIdle = hs.host.idleTime() / 60
	if minutesIdle < 30 then return end
	quitApp("YouTube")
	quitApp("Twitch")
	-- no need to quit IINA, since it autoquits on finishing playback
	-- no need to quit Netflix or CrunchyRoll, since they autostops
	applescript([[
		tell application "Brave Browser"
			if ((count of window) is not 0)
				if ((count of tab of front window) is not 0)
					set currentTabUrl to URL of active tab of front window
					if (currentTabUrl contains "youtu") then close active tab of front window
				end if
			end if
		end tell
	]])
end

sleepTimer0 = timer("02:00", "01d", sleepMovieApps, true)
sleepTimer1 = timer("03:00", "01d", sleepMovieApps, true)
sleepTimer2 = timer("04:00", "01d", sleepMovieApps, true)
sleepTimer3 = timer("05:00", "01d", sleepMovieApps, true)
sleepTimer4 = timer("06:00", "01d", sleepMovieApps, true)

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
