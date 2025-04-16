-- INFO prevent maximized window from covering sketchybar if they are unfocused
--------------------------------------------------------------------------------

local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")

local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- CONFIG
local neverHide = { "Alfred", "CleanShot X", "IINA", "pinentry-mac", "Catch", "Hammerspoon" }

M.aw_maxWindows = aw.new(function(appName, event, app)
	-- never hide these apps when they deactivate, never hide these other apps
	-- when these apps become activated.
	if hs.fnutils.contains(neverHide, appName) or u.isFront(neverHide) then return end
	if env.isProjector() then return end

	if event == aw.deactivated then
		for _, win in pairs(app:allWindows()) do
			local coversLeftTopCorner = win:frame().x == 0 and win:frame().y == 0
			if coversLeftTopCorner then app:hide() end
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
