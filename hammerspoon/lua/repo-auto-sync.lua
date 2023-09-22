local env = require("lua.environment-vars")
local u = require("lua.utils")

--------------------------------------------------------------------------------

-- CONFIG
local repoSyncMins = 30

--------------------------------------------------------------------------------
-- REPO SYNC JOBS

---@return boolean whether the job has been run
local function gitDotfileSync()
	local gitDotfileScript = env.dotfilesFolder .. "/git-dotfile-sync.sh"
	if GitDotfileSyncTask and GitDotfileSyncTask:isRunning() then return false end

	GitDotfileSyncTask = hs.task
		.new(gitDotfileScript, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print("🔵 Dotfiles Sync")
			else
				u.notify("🔵⚠️️ Dotfiles Sync: " .. stdErr)
			end
		end)
		:start()

	return true
end

---@return boolean whether the job has been run
local function gitVaultSync()
	local gitVaultScript = env.vaultLocation .. "/Meta/git-vault-sync.sh"
	if GitVaultSyncTask and GitVaultSyncTask:isRunning() then return false end

	GitVaultSyncTask = hs.task
		.new(gitVaultScript, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print("🟪 Vault Sync")
			else
				u.notify("🟪⚠️️ Vault Sync: " .. stdErr)
			end
		end)
		:start()

	return true
end

---@return boolean whether the job has been run
local function gitPassSync()
	local gitPassScript = env.passwordStore .. "/pass-sync.sh"
	if GitPassSyncTask and GitPassSyncTask:isRunning() then return false end

	GitPassSyncTask = hs.task
		.new(gitPassScript, function(exitCode, _, stdErr)
			if exitCode == 0 then
				print("🔑 Password-Store Sync")
			else
				u.notify("🔑⚠️️ Password-Store Sync: " .. stdErr)
			end
		end)
		:start()

	return true
end

---sync all three git repos
---@param notify boolean
local function syncAllGitRepos(notify)
	local success1 = gitDotfileSync()
	local success2 = gitPassSync()
	local success3 = gitVaultSync()
	if not (success1 and success2 and success3) then return end

	local function noSyncInProgress()
		local dotfilesSyncing = GitDotfileSyncTask and GitDotfileSyncTask:isRunning()
		local passSyncing = GitPassSyncTask and GitPassSyncTask:isRunning()
		local vaultSyncing = GitVaultSyncTask and GitVaultSyncTask:isRunning()
		return not (dotfilesSyncing or vaultSyncing or passSyncing)
	end

	AllSyncTimer = hs.timer
		.waitUntil(noSyncInProgress, function()
			if notify then u.notify("🔁 Sync finished") end
			u.runWithDelays(
				5,
				function() hs.execute(u.exportPath .. "sketchybar --trigger repo-files-update") end
			)
		end)
		:start()
end

--------------------------------------------------------------------------------
-- WHEN TO SYNC

-- 1. on systemstart
if not u.isReloading() then syncAllGitRepos(true) end

-- 2. every x minutes
RepoSyncTimer = hs.timer
	.doEvery(repoSyncMins * 60, function()
		if u.screenIsUnlocked() then syncAllGitRepos(false) end
	end)
	:start()

-- 3. manually via Alfred: `hammerspoon://sync-repos`
u.urischeme("sync-repos", function()
	u.app("Hammerspoon"):hide() -- so the previous app does not loose focus
	syncAllGitRepos(true)
end)

-- 4. when going to sleep or when unlocking
SleepWatcherForRepoSync = hs.caffeinate.watcher
	.new(function(event)
		if env.isProjector() then return end
		local c = hs.caffeinate.watcher
		local lockOrSleep = event == c.screensDidLock
			or event == c.screensDidSleep
			or event == c.screensDidUnlock
			or event == c.systemDidWake
			or event == c.screensDidWake
		if lockOrSleep then syncAllGitRepos(true) end
	end)
	:start()

-- 5. Every morning at 8:00, when at home
-- (safety redundancy to ensure sync when leaving for the office)
MorningSyncTimer = hs.timer
	.doAt("08:00", "01d", function()
		if env.isAtHome then syncAllGitRepos(false) end
	end)
	:start()
