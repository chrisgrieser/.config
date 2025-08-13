local config = {
	syncIntervalMins = 30,
	permaReposPath = os.getenv("HOME") .. "/.config/perma-repos.csv",
}

--------------------------------------------------------------------------------

local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")

---@param msg string
local function notify(msg) hs.notify.show("Hammerspoon", "", msg) end

---@alias Repo { icon: string, location: string }
--------------------------------------------------------------------------------

-- get repos from perma-repos.csv
M.reposToSync = {} ---@type Repo[]
for line in io.lines(config.permaReposPath) do
	local location, icon, _ = line:match("^(.-),(.-),(.-)$")
	if not (location and icon) then return end
	table.insert(M.reposToSync, { location = location, icon = icon })
end

--------------------------------------------------------------------------------
-- SYNC IMPLEMENTATION

M.finishedSyncing = {} ---@type Repo[]
M.task_sync = {} ---@type table<string, hs.task>

---@async
---@param repo Repo
local function syncOneRepo(repo)
	local syncScriptPath = repo.location:gsub("~", os.getenv("HOME") or "") .. "/.sync-this-repo.sh"
	if not u.isExecutable(syncScriptPath) then return end

	M.task_sync[repo.location] = hs.task
		.new(syncScriptPath, function(exitCode, stdout, stderr)
			if exitCode == 0 then
				table.insert(M.finishedSyncing, repo)
			else
				local output = (stdout .. "\n" .. stderr):gsub("^%s+", ""):gsub("%s+$", "")
				local msg = ("⚠️️ %s %s Sync: %s"):format(repo.icon, repo.location, output)
				print(msg)
				hs.alert(msg, 5)
				notify(msg)
			end
		end)
		:start()
end

---@nodiscard
---@return string stillSyncingIcons
local function repoSyncsInProgress()
	local stillSyncingIcons = ""
	for _, repo in pairs(M.reposToSync) do
		local isStillSyncing = M.task_sync[repo.location] and M.task_sync[repo.location]:isRunning()
		if isStillSyncing then stillSyncingIcons = stillSyncingIcons .. repo.icon end
	end
	return stillSyncingIcons
end

---@param notifyOnSuccess boolean set to false for regularly occurring syncs
local function syncAllGitRepos(notifyOnSuccess)
	if repoSyncsInProgress() ~= "" then
		u.notify("🔁 Sync still in progress: " .. repoSyncsInProgress())
		return
	end

	for _, repo in pairs(M.reposToSync) do
		syncOneRepo(repo)
	end

	M.timer_AllSyncs = hs.timer
		.waitUntil(function() return repoSyncsInProgress() == "" end, function()
			local syncedIcons = hs.fnutils.map(M.finishedSyncing, function(r) return r.icon end) or {}
			local msg = "🔁 Sync done: " .. table.concat(syncedIcons)
			print(msg)
			if notifyOnSuccess then notify(msg) end
			M.finishedSyncing = {} -- reset
		end)
		:start()
end

--------------------------------------------------------------------------------
-- WHEN TO SYNC

-- 1. on systemstart
if u.isSystemStart() then
	local delay = env.isAtOffice and 5 or 0 -- spotify internet at the office
	u.defer(delay, function() syncAllGitRepos(true) end)
end

-- 2. every x minutes
M.timer_repoSync = hs.timer
	.doEvery(config.syncIntervalMins * 60, function()
		local idleMins = hs.host.idleTime() / 60
		if idleMins < config.syncIntervalMins then syncAllGitRepos(false) end
	end)
	:start()

-- 3. manually via Alfred: `hammerspoon://sync-repos`
hs.urlevent.bind("sync-repos", function()
	u.notify("🔁 Starting sync…")
	syncAllGitRepos(true)
end)

-- 4. when going to sleep or when unlocking
local c = hs.caffeinate.watcher
M.caff_SleepWatcherForRepoSync = c.new(function(event)
	if M.recentlyTriggered or env.isProjector() then return end

	if
		event == c.screensDidLock
		or event == c.screensDidUnlock
		or event == c.screensDidWake
		or event == c.screensaverWillStop
		or event == c.systemDidWake
	then
		syncAllGitRepos(true)
		M.recentlyTriggered = true
		u.defer(4, function() M.recentlyTriggered = false end)
	end
end):start()

--------------------------------------------------------------------------------
return M
