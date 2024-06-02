local M = {} -- persist from garbage collector

local env = require("modules.environment-vars")
local u = require("modules.utils")

local aw = hs.application.watcher
local now = os.time
--------------------------------------------------------------------------------

---times after which apps should quit, in minutes
---(Apps not in this list will be ignored and never quit automatically).
---@class (exact) autoQuitterConfig
---@field thresholdMins table<string, integer>
---@field checkIntervalSecs integer
local config = {
	checkIntervalSecs = 30,
	thresholdMins = {
		Finder = 10, -- only closes windows (and only when not on projector)
		Hammerspoon = 3, -- only console window
		BusyCal = 5,
		Reminders = 5,
		Mimestream = 5,
		Slack = 25,
		Highlights = 90,
		Obsidian = 120,
		Discord = 180,
		["WezTerm"] = 150,
		["wezterm-gui"] = 150,
		["Alfred Preferences"] = 20,
		["System Settings"] = 3,
	},
}

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
	elseif appName == "Hammerspoon" then
		hs.closeConsole()
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
for app, _ in pairs(config.thresholdMins) do
	if u.appRunning(app) then M.idleApps[app] = now() end
end

--------------------------------------------------------------------------------

---Watch app (de)activation & update `idleApps`
M.aw_appDeactivation = aw.new(function(appName, event)
	-- ignore apps not included in configuration
	if config.thresholdMins[appName] == nil then return end

	if event == aw.deactivated then
		M.idleApps[appName] = now()
	elseif event == aw.activated or event == aw.terminated then
		M.idleApps[appName] = nil -- removes active or closed app from table
	end
end):start()

---Check apps regularly & quit if idle
M.timer_autoQuitter = hs.timer
	.doEvery(config.checkIntervalSecs, function()
		for app, lastActivation in pairs(M.idleApps) do
			-- can't do this with guard clause, since lua has no `continue`
			local appHasThreshold = config.thresholdMins[app] ~= nil
			local appIsRunning = u.appRunning(app)

			if appHasThreshold and appIsRunning then
				local idleTimeSecs = now() - lastActivation
				local thresholdSecs = config.thresholdMins[app] * 60
				if idleTimeSecs > thresholdSecs then quit(app) end
			end
		end
	end)
	:start()

--------------------------------------------------------------------------------
return M
