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

-- retrieve configs from zshenv; sometimes not loading properly
local i = 0
local dotfilesFolder
local passwordStore 
local vaultLocation 
while not dotfilesFolder do
	dotfilesFolder = os.getenv("DOTFILE_FOLDER")
	passwordStore = os.getenv("PASSWORD_STORE_DIR")
	vaultLocation = os.getenv("VAULT_PATH")
	hs.execute("sleep 0.2") -- since lua has no own wait command
	if i > 30 then
		Notify("Could not retrieve .zshenv")
		return
	end
end

local gitDotfileScript = dotfilesFolder .. "/git-dotfile-sync.sh"
local gitVaultScript = vaultLocation .. "/Meta/git-vault-sync.sh"
local gitPassScript = passwordStore .. "/pass-sync.sh"

--------------------------------------------------------------------------------

---@return boolean
local function gitDotfileSync()
	if GitDotfileSyncTask and GitDotfileSyncTask:isRunning() then return false end
	if not (ScreenIsUnlocked()) then return true end -- prevent standby home device background sync when in office

	GitDotfileSyncTask = hs.task
		.new(
			gitDotfileScript,
			function(exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
				if exitCode == 0 then
					print(dotfileIcon, "Dotfile Sync successful.")
					return
				end

				local stdout = hs.execute("git status --short")
				if not stdout then return end
				local submodulesStillDirty = stdout:match(" m ")
				if submodulesStillDirty then
					local modules = stdout:gsub(".*/", "")
					Notify(dotfileIcon .. "⚠️️ dotfiles submodules still dirty\n\n" .. modules)
				else
					Notify(dotfileIcon .. "⚠️️ dotfiles " .. stdErr)
				end
			end
		)
		:start()

	if not GitDotfileSyncTask then return false end
	return true
end

---@return boolean
local function gitVaultSync()
	if GitVaultSyncTask and GitVaultSyncTask:isRunning() then return false end
	if not (ScreenIsUnlocked()) then return true end -- prevent of standby home device background sync when in office

	GitVaultSyncTask = hs.task
		.new(gitVaultScript, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print(vaultIcon, "Vault Sync successful.")
				return
			end
			Notify(vaultIcon .. "⚠️️ vault " .. stdErr)
		end)
		:start()

	if not GitVaultSyncTask then return false end
	return true
end

---@return boolean
local function gitPassSync()
	if GitPassSyncTask and GitPassSyncTask:isRunning() then return true end
	if not ScreenIsUnlocked() then return true end -- prevent of standby home device background sync when in office

	GitPassSyncTask = hs.task
		.new(gitPassScript, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print(passIcon, "Password-Store Sync successful.")
				return
			end
			Notify(passIcon .. "⚠️️ password-store " .. stdErr)
		end)
		:start()

	if not GitPassSyncTask then return false end
	return true
end

--------------------------------------------------------------------------------

---sync all three git repos
---@param sendNotification? string|boolean whether to send notification on finished sync
function SyncAllGitRepos(sendNotification)
	local success1 = gitDotfileSync()
	local success2 = gitPassSync()
	local success3 = gitVaultSync()
	if not (success1 and success2 and success3) then
		Notify("⚠️️ Sync Error.")
		return
	end

	local function noSyncInProgress()
		local dotfilesSyncing = GitDotfileSyncTask and GitDotfileSyncTask:isRunning()
		local passSyncing = GitPassSyncTask and GitPassSyncTask:isRunning()
		local vaultSyncing = GitVaultSyncTask and GitVaultSyncTask:isRunning()
		return not (dotfilesSyncing or vaultSyncing or passSyncing)
	end

	hs.timer
		.waitUntil(noSyncInProgress, function()
			hs.execute("sketchybar --trigger repo-files-update")
			if sendNotification then Notify("Sync finished.") end
		end)
		:start()
end

BrightnessCheckTimer = hs.timer.doEvery(repoSyncFreqMin * 60, SyncAllGitRepos):start()

-- manual sync for Alfred: `hammerspoon://sync-repos`
UriScheme("sync-repos", function()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
	SyncAllGitRepos("notify")
end)

--------------------------------------------------------------------------------

SleepWatcher = caff
	.new(function(eventType)
		if eventType == caff.screensDidSleep then SyncAllGitRepos() end
	end)
	:start()

OfficeWakeWatcher = caff.new(function(event)
	if IsAtOffice() and (event == caff.screensDidWake or event == caff.systemDidWake) then
		TwitterScrollUp()
		SyncAllGitRepos()
		WorkLayout()
		local toDark = not (BetweenTime(7, 18))
		SetDarkmode(toDark)
		return
	end
end)

--------------------------------------------------------------------------------
-- CRONJOBS AT HOME

HomeWakeWatcher = caff
	.new(function(event)
		if IsAtOffice() then return end
		if not (event == caff.screensDidWake or event == caff.screensDidUnlock) then return end

		TwitterScrollUp()
		hs.execute("sketchybar --set clock popup.drawing=true")

		hs.timer.waitUntil(ScreenIsUnlocked, function()
			if event == caff.systemDidWake then SyncAllGitRepos("notify") end
			-- INFO checks need to run after delay, since display number is not
			-- immediately picked up after wake
			RunWithDelays(1, function()
				if IsProjector() then
					SetDarkmode(true)
					MovieModeLayout()
				else
					Notify("beep")
					AutoSwitchDarkmode()
					WorkLayout()
				end
			end)
		end)
	end)
	:start()

-- backup Vault, Dotfiles, Bookmarks, and extension list
BiweeklyTimer = timer("02:00", "02d", function()
	Applescript([[
		tell application id "com.runningwithcrayons.Alfred"
			run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
			run trigger "backup-dotfiles" in workflow "de.chris-grieser.terminal-dotfiles"
		end tell
	]])
	hs.execute(
		'cp -f "$HOME/Library/Application Support/Vivaldi/Default/Bookmarks" "$DATA_DIR/Backups/Browser-Bookmarks.bkp"'
	)
	hs.execute([[
		ls -1 "$HOME/Library/Application Support/Vivaldi/Default/Extensions/" |
		sed "s|^|https://chrome.google.com/webstore/detail/|" \
		> "$DOTFILE_FOLDER/browser-extension-configs/list-of-extensions.txt"
	]])
	hs.loadSpoon("EmmyLua") -- so it runs not as often
	PeripheryBatteryCheck("Drafts")
end, true)

ProjectorScreensaverWatcher = caff.new(function(eventType)
	if eventType == caff.screensaverDidStop or eventType == caff.screensaverDidStart then
		RunWithDelays(2, function()
			if IsProjector() then IMacDisplay:setBrightness(0) end
		end)
	end
end)

local function sleepMovieApps()
	local minutesIdle = hs.host.idleTime() / 60
	if minutesIdle < 30 then return end
	QuitApp { "YouTube", "Twitch", "CrunchyRoll" }
	-- no need to quit IINA and Netflix, since they autoquits / autoquit
	Applescript([[
		tell application "Vivaldi"
			if ((count of window) is not 0)
				if ((count of tab of front window) is not 0)
					set currentTabUrl to URL of active tab of front window
					if (currentTabUrl contains "youtu") then close active tab of front window
				end if
			end if
		end tell
	]])
end

--------------------------------------------------------------------------------

if IsIMacAtHome() or IsAtMother() then
	SleepTimer0 = timer("02:00", "01d", sleepMovieApps, true):start()
	SleepTimer1 = timer("03:00", "01d", sleepMovieApps, true):start()
	SleepTimer2 = timer("04:00", "01d", sleepMovieApps, true):start()
	SleepTimer3 = timer("05:00", "01d", sleepMovieApps, true):start()
	SleepTimer4 = timer("06:00", "01d", sleepMovieApps, true):start()
	if IsIMacAtHome() then
		BiweeklyTimer:start()
		ProjectorScreensaverWatcher:start()
	end
end
