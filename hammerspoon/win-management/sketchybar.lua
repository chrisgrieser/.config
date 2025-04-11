-- INFO prevent maximized window from covering sketchybar if they are unfocused
--------------------------------------------------------------------------------

local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")

local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- CONFIG
local dontTriggerHidingOtherApps = { "Alfred", "CleanShot X", "IINA", "pinentry-mac", "Catch" }

M.aw_maxWindows = aw.new(function(appName, event, app)
	if appName == "Hammerspoon" then return end -- never hide the hammerspoon console
	if event ~= aw.deactivated or env.isProjector() or u.isFront(dontTriggerHidingOtherApps) then
		return
	end

	for _, win in pairs(app:allWindows()) do
		local coversLeftTopCorner = win:frame().x == 0 and win:frame().y == 0
		if coversLeftTopCorner then
			app:hide()
			return
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
