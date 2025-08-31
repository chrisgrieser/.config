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
		local screen = hs.mouse.getCurrentScreen() ---@diagnostic disable-line: undefined-field
		if not screen then return end
		local screenF = screen:fullFrame()
		local onlyWindow = #app:allWindows() == 1
		for _, win in pairs(app:allWindows()) do
			local coversLeftTopCorner = win:frame().x == 0 and win:frame().y == 0
			local isMaximized = win:frame().w == screenF.w and win:frame().h == screenF.h
			-- left-half windows are only hidden when they are not the only window
			-- (e.g. two tiled Finder windows). This prevents hiding windows we are
			-- working on via left-half-right-half tiling.
			if isMaximized or (coversLeftTopCorner and not onlyWindow) then app:hide() end
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
