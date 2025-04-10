-- INFO prevent maximized window from covering sketchybar if they are unfocused
--------------------------------------------------------------------------------

local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")

local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- CONFIG
local dontTriggerHidingOtherApps = { "Alfred", "CleanShot X", "IINA", "pinentry-mac", "Catch" }

M.aw_maxWindows = aw.new(function(appName, event, app)
	if appName == "Hammerspoon" then return end -- lots of dummy windows
	if event ~= aw.deactivated or env.isProjector() or u.isFront(dontTriggerHidingOtherApps) then
		return
	end

	local hasCoveringWin = hs.fnutils.some(app:allWindows(), function(win)
		local maximized = wu.winHasSize(win, hs.layout.maximized)
		local leftHalf = wu.winHasSize(win, hs.layout.left50)
		return maximized or leftHalf
	end)
	local hasLikelyCoveringWin = #app:allWindows() > 2

	if hasCoveringWin or hasLikelyCoveringWin then app:hide() end
end):start()

--------------------------------------------------------------------------------
return M
