local M = {}
local env = require("lua.environment-vars")
local u = require("lua.utils")

--------------------------------------------------------------------------------

-- CONFIG
local repoSyncFreqMin = 30
local dotfileIcon = "🔵"
local vaultIcon = "🟪"
local passIcon = "🔑"

--------------------------------------------------------------------------------
-- Repo Sync Setup

---@param submodulePull? boolean also update submodules, defaults to **true**
---@return boolean
local function gitDotfileSync(submodulePull)
	local gitDotfileScript = env.dotfilesFolder .. "git-dotfile-sync.sh"

	local scriptArgs = {}
	if submodulePull == nil then submodulePull = true end
	if submodulePull then scriptArgs = { "--submodule-pull" } end

	if GitDotfileSyncTask and GitDotfileSyncTask:isRunning() then return false end
	if not (u.screenIsUnlocked()) then return true end -- prevent standby home device background sync when in office

	local function dotfileSyncCallback(exitCode, _, stdErr)
		if exitCode == 0 then
			local msg = dotfileIcon .. " Dotfile Sync successful"
			if submodulePull then msg = msg .. " (with submodules)" end
			print(msg)
			return
		end
		local stdout = hs.execute("git status --short")
		if not stdout then return end
		local submodulesStillDirty = stdout:match(" m ")
		if submodulesStillDirty then
			local modules = stdout:gsub(".*/", "")
			u.notify(dotfileIcon .. "⚠️️ dotfiles submodules still dirty\n\n" .. modules)
		else
			u.notify(dotfileIcon .. "⚠️️ dotfiles " .. stdErr)
		end
	end

	GitDotfileSyncTask = hs.task.new(gitDotfileScript, dotfileSyncCallback, scriptArgs):start()
	if not GitDotfileSyncTask then return false end
	return true
end

---@return boolean
local function gitVaultSync()
	local gitVaultScript = env.vaultLocation .. "Meta/git-vault-sync.sh"
	if GitVaultSyncTask and GitVaultSyncTask:isRunning() then return false end
	if not (u.screenIsUnlocked()) then return true end -- prevent of standby home device background sync when in office

	GitVaultSyncTask = hs.task
		.new(gitVaultScript, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print(vaultIcon, "Vault Sync successful")
				return
			end
			u.notify(vaultIcon .. "⚠️️ vault " .. stdErr)
		end)
		:start()

	if not GitVaultSyncTask then return false end
	return true
end

---@return boolean
local function gitPassSync()
	local gitPassScript = env.passwordStore .. "pass-sync.sh"
	if GitPassSyncTask and GitPassSyncTask:isRunning() then return true end
	if not u.screenIsUnlocked() then return true end -- prevent of standby home device background sync when in office

	GitPassSyncTask = hs.task
		.new(gitPassScript, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print(passIcon, "Password-Store Sync successful")
				return
			end
			u.notify(passIcon .. "⚠️️ password-store " .. stdErr)
		end)
		:start()

	if not GitPassSyncTask then return false end
	return true
end

--------------------------------------------------------------------------------

---sync all three git repos
---@param extras? string extra modes
function M.syncAllGitRepos(extras)
	local pullSubmodules = extras ~= "no-submodule-pull"
	local success1 = gitDotfileSync(pullSubmodules)

	local success2 = gitPassSync()
	local success3 = gitVaultSync()

	if not (success1 and success2 and success3) then
		u.notify("⚠️️ Sync Error")
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
		if extras == "notify" then u.notify("Sync finished") end
	end

	hs.timer.waitUntil(noSyncInProgress, updateSketchybar):start()
end

--------------------------------------------------------------------------------
-- WHEN TO SYNC

-- 1. on systemstart
-- (see reload-systemstart.lua)

-- 2. every x minutes
RepoSyncTimer = hs.timer
	.doEvery(repoSyncFreqMin * 60, function() M.syncAllGitRepos("no-submodule-pull") end)
	:start()

-- 3. manually via Alfred: `hammerspoon://sync-repos`
u.urischeme("sync-repos", function()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
	M.syncAllGitRepos("notify")
end)

-- 4. when going to sleep or when unlocking with idleTime
SleepWatcher = hs.caffeinate.watcher
	.new(function(event)
		local c = hs.caffeinate.watcher
		if
			event == c.screensDidLock
			or event == c.screensDidSleep
			or ((event == c.screensDidWake or event == c.systemDidWake) and u.idleMins(30))
		then
			M.syncAllGitRepos()
		end
	end)
	:start()

--------------------------------------------------------------------------------
return M
