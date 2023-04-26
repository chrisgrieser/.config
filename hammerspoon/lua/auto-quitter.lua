local u = require("lua.utils")
--------------------------------------------------------------------------------
-- INFO This is essentially an implementation of the inspired by the macOS app
-- [quitter](https://marco.org/apps), this module quits any app if long enough idle

---CONFIG
---times after which apps should quit, in minutes
---(Apps not in this list will be ignored and never quit automatically).
Thresholds = {
	Slack = 15,
	Obsidian = 60,
	Mimestream = 5,
	Highlights = 90,
	Discord = 180,
	BusyCal = 2,
	neovide = 120, -- needs lowercase
	["wezterm-gui"] = 45, -- does not work with "WezTerm"
	Hammerspoon = 3, -- affects the console
	Lire = 3,
	["Alfred Preferences"] = 10,
	["System Settings"] = 2,
	Finder = 25, -- only closes windows
}

--------------------------------------------------------------------------------

IdleApps = {} ---table containing all apps with their last activation time
local now = os.time

--Initialize on load: fills `IdleApps` with all running apps and the current time
for app, _ in pairs(Thresholds) do
	if u.appRunning(app) then IdleApps[app] = now() end
end

---log times when an app has been deactivated
DeactivationWatcher = u.aw.new(function(app, event)
	if not app or app == "" then return end -- empty string as safeguard for special apps

	if event == u.aw.deactivated then
		IdleApps[app] = now()
	elseif event == u.aw.activated or event == u.aw.terminated then
		IdleApps[app] = nil -- removes active or closed app from table
	end
end):start()

--------------------------------------------------------------------------------

---@param app string name of the app
local function quit(app)
	local suffix = ""
	if app == "Finder" then
		for _, win in pairs(u.app("Finder"):allWindows()) do
			win:close()	
		end
		suffix = " (windows closed)"	
	elseif app == "Hammerspoon" then
		hs.closeConsole()
		app = "Hammerspoon"
		suffix = " (Console)"	
	elseif app == "wezterm-gui" then
		u.app(app):kill9() -- needs kill9 to avoid confirmation
		suffix = " (kill9)"	
	else
		u.app(app):kill()
	end
	print("⏹️ AutoQuitting: " .. app .. suffix)
	IdleApps[app] = nil
end

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
