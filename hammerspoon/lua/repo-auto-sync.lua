local env = require("lua.environment-vars")
local u = require("lua.utils")

--------------------------------------------------------------------------------

local config = {
	syncIntervallMins = 30,
	repos = {
		{
			name = "Dotfiles",
			icon = "🔵",
			scriptPath = env.dotfilesFolder .. "/git-dotfile-sync.sh",
		},
		{
			name = "Vault",
			icon = "🟪",
			scriptPath = env.vaultLocation .. "/Meta/git-vault-sync.sh",
		},
		{
			name = "Passwords",
			icon = "🔑",
			scriptPath = env.passwordStore .. "/pass-sync.sh",
		},
	},
	postSyncHook = {
		func = function() hs.execute(u.exportPath .. "sketchybar --trigger repo-files-update") end,
		delaySecs = 2,
	},
}

--------------------------------------------------------------------------------
-- REPO SYNC JOBS

local syncSuccessIcons = {}
local syncTasks = {}

---@param name string
---@param icon string
---@param scriptPath string
local function repoSync(name, icon, scriptPath)
	if syncTasks[name] and syncTasks[name]:isRunning() then return end

	syncTasks[name] = hs.task
		.new(scriptPath, function(exitCode, _, stdErr)
			if exitCode == 0 then
				table.insert(syncSuccessIcons, icon)
			else
				u.notify(("%s⚠️️ %s Sync: %s"):format(icon, name, stdErr))
			end
		end)
		:start()
end

---@nodiscard
---@return boolean
local function noSyncInProgress()
	local isSyncing = {}
	for _, repo in pairs(config.repos) do
		local stillSyncing = syncTasks[repo.name] and syncTasks[repo.name]:isRunning()
		table.insert(isSyncing, stillSyncing)
	end
	return not (u.tbl_contains(isSyncing, true))
end

---@param notifyOnSuccess boolean
local function syncAllGitRepos(notifyOnSuccess)
	for _, repo in pairs(config.repos) do
		repoSync(repo.name, repo.icon, repo.scriptPath)
	end

	AllSyncTimer = hs.timer
		.waitUntil(noSyncInProgress, function()
			local allSyncSuccess = #syncSuccessIcons == #config.repos
			local successfulSyncs = "Sync done: " .. table.concat(syncSuccessIcons)
			if allSyncSuccess then
				local func = notifyOnSuccess and u.notify or print
				func(successfulSyncs)
			else
				print(successfulSyncs)
				print(("⚠️ %s Sync failed."):format(#config.repos - #syncSuccessIcons))
			end
			syncSuccessIcons = {} -- reset
			u.runWithDelays(config.postSyncHook.delaySecs, config.postSyncHook.func)
		end)
		:start()
end

--------------------------------------------------------------------------------
-- WHEN TO SYNC

-- 1. on systemstart
if not u.isReloading() then syncAllGitRepos(true) end

-- 2. every x minutes
RepoSyncTimer = hs.timer
	.doEvery(config.syncIntervallMins * 60, function()
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
if env.isAtHome then
	MorningSyncTimer = hs.timer.doAt("08:00", "01d", function() syncAllGitRepos(false) end):start()
end
