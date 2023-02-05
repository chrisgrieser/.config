require("lua.utils")
require("lua.window-management")
require("lua.dark-mode")
require("lua.layouts")
local caff = hs.caffeinate.watcher
local timer = hs.timer.doAt

local function restartSketchybar()
	hs.execute(
		"export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; brew services restart sketchybar"
	)
	runWithDelays(0.5, function ()
		hs.execute("osascript -l JavaScript ./helpers/dismiss-notification.js &>/dev/null;")
	end)
end
--------------------------------------------------------------------------------

-- CONFIG
local repoSyncFreqMin = 20
local dotfileIcon = "🔵"
local vaultIcon = "🟪"
local passIcon = "🔑"

--------------------------------------------------------------------------------

-- retrieve configs from zshenv
-- not local, cause sometimes not available, so set at startup
dotfilesFolder = getenv("DOTFILE_FOLDER")
passwordStore = getenv("PASSWORD_STORE_DIR")
vaultLocation = getenv("VAULT_PATH")

local gitDotfileScript = dotfilesFolder .. "/git-dotfile-sync.sh"
local gitVaultScript = vaultLocation .. "/Meta/git-vault-sync.sh"
local gitPassScript = passwordStore .. "/pass-sync.sh"

--------------------------------------------------------------------------------

---@return boolean
local function gitDotfileSync()
	if gitDotfileSyncTask and gitDotfileSyncTask:isRunning() then return false end
	if not (screenIsUnlocked()) then return true end -- prevent of standby home device background sync when in office

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

	if not gitDotfileSyncTask then return false end
	return true
end

---@return boolean
local function gitVaultSync()
	if gitVaultSyncTask and gitVaultSyncTask:isRunning() then return false end
	if not (screenIsUnlocked()) then return true end -- prevent of standby home device background sync when in office

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

	if not gitVaultSyncTask then return false end
	return true
end

---@return boolean
local function gitPassSync()
	if gitPassSyncTask and gitPassSyncTask:isRunning() then return true end
	if not screenIsUnlocked() then return true end -- prevent of standby home device background sync when in office

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

	if not gitPassSyncTask then return false end
	return true
end

--------------------------------------------------------------------------------

---sync all three git repos
---@param sendNotification? string whether to send notification on finished sync
function syncAllGitRepos(sendNotification)
	local success1 = gitDotfileSync()
	local success2 = gitPassSync()
	local success3 = gitVaultSync()
	if not (success1 and success2 and success3) then
		notify("⚠️️ Sync Error.")
		return
	end

	local function noSyncInProgress()
		local dotfilesSyncing = gitDotfileSyncTask and gitDotfileSyncTask:isRunning()
		local passSyncing = gitPassSyncTask and gitPassSyncTask:isRunning()
		local vaultSyncing = gitVaultSyncTask and gitVaultSyncTask:isRunning()
		return not (dotfilesSyncing or vaultSyncing or passSyncing)
	end

	hs.timer
		.waitUntil(noSyncInProgress, function()
			hs.execute("sketchybar --trigger repo-files-update")
			if sendNotification then notify("Sync finished.") end
		end)
		:start()
end

repoSyncTimer = hs.timer.doEvery(repoSyncFreqMin * 60, syncAllGitRepos):start()

-- manual sync for Alfred: `hammerspoon://sync-repos`
uriScheme("sync-repos", function()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
	syncAllGitRepos("notify")
end)

--------------------------------------------------------------------------------

sleepWatcher = caff
	.new(function(eventType)
		if eventType == caff.screensDidSleep then syncAllGitRepos() end
	end)
	:start()




wakeWatcher = caff
	.new(function(eventType)
		if eventType ~= caff.screensDidWake and eventType ~= caff.systemDidWake and eventType ~= caff.screensDidWake and eventType ~= caff.screensDidUnlock then return end

		twitterScrollUp()

		if isAtOffice() then
			syncAllGitRepos()
			workLayout()
			local toDark = betweenTime(7, 18)
			setDarkmode(toDark)
			return
		end

		if eventType == caff.screensDidWake or eventType == caff.screensDidUnlock then
			-- restartSketchybar()
			hs.execute("sketchybar --set clock popup.drawing=true")
		end

		-- INFO checks need to run after delay, since display number is not
		-- immediately picked up after wake
		runWithDelays(1, function()
			if isProjector() then
				setDarkmode(true)
				movieModeLayout()
			else
				if eventType ~= caff.systemDidWake then syncAllGitRepos("notify") end
				workLayout()
				local toDark = hs.brightness.ambient() < 100
				setDarkmode(toDark)
			end
		end)
	end)
	:start()

--------------------------------------------------------------------------------

-- CRONJOBS AT HOME

-- Drafts to do if trackpadBattery is low
local function trackpadBatteryCheck()
	local warningLevel = 20
	local trackpadPercent = hs.execute(
		[[ioreg -c AppleDeviceManagementHIDEventService -r -l | grep -i trackpad -A 20 | grep BatteryPercent | cut -d= -f2 | cut -d' ' -f2]]
	)
	if not trackpadPercent then return end -- no trackpad connected
	trackpadPercent = trim(trackpadPercent)
	if tonumber(trackpadPercent) < warningLevel then
		local msg = "Trackpad Battery is low (" .. trackpadPercent .. "%)"
		-- write to drafts inbox (= new draft without opening Drafts)
		hs.execute(
			'echo "'
				.. msg
				.. [[" > "$HOME/Library/Mobile Documents/iCloud~com~agiletortoise~Drafts5/Documents/Inbox/battery.md"]]
		)
	end
end

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
	trackpadBatteryCheck()
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
	quitApp { "YouTube", "Twitch", "CrunchyRoll" }
	-- no need to quit IINA, since it autoquits on finishing playback
	-- no need to quit Netflix since it autostops
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
