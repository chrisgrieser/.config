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

---@param msg string
local function notify(msg) hs.notify.show("Hammerspoon", "", msg) end

local syncedRepos = {}
local syncTasks = {}

---@param repo { name: string, icon: string, scriptPath: string }
local function repoSync(repo)
	syncTasks[repo.name] = hs.task
		.new(repo.scriptPath, function(exitCode, _, stdErr)
			if exitCode == 0 then
				table.insert(syncedRepos, repo)
			else
				notify(("⚠️️%s %s Sync: %s"):format(repo.icon, repo.name, stdErr))
			end
		end)
		:start()
end

---@nodiscard
---@return boolean
local function syncInProgress()
	local isSyncing = {}
	for _, repo in pairs(config.repos) do
		local isStillSyncing = syncTasks[repo.name] and syncTasks[repo.name]:isRunning()
		table.insert(isSyncing, isStillSyncing)
	end
	return u.tbl_contains(isSyncing, true)
end

---@param notifyOnSuccess boolean set to false for regularly occurring syncs
local function syncAllGitRepos(notifyOnSuccess)
	if syncInProgress() then
		print("🔁 Sync already in progress.")
		return
	end

	for _, repo in pairs(config.repos) do
		repoSync(repo)
	end

	AllSyncTimer = hs.timer
		.waitUntil(function() return not syncInProgress() end, function()
			local failedRepos = hs.fnutils.filter(
				config.repos,
				function(r) return not (hs.fnutils.contains(syncedRepos, r)) end
			)

			if #syncedRepos > 0 then
				local syncedIcons = hs.fnutils.map(syncedRepos, function(r) return r.icon end) or {}
				print("🔁 Sync done: " .. table.concat(syncedIcons))
				if notifyOnSuccess then notify("🔁 Sync done") end
			end
			if #failedRepos > 0 then
				local failedIcons = hs.fnutils.map(failedRepos, function(r) return r.icon end) or {}
				local failMsg = "🔁⚠️ Warning – Sync failed: " .. table.concat(failedIcons)
				print(failMsg)
				notify(failMsg)
			end

			syncedRepos = {} -- reset
			u.runWithDelays(config.postSyncHook.delaySecs, config.postSyncHook.func)
		end)
		:start()
end

--------------------------------------------------------------------------------
-- WHEN TO SYNC

-- 1. on systemstart
if u.isSystemStart() then syncAllGitRepos(true) end

-- 2. every x minutes
RepoSyncTimer = hs.timer
	.doEvery(config.syncIntervallMins * 60, function()
		if u.screenIsUnlocked() then syncAllGitRepos(false) end
	end)
	:start()

-- 3. manually via Alfred: `hammerspoon://sync-repos`
u.urischeme("sync-repos", function() syncAllGitRepos(true) end)

-- 4. when going to sleep or when unlocking
local recentlyTriggered
local c = hs.caffeinate.watcher
SleepWatcherForRepoSync = c.new(function(event)
	if env.isProjector() then return end
	if recentlyTriggered then return end
	recentlyTriggered = true

	local lockOrSleep = event == c.screensDidLock
		or event == c.screensDidSleep
		or event == c.screensDidUnlock
		or event == c.systemDidWake
		or event == c.screensDidWake
	if lockOrSleep then syncAllGitRepos(true) end
	u.runWithDelays(3, function() recentlyTriggered = false end)
end):start()

-- 5. Every morning at 8:00, when at home
-- (safety redundancy to ensure sync when leaving for the office)
if env.isAtHome then
	MorningSyncTimer = hs.timer.doAt("08:00", "01d", function() syncAllGitRepos(false) end):start()
end
