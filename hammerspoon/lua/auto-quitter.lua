local u = require("lua.utils")
local env = require("lua.environment-vars")
--------------------------------------------------------------------------------
-- INFO This is essentially an implementation of the inspired by the macOS app
-- [quitter](https://marco.org/apps), this module quits any app if long enough idle

---CONFIG
---times after which apps should quit, in minutes
---(Apps not in this list will be ignored and never quit automatically).
Thresholds = {
	Slack = 20,
	[env.mailApp] = 5,
	Highlights = 90, -- not left when Steam is one
	Discord = 180,
	BusyCal = 2,
	neovide = 120, -- needs lowercase
	Hammerspoon = 3, -- affects the console, not hammerspoon itself
	["Alfred Preferences"] = 20,
	["System Settings"] = 2,
	Finder = 20, -- only closes windows

	-- INFO only minimized since the "Search Obsidian in Google" plugin requires
	-- Obsidian being open to work. Not hidden, so there is no interference with
	-- the app-hiding from Hammerspoon
	Obsidian = 100,
}

---@param app string name of the app
local function quit(app)
	local suffix = ""

	-- don't leave voice call when gaming
	if app == "Discord" and u.appRunning("Steam") then return end

	if app == "Finder" then
		local finderWins = u.app("Finder"):allWindows()
		if #finderWins == 0 then return end
		for _, win in pairs(finderWins) do
			win:close()
		end
		suffix = " (windows closed)"
	elseif app == "Obsidian" then
		u.app("Obsidian"):mainWindow():minimize()
		suffix = " (window minimized)"
	elseif app == "Hammerspoon" then
		hs.closeConsole()
		suffix = " (Console)"
	else
		u.app(app):kill()
	end
	print("⏹️ AutoQuitting: " .. app .. suffix)
	IdleApps[app] = nil
end

--------------------------------------------------------------------------------

IdleApps = {} ---table containing all apps with their last activation time
local now = os.time

--Initialize on load: fills `IdleApps` with all running apps and the current time
for app, _ in pairs(Thresholds) do
	if u.appRunning(app) then IdleApps[app] = now() end
end

---log times when an app has been deactivated
DeactivationWatcher = u.aw
	.new(function(app, event)
		if not app or app == "" then return end -- empty string as safeguard for special apps

		if event == u.aw.deactivated then
			IdleApps[app] = now()
		elseif event == u.aw.activated or event == u.aw.terminated then
			IdleApps[app] = nil -- removes active or closed app from table
		end
	end)
	:start()

--------------------------------------------------------------------------------

---check apps regularly and quit if idle for longer than their thresholds
local checkIntervallSecs = 20
AutoQuitterTimer = hs.timer
	.doEvery(checkIntervallSecs, function()
		for app, lastActivation in pairs(IdleApps) do
			-- can't do this with guard clause, since lua has no `continue`
			local appHasThreshhold = Thresholds[app] ~= nil
			local appIsRunning = u.appRunning(app)

			if appHasThreshhold and appIsRunning then
				local idleTimeSecs = now() - lastActivation
				local thresholdSecs = Thresholds[app] * 60
				if idleTimeSecs > thresholdSecs then quit(app) end
			end
		end
	end)
	:start()
