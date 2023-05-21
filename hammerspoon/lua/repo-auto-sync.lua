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

---@return boolean success
local function gitDotfileSync()
	local gitDotfileScript = env.dotfilesFolder .. "git-dotfile-sync.sh"

	if GitDotfileSyncTask and GitDotfileSyncTask:isRunning() then return false end
	if not (u.screenIsUnlocked()) then return true end -- prevent standby home device background sync when in office

	GitDotfileSyncTask = hs.task
		.new(gitDotfileScript, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print(dotfileIcon .. " Dotfile Sync")
				return
			end
			u.notify(vaultIcon .. "⚠️️ dotfiles " .. stdErr)
		end)
		:start()

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
				print(vaultIcon, "Vault Sync")
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
				print(passIcon, "Password-Store Sync")
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
---@param notify boolean
function M.syncAllGitRepos(notify)
	local success1 = gitDotfileSync()
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
		if notify then u.notify("Sync finished") end
	end

	AllSyncTimer = hs.timer.waitUntil(noSyncInProgress, updateSketchybar):start()
end

--------------------------------------------------------------------------------
-- WHEN TO SYNC

-- 1. on systemstart
-- (see reload-systemstart.lua)

-- 2. every x minutes
RepoSyncTimer = hs.timer
	.doEvery(repoSyncFreqMin * 60, function() M.syncAllGitRepos(false) end)
	:start()

-- 3. manually via Alfred: `hammerspoon://sync-repos`
u.urischeme("sync-repos", function()
	u.app("Hammerspoon"):hide() -- so the previous app does not loose focus
	M.syncAllGitRepos(true)
end)

-- 4. when going to sleep or when unlocking
SleepWatcher = hs.caffeinate.watcher
	.new(function(event)
		local c = hs.caffeinate.watcher
		if
			event == c.screensDidLock
			or event == c.screensDidSleep
			or event == c.systemDidWake
			or (event == c.screensDidWake and u.idleMins(30))
		then
			M.syncAllGitRepos(true)
		end
	end)
	:start()

-- 5. Every morning at 8:00, when at home
-- (safety redundancy to ensure syncs when leaving for the office)
MorningSyncTimer = hs.timer
	.doAt("08:00", "01d", function()
		if env.isAtHome then M.syncAllGitRepos(false) end
	end)
	:start()

--------------------------------------------------------------------------------
return M
