require("lua.utils")
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
	alacritty = 20,-- needs lowercase
	Lire = 2,
	["Alfred Preferences"] = 15,
	["System Settings"] = 2,
	Finder = 10, -- only closes windows
}

--------------------------------------------------------------------------------

IdleApps = {} ---table containing all apps with their last activation time
local now = os.time

--Initialize on load: fills `IdleApps` with all running apps and the current time
for app, _ in pairs(Thresholds) do
	if AppIsRunning(app) then IdleApps[app] = now() end
end

---log times when an app has been deactivated
DeactivationWatcher = Aw.new(function(app, event)
	if not app or app == "" then return end -- safeguard for special apps

	if event == Aw.deactivated then
		IdleApps[app] = now()
	elseif event == Aw.activated or event == Aw.terminated then
		IdleApps[app] = nil -- removes active or closed app from table
	end
end):start()

--------------------------------------------------------------------------------

---@param app string name of the app
local function quitter(app)
	if app == "Finder" then
		for _, win in pairs(App("Finder"):allWindows()) do
			win:close()	
		end
	else
		App(app):kill()
	end
	print("⏹️ AutoQuitting: " .. app)
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
			local appIsRunning = hs.application.get(app)

			if appHasThreshhold and appIsRunning then
				local idleTimeSecs = now() - lastActivation
				local thresholdSecs = Thresholds[app] * 60
				if idleTimeSecs > thresholdSecs then quitter(app) end
			end
		end
	end)
	:start()
