-- INFO prevent maximized window from covering `sketchybar` if they are unfocused
--------------------------------------------------------------------------------

local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")

local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- CONFIG
local neverHide = {
	"Alfred",
	"CleanShot X",
	"IINA",
	"pinentry-mac",
	"Catch",
	"Hammerspoon",
	"Steam",
}

M.aw_maxWindows = aw.new(function(appName, event, app)
	-- FIX Steam window somehow not working correctly, causing endless flipping
	if u.appRunning("Steam") then return end

	-- never hide these apps when they deactivate or when they are front
	if hs.fnutils.contains(neverHide, appName) or u.isFront(neverHide) then return end

	if not env.isProjector() and event == aw.deactivated then
		for _, win in pairs(app:allWindows()) do
			local coversLeftTopCorner = win:frame().x == 0 and win:frame().y == 0
			if coversLeftTopCorner then app:hide() end
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
