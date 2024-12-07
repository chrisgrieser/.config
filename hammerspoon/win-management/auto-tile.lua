local M = {}
local env = require("meta.environment")
local wu = require("win-management.window-utils")
--------------------------------------------------------------------------------

local config = {
	---@type table<string, string[]>
	appsToAutoTile = {
		-- appName -> ignoredWinTitles
		Finder = { "^Move$", "^Copy$", "^Delete$", "^Finder Settings$", " Info$" },
		["Brave Browser"] = { "^Picture in Picture$", "^Task Manager$", "^DevTools" },
	},
	---@type fun(appName: string)
	zeroWindowAction = function(appName)
		-- hide to prevent focussing windowless app
		-- not on projector, since weird interaction with IINA
		local autoTileApp = hs.application.find(appName, true, true)
		if autoTileApp and not env.isProjector() then autoTileApp:hide() end
	end,
	---@type fun(appName: string): hs.geometry
	oneWindowSize = function(appName)
		if env.isProjector() then return hs.layout.maximized end
		return appName == "Finder" and wu.middleHalf or wu.pseudoMax
	end,
	-- stylua: ignore
	dontTriggerHiding = {
		"Alfred", "CleanShot X", "IINA", "Ivory", "pinentry-mac", "Espanso",
		"Catch", "BetterZip", "System Preferences", "Transmission",
		"Slack", -- FIX bug where Slack briefly re-activates when opening link
	},
}

--------------------------------------------------------------------------------

---@param appName string
local function autoTile(appName)
	local app = hs.application.find(appName, true, true)
	if not app then return end
	app:selectMenuItem { "Window", "Bring All to Front" }
	app:unhide()

	-- need to manually filter windows, since window filter is sometimes buggy
	-- and does include the correct number of windows
	local ignoredWins = config.appsToAutoTile[appName]
	local wins = hs.fnutils.filter(app:allWindows(), function(win)
		local ignored = hs.fnutils.some(ignoredWins, function(name) return win:title():find(name) end)
		return not ignored and win:isStandard()
	end)
	---@cast wins hs.window[] -- fix wrong annotation

	-- GUARD prevent unnecessary runs or duplicate triggers
	if M["winCount_" .. appName] == #wins then return end
	M["winCount_" .. appName] = #wins

	local pos = {}
	if #wins == 0 then
		config.zeroWindowAction(appName)
	elseif #wins == 1 then
		pos[1] = config.oneWindowSize(appName)
	elseif #wins == 2 then
		pos = { hs.layout.left50, hs.layout.right50 }
	elseif #wins == 3 then
		pos = {
			{ h = 1, w = 0.333, x = 0, y = 0 },
			{ h = 1, w = 0.334, x = 0.333, y = 0 },
			{ h = 1, w = 0.333, x = 0.667, y = 0 },
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
			{ h = 0.5, w = 0.34, x = 0.33, y = 0 },
			{ h = 0.5, w = 0.34, x = 0.33, y = 0.5 },
			{ h = 0.5, w = 0.33, x = 0.67, y = 0 },
			#wins == 6 and { h = 0.5, w = 0.33, x = 0.67, y = 0.5 } or nil,
		}
	end

	for i = 1, #pos do
		wu.moveResize(wins[i], pos[i])
	end
end

--------------------------------------------------------------------------------

-- triggering conditions
local wf = hs.window.filter
local aw = hs.application.watcher
for appName, ignoredWins in pairs(config.appsToAutoTile) do
	M["winFilter_" .. appName] = wf.new(appName)
		:setOverrideFilter({ rejectTitles = ignoredWins, allowRoles = "AXStandardWindow" })
		:subscribe(wf.windowCreated, function() autoTile(appName) end)
		:subscribe(wf.windowDestroyed, function() autoTile(appName) end)
		:subscribe(wf.windowFocused, function() autoTile(appName) end)

	-- hide on deactivation (e.g., so sketchybar is not covered)
	M["appWatcher_" .. appName] = aw.new(function(name, eventType, autoTileApp)
		local frontApp = hs.application.frontmostApplication()
		if not frontApp then return end

		-- FIX weird bug where opening liks sometimes activates a browser twice…
		if frontApp:name() == appName then return end

		local dontTrigger = config.dontTriggerHiding
		local ignored = hs.fnutils.some(dontTrigger, function(n) return frontApp:name() == n end)
		if name == appName and eventType == aw.deactivated and not ignored then autoTileApp:hide() end
	end):start()
end

---helper function, so window-closing modules can reset the count here
---@param appName string
function M.resetWinCount(appName) M["winCount_" .. appName] = nil end

--------------------------------------------------------------------------------
return M
