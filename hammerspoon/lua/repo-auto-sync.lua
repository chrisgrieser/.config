require("lua.utils")
--------------------------------------------------------------------------------

-- CONFIG
local repoSyncFreqMin = 20
local dotfileIcon = "🔵"
local vaultIcon = "🟪"
local passIcon = "🔑"

--------------------------------------------------------------------------------
-- Repo Sync Setup
local gitDotfileScript = DotfilesFolder .. "/git-dotfile-sync.sh"
local gitVaultScript = VaultLocation .. "/Meta/git-vault-sync.sh"
local gitPassScript = PasswordStore .. "/pass-sync.sh"

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
---@param sendNotification? any whether to send notification on finished sync
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

--------------------------------------------------------------------------------
-- CALLING THE SYNC

-- 1. on systemstart (see meta.lua)
-- 2. on screen unlock (see cronjobs.lua)

-- 3. every x minutes
RepoSyncTimer = hs.timer.doEvery(repoSyncFreqMin * 60, SyncAllGitRepos):start()

-- 4. manually via Alfred: `hammerspoon://sync-repos`
UriScheme("sync-repos", function()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
	SyncAllGitRepos("notify")
end)

-- 5. when going to sleep
SleepWatcher = hs.caffeinate.watcher
	.new(function(eventType)
		if eventType == hs.caffeinate.watcher.screensDidSleep then SyncAllGitRepos() end
	end)
	:start()
