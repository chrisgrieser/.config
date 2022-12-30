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

-- calling with "--submodules" also updates submodules
local function gitDotfileSync(arg)
	if gitDotfileSyncTask and gitDotfileSyncTask:isRunning() then return end
	if not (screenIsUnlocked()) then return end -- prevent background sync when in office

	gitDotfileSyncTask = hs.task
		.new(
			gitDotfileScript,
			function(exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
				stdErr = stdErr:gsub("\n", " –– ")
				if exitCode == 0 then return end
				local stdout = hs.execute("git status --short")
				if not stdout then return end
				local submodulesStillDirty = stdout:match(" m ")
				if submodulesStillDirty then
					local modules = stdout:gsub(".*/", "")
					notify(dotfileIcon .. "⚠️️ dotfiles submodules still dirty\n\n" .. modules)
				else
					notify(dotfileIcon .. "⚠️️ dotfiles " .. stdErr)
				end
			end,
			{ arg }
		)
		:start()
end

local function gitVaultSync()
	if gitVaultSyncTask and gitVaultSyncTask:isRunning() then return end
	if not (screenIsUnlocked()) then return end -- prevent background sync when in office

	gitVaultSyncTask = hs.task
		.new(gitVaultScript, function(exitCode, _, stdErr)
			stdErr = stdErr:gsub("\n", " –– ")
			if exitCode ~= 0 then
				notify(vaultIcon .. "⚠️️ vault " .. stdErr)
			else
				print("Vault Sync successful.")
			end
		end)
		:start()
end

local function gitPassSync()
	if gitpassSync and gitpassSync:isRunning() then return end
	if not (screenIsUnlocked()) then return end -- prevent background sync when in office

	gitpassSync = hs.task
		.new(gitPassScript, function(exitCode, _, stdErr)
			stdErr = stdErr:gsub("\n", " –– ")
			if exitCode ~= 0 then
				notify(passIcon .. "⚠️️ password-store " .. stdErr)
			else
				print("Password-Store Sync successful.")
			end
		end)
		:start()
end

---sync all three git repos
---@param mode? string full|partial
function syncAllGitRepos(mode)
	if mode == "full" then
		gitDotfileSync("--submodules")
	elseif mode == "partial" then
		gitDotfileSync()
	end
	gitPassSync()
	gitVaultSync()
end

--------------------------------------------------------------------------------

repoSyncTimer = hs.timer.doEvery(repoSyncFreqMin * 60, function() syncAllGitRepos("partial") end):start()

-- manual sync for Alfred: `hammerspoon://sync-repos`
uriScheme("sync-repos", function()
	syncAllGitRepos("full")
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)

-- update icons for sketchybar
local function updateSketchybar()
	hs.execute(
		"export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; sketchybar --trigger repo-files-update"
	)
end

dotfilesWatcher = pw(dotfilesFolder, updateSketchybar):start()
vaultWatcher = pw(vaultLocation, updateSketchybar):start()
passFileWatcher = pw(passwordStore, updateSketchybar):start()

--------------------------------------------------------------------------------

shutDownWatcher = caff
	.new(function(eventType)
		if eventType == caff.screensDidSleep then syncAllGitRepos("full") end
	end)
	:start()

--------------------------------------------------------------------------------
-- SYSTEM WAKE/START
wakeWatcher = caff
	.new(function(eventType)
		if isAtOffice() and eventType == caff.screensDidUnlock then
			syncAllGitRepos("full")
			officeModeLayout()
		elseif not (isAtOffice()) and (eventType == caff.screensDidWake or eventType == caff.systemDidWake) then
			runWithDelays(1, function()
				if isProjector() then
					setDarkmode(true)
					movieModeLayout()
				else
					syncAllGitRepos("full")
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
			run trigger "backup-dotfiles" in workflow "de.chris-grieser.terminal-dotfiles" with argument "no sound"
		end tell
	]])
	hs.execute(
		'cp -f "$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/Bookmarks" "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Backups/Browser-Bookmarks.bkp"'
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
		runWithDelays(3, function()
			if isProjector() then iMacDisplay:setBrightness(0) end
		end)
	end
end)

local function sleepYouTube()
	local minutesIdle = hs.host.idleTime() / 60
	if minutesIdle < 30 then return end
	quitApp("YouTube")
	quitApp("Twitch")
	-- no need to quit IINA, since it autoquits on finishing playback
	-- no need to quit Netflix, since it autostops
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
