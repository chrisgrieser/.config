require("lua.utils")
--------------------------------------------------------------------------------
-- inspired by the macOS app "quitter"

---table containing all apps with their last activation time
IdleApps = {}

---log times when an app has been deactivated
DeactivationWatcher = Aw.new(function(appName, eventType)
	if eventType == Aw.deactivated then
		local now = os.time()
		IdleApps[appName] = now
	elseif eventType == Aw.activated then
		IdleApps[appName] = nil -- removes active apps from the table
	end
end):start()

---check every ten second for idle apps
hs.timer.doEvery(10, function()
	local now = os.time()
	if IdleApps["Spotify"] then
		local diff = IdleApps["Spotify"] - now
		local threshold = 60
		if diff < threshold then
			
		end
	end
end)
