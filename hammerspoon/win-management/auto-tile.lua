local M = {}

local env = require("meta.environment")
local wu = require("win-management.window-utils")
local wf = hs.window.filter
local aw = hs.application.watcher
--------------------------------------------------------------------------------

local config = {
	---@type table<string, string[]>
	appsToAutoTile = {
		-- appName -> ignoredWinTitles
		Finder = { "^Move$", "^Copy$", "^Delete$", "^Finder Settings$", " Info$" },
		["Brave Browser"] = { "^Picture in Picture$", "^Task Manager$", "^DevTools", "^Meet - " },
	},
	---@type fun(appName: string): hs.geometry
	oneWindowSize = function(appName)
		if env.isProjector() then return hs.layout.maximized end
		return appName == "Finder" and wu.middleHalf or wu.pseudoMax
	end,
}

--------------------------------------------------------------------------------

---@param appName string
local function autoTile(appName)
	local app = hs.application.find(appName, true, true)
	if not app then
		M["winCount_" .. appName] = nil
		return
	end

	-- need to manually filter windows, since window filter is sometimes buggy
	-- and does include the correct number of windows
	local ignoredWins = config.appsToAutoTile[appName]
	local wins = hs.fnutils.filter(app:allWindows(), function(win)
		local ignored = hs.fnutils.some(ignoredWins, function(name) return win:title():find(name) end)
		local mouseScreen = hs.mouse.getCurrentScreen()
		local onMouseScreen = mouseScreen and mouseScreen:id() == win:screen():id()
		return not ignored and win:isStandard() and onMouseScreen
	end) --[[@as hs.window[] ]]

	-- GUARD idempotent
	if M["winCount_" .. appName] == #wins and #wins > 1 then return end
	M["winCount_" .. appName] = #wins

	-- GUARD
	if #wins > 1 and env.isProjector() then return end

	local pos = {} ---@cast pos hs.geometry[]
	if #wins == 1 then
		pos = { config.oneWindowSize(appName) }
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
		}
		if #wins == 6 then table.insert(pos, { h = 0.5, w = 0.33, x = 0.67, y = 0.5 }) end
	end

	for i = 1, #pos do
		wu.moveResize(wins[i], pos[i] --[[@as hs.geometry]])
	end
end

---TRIGGERING CONDITIONS--------------------------------------------------------

for appName, ignoredWins in pairs(config.appsToAutoTile) do
	M["winFilter_" .. appName] = wf.new(appName)
		:setOverrideFilter({ rejectTitles = ignoredWins, allowRoles = "AXStandardWindow" })
		:subscribe(wf.windowCreated, function() autoTile(appName) end)
		:subscribe(wf.windowDestroyed, function() autoTile(appName) end)
		:subscribe(wf.windowFocused, function() autoTile(appName) end)

	M["appWatcher_" .. appName] = aw.new(function(name, event, autoTileApp)
		if event == aw.activated and name == appName then
			autoTile(appName)
			autoTileApp:selectMenuItem { "Window", "Bring All to Front" }
		elseif event == aw.terminated and name == appName then
			M.resetWinCount(appName)
		end
	end):start()
end

---HELPERS----------------------------------------------------------------------

---@param appName string
function M.resetWinCount(appName) M["winCount_" .. appName] = nil end

---@param win hs.window
---@return boolean
function M.winIsOfAutotileApp(win)
	local appName = win:application():name() ---@diagnostic disable-line: undefined-field
	local autoTileApps = {}
	for name, _ in pairs(config.appsToAutoTile) do
		table.insert(autoTileApps, name)
	end
	return hs.fnutils.contains(autoTileApps, appName)
end

--------------------------------------------------------------------------------
return M
