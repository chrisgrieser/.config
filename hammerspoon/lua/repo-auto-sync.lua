local env = require("lua.environment-vars")
local u = require("lua.utils")

--------------------------------------------------------------------------------

-- CONFIG
local repoSyncMins = 30

--------------------------------------------------------------------------------
-- REPO SYNC JOBS

---@return string|nil nil if not successful, otherwise success Symbol
local function gitDotfileSync()
	local gitDotfileScript = env.dotfilesFolder .. "/git-dotfile-sync.sh"
	if GitDotfileSyncTask and GitDotfileSyncTask:isRunning() then return end

	GitDotfileSyncTask = hs.task
		.new(gitDotfileScript, function(exitCode, _, stdErr)
			if exitCode == 0 then return "🔵" end
			u.notify("🔵⚠️️ Dotfiles Sync: " .. stdErr)
		end)
		:start()
end

---@return string|nil nil if not successful, otherwise success Symbol
local function gitVaultSync()
	local gitVaultScript = env.vaultLocation .. "/Meta/git-vault-sync.sh"
	if GitVaultSyncTask and GitVaultSyncTask:isRunning() then return end

	GitVaultSyncTask = hs.task
		.new(gitVaultScript, function(exitCode, _, stdErr)
			if exitCode == 0 then return "🟪" end
			u.notify("🟪⚠️️ Vault Sync: " .. stdErr)
		end)
		:start()
end

---@return string|nil nil if not successful, otherwise success Symbol
local function gitPassSync()
	local gitPassScript = env.passwordStore .. "/pass-sync.sh"
	if GitPassSyncTask and GitPassSyncTask:isRunning() then return end

	GitPassSyncTask = hs.task
		.new(gitPassScript, function(exitCode, _, stdErr)
			if exitCode == 0 then return "🔑" end
			u.notify("🔑⚠️️ Password-Store Sync: " .. stdErr)
		end)
		:start()
end

---sync all three git repos
---@param notify boolean
local function syncAllGitRepos(notify)
	local success1 = gitDotfileSync()
	local success2 = gitPassSync()
	local success3 = gitVaultSync()
	print("Sycned: " .. (success1 or "") .. (success2 or "") .. (success3 or ""))

	local function noSyncInProgress()
		local dotfilesSyncing = GitDotfileSyncTask and GitDotfileSyncTask:isRunning()
		local passSyncing = GitPassSyncTask and GitPassSyncTask:isRunning()
		local vaultSyncing = GitVaultSyncTask and GitVaultSyncTask:isRunning()
		return not (dotfilesSyncing or vaultSyncing or passSyncing)
	end

	AllSyncTimer = hs.timer
		.waitUntil(noSyncInProgress, function()
			-- stylua: ignore
			u.runWithDelays(2, function() hs.execute(u.exportPath .. "sketchybar --trigger repo-files-update") end)
		end)
		:start()

	if not (success1 and success2 and success3) then
		u.notify("⚠️ Sync fail.")
	elseif notify then
		u.notify("🔁 Sync done.")
	end
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
local c = hs.caffeinate.watcher
SleepWatcherForRepoSync = c.new(function(event)
	if env.isProjector() then return end
	local lockOrSleep = event == c.screensDidLock
		or event == c.screensDidSleep
		or event == c.screensDidUnlock
		or event == c.systemDidWake
		or event == c.screensDidWake
	if lockOrSleep then syncAllGitRepos(true) end
end):start()

-- 5. Every morning at 8:00, when at home
-- (safety redundancy to ensure sync when leaving for the office)
MorningSyncTimer = hs.timer
	.doAt("08:00", "01d", function()
		if env.isAtHome then syncAllGitRepos(false) end
	end)
	:start()
