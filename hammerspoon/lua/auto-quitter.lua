require("lua.utils")
--------------------------------------------------------------------------------
-- INFO This is essentially an implementation of the inspired by the macOS app
-- [quitter](https://marco.org/apps), this module quits any app if long enough idle

-- CONFIG
---times after which apps should quit, in minutes. (Apps not in this list will
--simply be ignored and never quit automatically).
Thresholds = {
	Slack = 15,
	Obsidian = 90,
	Mimestream = 5,
	Discord = 180,
	BusyCal = 3,
	Neovide = 180,
	["Alfred Preferences"] = 15,
	Hammerspoon = 1, -- the console, not Hammerspoon itself
	Drafts = 3, -- has the extra condition of having no active Draft – see `quitter()`
	Finder = 10, -- requires `defaults write com.apple.Finder QuitMenuItem 1`
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

-- INFO the console is not triggered by the app watcher, so using window filter
Wf_hammerspoonConsole = Wf.new("Hammerspoon")
	:subscribe(Wf.windowUnfocused, function() IdleApps["Hammerspoon"] = now() end)
	:subscribe(Wf.windowFocused, function() IdleApps["Hammerspoon"] = nil end)

---OPTIONAL extra utility for Drafts.app
---@return number number of currently active Drafts
local function getDraftsCount()
	local exclude = IsAtOffice() and "home" or "office"
	local stdout, _ = hs.execute(
		[[python3 "$HOME/.config/sketchybar/numberOfDrafts.py" "tasklist" "]] .. exclude .. [["]]
	)
	local count = tonumber(stdout)
	if not stdout or not count then return 0 end
	return count
end

---quit app, with the extra condition of Drafts requiring zero drafts
---@param app string name of the app
local function quitter(app)
	if app == "Drafts" and getDraftsCount() > 0 then return end
	print("AutoQuitter: Quitting " .. app)
	IdleApps[app] = nil
	if app == "Hammerspoon" then
		hs.closeConsole()
	else
		hs.application(app):kill()
	end
end

---check apps regularly and quit if idle for longer than their thresholds
local checkIntervallSecs = 15
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
