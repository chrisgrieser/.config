local M = {}
local wu = require("modules.window-utils")
local wf = hs.window.filter
--------------------------------------------------------------------------------

-- CONFIG
local config = {
	appsToAutoTile = {
		-- appName -> ignoredWinTitles
		Finder = { "^Move$", "^Copy$", "^Delete$", "^Finder Settings$", " Info$" },
		Brave = { "^Picture in Picture$", "^Task Manager$", "^Developer Tools", "^DevTools" },
	},
	---@param appName string
	---@return hs.geometry
	oneWindowSizer = function(appName) 
		local pos = appName == "Finder" and wu.middleHalf or wu.pseudoMax
		local env = require("modules.environment-vars")
		if env.isProjector() then pos = hs.layout.maximized end
		return pos
	end,
}


---@param winfilter hs.window.filter
---@param appName string
local function autoTile(winfilter, appName)
	-- GUARD concurrent runs
	if M.autoTileInProgress then return end
	M.autoTileInProgress = true
	M.autoTileTimer = hs.timer.doAfter(0.3, function() M.autoTileInProgress = false end):start()

	local app = hs.application.find(appName, true, true)
	local wins = winfilter:getWindows()
	local pos = {}
	if #wins > 1 then app:selectMenuItem { "Window", "Bring All to Front" } end

	if #wins == 0 then
		app:hide()
	elseif #wins == 1 then
		pos[1] = config.oneWindowSizer(appName)
	elseif #wins == 2 then
		pos = { hs.layout.left50, hs.layout.right50 }
	elseif #wins == 3 then
		pos = {
			{ h = 1, w = 0.33, x = 0, y = 0 },
			{ h = 1, w = 0.34, x = 0.33, y = 0 },
			{ h = 1, w = 0.33, x = 0.67, y = 0 },
		}
	elseif #wins == 4 then
		pos = {
			{ h = 0.5, w = 0.5, x = 0, y = 0 },
			{ h = 0.5, w = 0.5, x = 0, y = 0.5 },
			{ h = 0.5, w = 0.5, x = 0.5, y = 0 },
			{ h = 0.5, w = 0.5, x = 0.5, y = 0.5 },
		}
	elseif #wins == 5 or #wins == 6 then
		pos = {
			{ h = 0.5, w = 0.33, x = 0, y = 0 },
			{ h = 0.5, w = 0.33, x = 0, y = 0.5 },
			{ h = 0.5, w = 0.33, x = 0.33, y = 0 },
			{ h = 0.5, w = 0.33, x = 0.33, y = 0.5 },
			{ h = 0.5, w = 0.33, x = 0.66, y = 0 },
			#wins == 6 and { h = 0.5, w = 0.33, x = 0.66, y = 0.5 } or nil,
		}
	end

	-- GUARD wins are already tiled but not in right order. Prevent wins glitching around.
	local allPositionsExist = hs.fnutils.every(pos, function(p)
		return hs.fnutils.some(wins, function(w) return wu.winHasSize(w, p) end)
	end)
	if allPositionsExist then return end

	for i = 1, #pos do
		wu.moveResize(wins[i], pos[i])
	end
end

-- conditions triggering the auto-tiling
for appName, ignoredWins in pairs(config.appsToAutoTile) do
	M[appName] = wf.new(appName)
		:setOverrideFilter({
			rejectTitles = ignoredWins,
			allowRoles = "AXStandardWindow",
		})
		:subscribe(wf.windowCreated, function() autoTile(M[appName], appName) end)
		:subscribe(wf.windowDestroyed, function() autoTile(M[appName], ap) end)
end

--------------------------------------------------------------------------------
return M
