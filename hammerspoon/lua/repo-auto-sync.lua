local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")
--------------------------------------------------------------------------------

local config = {
	syncIntervalMins = 30,
	permaReposPath = os.getenv("HOME") .. "/.config/perma-repos.csv",
	repos = {},
}
for line in io.lines(config.permaReposPath) do
	local name, location, icon, _ = line:match("^(.-),(.-),(.-),(.-)$")
	if not (name and location and icon) then return end
	table.insert(config.repos, {
		name = name,
		location = location,
		icon = icon,
	})
end

--------------------------------------------------------------------------------
-- REPO SYNC JOBS

---@param msg string
local function notify(msg) hs.notify.show("Hammerspoon", "", msg) end

M.syncedRepos = {}
M.task_sync = {}

---@async
---@param repo { name: string, icon: string, location: string }
local function repoSync(repo)
	local syncScriptPath = repo.location .. "/.sync-this-repo.sh"
	local syncScriptExists = hs.fs.attributes(syncScriptPath) ~= nil
	if not syncScriptExists then
		notify(("⚠️️ %s %s: missing .sync-this-repo.sh"):format(repo.icon, repo.name))
		return
	end
	M.task_sync[repo.name] = hs.task
		.new(syncScriptPath, function(exitCode, _, stdErr)
			if exitCode == 0 then
				table.insert(M.syncedRepos, repo)
			else
				local msg = ("⚠️️ %s %s Sync: %s"):format(repo.icon, repo.name, stdErr)
				print(msg)
				notify(msg)
			end
		end)
		:start()
end

---@nodiscard
---@return string[] reposStillSyncing
local function repoSyncsInProgress()
	local reposStillSyncing = {}
	for _, repo in pairs(config.repos) do
		local isStillSyncing = M.task_sync[repo.name] and M.task_sync[repo.name]:isRunning()
		if isStillSyncing then table.insert(reposStillSyncing, repo.icon) end
	end
	return reposStillSyncing
end

---@async
---@param notifyOnSuccess boolean set to false for regularly occurring syncs
local function syncAllGitRepos(notifyOnSuccess)
	print("❗ beep 🔵")
	local reposStillSyncing = repoSyncsInProgress()
	if #reposStillSyncing > 0 then
		u.notify("🔁 Sync still in progress: " .. table.concat(reposStillSyncing))
		return
	end

	for _, repo in pairs(config.repos) do
		repoSync(repo)
	end

	M.timer_AllSyncs = hs.timer
		.waitUntil(function() return not repoSyncsInProgress() end, function()
			if #M.syncedRepos > 0 then
				local syncedIcons = hs.fnutils.map(M.syncedRepos, function(r) return r.icon end) or {}
				local msg = "🔁 Sync done: " .. table.concat(syncedIcons)
				print(msg)
				if notifyOnSuccess then notify(msg) end
			end

			M.syncedRepos = {} -- reset
		end)
		:start()
end

--------------------------------------------------------------------------------
-- WHEN TO SYNC

-- 1. on systemstart
if u.isSystemStart() then syncAllGitRepos(true) end

-- 2. every x minutes
M.timer_repoSync = hs.timer
	.doEvery(config.syncIntervalMins * 60, function()
		if u.screenIsUnlocked() then syncAllGitRepos(false) end
	end)
	:start()

-- 3. manually via Alfred: `hammerspoon://sync-repos`
hs.urlevent.bind("sync-repos", function() syncAllGitRepos(true) end)

-- 4. when going to sleep or when unlocking
local c = hs.caffeinate.watcher
M.caff_SleepWatcherForRepoSync = c.new(function(event)
	if M.recentlyTriggered or env.isProjector() then return end
	M.recentlyTriggered = true

	local lockOrSleep = event == c.screensDidLock
		or event == c.screensDidSleep
		or event == c.screensDidUnlock
		or event == c.systemDidWake
		or event == c.screensDidWake
	if lockOrSleep then syncAllGitRepos(true) end
	u.runWithDelays(3, function() M.recentlyTriggered = false end)
end):start()

-- 5. Every morning at 8:00, when at home
-- (safety redundancy to ensure sync when leaving for the office)
if env.isAtHome then
	M.timer_morningSync = hs.timer
		.doAt("08:00", "01d", function() syncAllGitRepos(false) end)
		:start()
end

--------------------------------------------------------------------------------
return M
