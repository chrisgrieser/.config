local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")

local aw = hs.application.watcher
local now = os.time

--------------------------------------------------------------------------------

---CONFIG
---times after which apps should quit, in minutes
---(Apps not in this list will be ignored and never quit automatically).
---@type table<string, integer|nil>
M.thresholdMins = {
	GoodTask = 5,
	Slack = 20,
	Mimestream = 5,
	Highlights = 90,
	Obsidian = 90,
	Discord = 180,
	BusyCal = 5,
	["wezterm-gui"] = 45, -- does not work with "WezTerm"
	["Alfred Preferences"] = 20,
	["System Settings"] = 2,
	Finder = 20, -- only closes windows when not on projector
}
local checkIntervalSecs = 30

--------------------------------------------------------------------------------

---@param appName string name of the app
local function quit(appName)
	if appName == "Finder" then
		if env.isProjector() then return end
		local finderWins = u.app("Finder"):allWindows()
		if #finderWins == 0 then return end
		for _, win in pairs(finderWins) do
			win:close()
		end
	else
		u.quitApps(appName)
	end
	print("📴 AutoQuitting: " .. appName)
	M.idleApps[appName] = nil
end

--------------------------------------------------------------------------------
-- Initialize

---apps with their last activation time
---@type table<string, integer|nil>
M.idleApps = {}

-- fill `idleApps` with all running apps and the current time
for app, _ in pairs(M.thresholdMins) do
	if u.appRunning(app) then M.idleApps[app] = now() end
end

--------------------------------------------------------------------------------

---Watch app (de)activation & update `idleApps`
M.aw_appDeactivation = aw.new(function(appName, event)
	if not appName or appName == "" then return end -- empty string as safeguard for special apps

	if event == aw.deactivated then
		M.idleApps[appName] = now()
	elseif event == aw.activated or event == aw.terminated then
		M.idleApps[appName] = nil -- removes active or closed app from table
	end
end):start()

---Check apps regularly & quit if idle
M.timer_autoQuitter = hs.timer
	.doEvery(checkIntervalSecs, function()
		for app, lastActivation in pairs(M.idleApps) do
			-- can't do this with guard clause, since lua has no `continue`
			local appHasThreshold = M.thresholdMins[app] ~= nil
			local appIsRunning = u.appRunning(app)

			if appHasThreshold and appIsRunning then
				local idleTimeSecs = now() - lastActivation
				local thresholdSecs = M.thresholdMins[app] * 60
				if idleTimeSecs > thresholdSecs then quit(app) end
			end
		end
	end)
	:start()

--------------------------------------------------------------------------------
return M
