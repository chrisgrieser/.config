local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")
local aw = hs.application.watcher

---@return integer
local function now() return os.time() end

--------------------------------------------------------------------------------

-- INFO This is essentially an implementation of the inspired by the macOS app
-- [quitter](https://marco.org/apps), this module quits any app if long enough idle

---CONFIG
---times after which apps should quit, in minutes
---(Apps not in this list will be ignored and never quit automatically).
M.thresholds = {
	Slack = 20,
	[env.mailApp] = 5,
	Highlights = 90,
	Discord = 180, -- when Steam is not on
	BusyCal = 2,
	neovide = 120, -- needs lowercase
	["Alfred Preferences"] = 20,
	["System Settings"] = 2,
	Finder = 20, -- only closes windows when not on projector
	Obsidian = nil, -- do not autoquit due to omnisearch indexing
}

--------------------------------------------------------------------------------

---@param appName string name of the app
local function quit(appName)
	local suffix = ""

	-- don't leave voice call when gaming
	if appName == "Discord" and u.appRunning("Steam") then return end

	if appName == "Finder" then
		if env.isProjector() then return end
		local finderWins = u.app("Finder"):allWindows()
		if #finderWins == 0 then return end
		for _, win in pairs(finderWins) do
			win:close()
		end
		suffix = "(windows closed)"
	else
		u.app(appName):kill()
	end
	print("📴 AutoQuitting: " .. appName .. " " .. suffix)
	M.idleApps[appName] = nil
end

--------------------------------------------------------------------------------

M.idleApps = {} ---table containing all apps with their last activation time

--Initialize on load: fills `g.idleApps` with all running apps and the current time
for app, _ in pairs(M.thresholds) do
	if u.appRunning(app) then M.idleApps[app] = now() end
end

---log times when an app has been deactivated
M.aw_appDeactivation = aw.new(function(appName, event)
	if not appName or appName == "" then return end -- empty string as safeguard for special apps

	if event == aw.deactivated then
		M.idleApps[appName] = now()
	elseif event == aw.activated or event == aw.terminated then
		M.idleApps[appName] = nil -- removes active or closed app from table
	end
end):start()

--------------------------------------------------------------------------------

---check apps regularly and quit if idle for longer than their thresholds
local checkIntervallSecs = 20
M.timer_autoQuitter = hs.timer
	.doEvery(checkIntervallSecs, function()
		for app, lastActivation in pairs(M.idleApps) do
			-- can't do this with guard clause, since lua has no `continue`
			local appHasThreshhold = M.thresholds[app] ~= nil
			local appIsRunning = u.appRunning(app)

			if appHasThreshhold and appIsRunning then
				local idleTimeSecs = now() - lastActivation
				local thresholdSecs = M.thresholds[app] * 60
				if idleTimeSecs > thresholdSecs then quit(app) end
			end
		end
	end)
	:start()

--------------------------------------------------------------------------------
return M
