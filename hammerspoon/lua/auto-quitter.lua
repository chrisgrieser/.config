-- INFO This is essentially an implementation of the inspired by the macOS app
-- [quitter](https://marco.org/apps), this module quits any app if long enough idle
--------------------------------------------------------------------------------

-- CONFIG
---apps times after which apps should quit, in minutes
Thresholds = {
	Slack = 15,
	Obsidian = 60,
	Finder = 30,
	Mimestream = 10,
	BusyCal = 10,
	Drafts = 5, -- has the extra condition of having no active Draft – see `quitter()`
}

--------------------------------------------------------------------------------

IdleApps = {} ---table containing all apps with their last activation time
CheckIntervallSecs = 10
local aw = hs.application.watcher

---log times when an app has been deactivated
DeactivationWatcher = aw.new(function(appName, eventType)
	if not appName or appName == "" then return end
	if eventType == aw.deactivated then
		local now = os.time()
		IdleApps[appName] = now
	elseif eventType == aw.activated and eventType == aw.terminated then
		IdleApps[appName] = nil -- removes active app from the table
	end
end):start()

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
	local appObj = App.get(app)
	if appObj then appObj:kill() end
	IdleApps[app] = nil
end

---check apps regularly and quit if idle for longer than their thresholds
AutoQuitterTimer = hs.timer
	.doEvery(CheckIntervallSecs, function()
		local now = os.time()

		for app, lastActivation in pairs(IdleApps) do
			local appHasThreshhold = Thresholds[app] ~= nil

			if appHasThreshhold then
				local idleTimeSecs = now - lastActivation
				local thresholdSecs = Thresholds[app] * 60
				if idleTimeSecs > thresholdSecs then quitter(app) end
			end
		end
	end)
	:start()
