require("lua.utils")
--------------------------------------------------------------------------------

-- CONFIG
local repoSyncFreqMin = 0.3
local dotfileIcon = "🔵"
local vaultIcon = "🟪"
local passIcon = "🔑"

--------------------------------------------------------------------------------
-- Repo Sync Setup
local gitDotfileScript = DotfilesFolder .. "/git-dotfile-sync.sh"
local gitVaultScript = VaultLocation .. "/Meta/git-vault-sync.sh"
local gitPassScript = PasswordStore .. "/pass-sync.sh"

---@return boolean
---@param submodulePull? boolean also update submodules, defaults to **true**
local function gitDotfileSync(submodulePull)
	local scriptArgs = {}
	if submodulePull == nil or submodulePull == true then scriptArgs = { "--submodule-pull" } end

	if GitDotfileSyncTask and GitDotfileSyncTask:isRunning() then return false end
	if not (ScreenIsUnlocked()) then return true end -- prevent standby home device background sync when in office

	local function dotfileSyncCallback(exitCode, _, stdErr)
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

	GitDotfileSyncTask = hs.task.new(gitDotfileScript, dotfileSyncCallback, scriptArgs):start()
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
---@param extras? string extra modes
function SyncAllGitRepos(extras)
	local pullSubmodules = extras ~= "no-submodule-pull"
	local success1 = gitDotfileSync(pullSubmodules)

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
	local function updateSketchybar()
		hs.execute("sketchybar --trigger repo-files-update")
		if extras == "notify" then Notify("Sync finished.") end
	end

	hs.timer.waitUntil(noSyncInProgress, updateSketchybar):start()
end

--------------------------------------------------------------------------------
-- WHEN TO SYNC

-- 1. on systemstart
-- (see meta.lua)

-- 2. every x minutes
RepoSyncTimer = hs.timer
	.doEvery(repoSyncFreqMin * 60, function() SyncAllGitRepos("no-submodule-pull") end)
	:start()

-- 3. manually via Alfred: `hammerspoon://sync-repos`
UriScheme("sync-repos", function()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
	SyncAllGitRepos("notify")
end)

-- 4. when going to sleep or when unlocking with idleTime
SleepWatcher = hs.caffeinate.watcher
	.new(function(event)
		local c = hs.caffeinate.watcher
		if event == c.screensDidSleep or (event == c.screensDidUnlock and IdleMins(30)) then
			SyncAllGitRepos()
		end
	end)
	:start()
