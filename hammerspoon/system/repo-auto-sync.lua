local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
--------------------------------------------------------------------------------

local config = {
	syncIntervalMins = 30,
	syncScriptAtLocation = ".sync-this-repo.sh",

	-- csv-format: "location,icon"
	permaReposPath = os.getenv("HOME") .. "/.config/perma-repos.csv",
}

--------------------------------------------------------------------------------
-- SYNC IMPLEMENTATION

---@alias Repo { icon: string, location: string }

---@param silent? "silent"
local function syncAllGitRepos(silent)
	-- idempotent
	if M.isSyncing then return end
	M.isSyncing = true
	u.defer(3, function() M.isSyncing = false end)

	-- reset
	M.reposToSync = {} ---@type Repo[]
	M.finishedSyncing = {} ---@type Repo[]
	M.task_sync = {} ---@type table<string, hs.task>

	-- get all repos to sync
	for line in io.lines(config.permaReposPath) do
		local location, icon, _ = line:match("^([^,]+),([^,]+)")
		assert(location and icon, "invalid repo line: " .. line)
		table.insert(M.reposToSync, { location = location, icon = icon })
	end

	-- helper func
	local function repoSyncsInProgress() ---@return string stillSyncingIcons
		local stillSyncingIcons = ""
		for _, repo in pairs(M.reposToSync) do
			local isStillSyncing = M.task_sync[repo.location]
				and M.task_sync[repo.location]:isRunning()
			if isStillSyncing then stillSyncingIcons = stillSyncingIcons .. repo.icon end
		end
		return stillSyncingIcons
	end

	-- GUARD
	local hasInternetAccess = hs.network.reachability.internet():statusString():find("R") ---@diagnostic disable-line: undefined-field
	if not hasInternetAccess then
		u.notify("⛔🛜 No internet connection.")
		return
	end
	local stillInProgress = repoSyncsInProgress()
	if stillInProgress ~= "" then
		u.notify("🔁 Sync still in progress: " .. stillInProgress)
		return
	end

	-- sync them
	for _, repo in pairs(M.reposToSync) do
		local syncScriptPath = repo.location:gsub("^~", os.getenv("HOME") or "")
			.. "/"
			.. config.syncScriptAtLocation
		assert(u.isExecutableFile(syncScriptPath), "no sync script found at " .. syncScriptPath)

		M.task_sync[repo.location] = hs.task
			.new(syncScriptPath, function(exitCode, stdout, stderr)
				if exitCode == 0 then
					table.insert(M.finishedSyncing, repo)
				else
					local output = (stdout .. "\n" .. stderr):gsub("^%s+", ""):gsub("%s+$", "")
					local msg = ("⚠️️ %s %s Sync: %s"):format(repo.icon, repo.location, output)
					print(msg)
					hs.alert(msg, 5)
				end
			end)
			:start()
	end

	-- notify when done
	M.timer_AllSyncs = hs.timer
		.waitUntil(function() return repoSyncsInProgress() == "" end, function()
			local syncedIcons = hs.fnutils.map(M.finishedSyncing, function(r) return r.icon end) or {}
			local msg = #syncedIcons > 0 and "🔁 Sync done: " .. table.concat(syncedIcons)
				or "⚠️ Sync issue"
			print(msg)
			if #syncedIcons == 0 or not silent then hs.notify.show("Hammerspoon", "", msg) end
		end)
		:start()
end

--------------------------------------------------------------------------------
-- SYNC TRIGGERS

-- 1. systemstart
if u.isSystemStart() then syncAllGitRepos() end

-- 2. every x minutes
M.timer_repoSync = hs.timer
	.doEvery(config.syncIntervalMins * 60, function()
		local idleMins = hs.host.idleTime() / 60
		if idleMins < config.syncIntervalMins then syncAllGitRepos("silent") end
	end)
	:start()

-- 3. manually via Alfred: `hammerspoon://sync-repos`
hs.urlevent.bind("sync-repos", function()
	u.notify("🔁 Starting sync…")
	syncAllGitRepos()
end)

-- 4. when going to sleep or when unlocking
local c = hs.caffeinate.watcher
M.caff_SleepWatcherForRepoSync = c.new(function(event)
	if env.isProjector() then return end

	if event == c.screensDidLock then
		syncAllGitRepos()
	elseif event == c.screensDidWake or event == c.systemDidWake then
		u.defer(2, syncAllGitRepos)
	end
end):start()

--------------------------------------------------------------------------------
return M
