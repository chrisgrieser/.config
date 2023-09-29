local env = require("lua.environment-vars")
local u = require("lua.utils")

--------------------------------------------------------------------------------

local config = {
	syncMins = 30,
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
}

--------------------------------------------------------------------------------
-- REPO SYNC JOBS

SyncSucessIcons = {}
SyncTasks = {}

---@param name string
---@param icon string
---@param scriptPath string
local function repoSync(name, icon, scriptPath)
	if SyncTasks[name] and SyncTasks[name]:isRunning() then return end

	SyncTasks[name] = hs.task
		.new(scriptPath, function(exitCode, _, stdErr)
			if exitCode == 0 then
				table.insert(SyncSucessIcons, icon)
			else
				u.notify(("%s⚠️️ %s Sync: %s"):format(icon, name, stdErr))
			end
		end)
		:start()
end

---sync all three git repos
---@param notify boolean
local function syncAllGitRepos(notify)
	for _, repo in pairs(config.repos) do
		repoSync(repo.name, repo.icon, repo.scriptPath)
	end

	local function noSyncInProgress()
		local isSyncing = {}
		for _, repo in pairs(config.repos) do
			local syncing = SyncTasks[repo.name] and SyncTasks[repo.name]:isRunning()
			table.insert(isSyncing, syncing)
		end
		return not (u.tbl_contains(isSyncing, true))
	end

	AllSyncTimer = hs.timer
		.waitUntil(noSyncInProgress, function()
			local allSyncSucess = #SyncSucessIcons == #config.repos
			if allSyncSucess and notify then
				u.notify("🔁 Sync done.")
			elseif allSyncSucess then
				print("Sync done: " .. table.concat(SyncSucessIcons, ""))
			else
				print(("⚠️ %s Sync failed."):format(#config.repos - #SyncSucessIcons))
			end
			SyncSucessIcons = {} -- reset
			-- stylua: ignore
			u.runWithDelays(2, function() hs.execute(u.exportPath .. "sketchybar --trigger repo-files-update") end)
		end)
		:start()
end

--------------------------------------------------------------------------------
-- WHEN TO SYNC

-- 1. on systemstart
if not u.isReloading() then syncAllGitRepos(true) end

-- 2. every x minutes
RepoSyncTimer = hs.timer
	.doEvery(config.syncMins * 60, function()
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
