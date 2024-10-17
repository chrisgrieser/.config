local M = {}
local wu = require("win-management.window-utils")
--------------------------------------------------------------------------------

local config = {
	appsToAutoTile = {
		-- appName -> ignoredWinTitles
		Finder = { "^Move$", "^Copy$", "^Delete$", "^Finder Settings$", " Info$" },
		["Brave Browser"] = { "^Picture in Picture$", "^Task Manager$", "^DevTools" },
	},
	---@type fun(appName: string): hs.geometry
	oneWindowSizer = function(appName)
		if require("meta.environment").isProjector() then return hs.layout.maximized end
		return appName == "Finder" and wu.middleHalf or wu.pseudoMax
	end,
}

--------------------------------------------------------------------------------

---@param appName string
local function autoTile(appName)
	local app = hs.application.find(appName, true, true)
	if not app then return end
	app:selectMenuItem { "Window", "Bring All to Front" }
	app:unhide()

	-- need to manually filter windows, since window filter is sometimes buggy,
	-- not including the correct number of windows
	local ignoredWins = config.appsToAutoTile[appName]
	local wins = hs.fnutils.filter(app:allWindows(), function(win)
		local notIgnored = hs.fnutils.every(
			ignoredWins,
			function(ignored) return not win:title():find(ignored) end
		)
		return notIgnored and win:isStandard()
	end)
	---@cast wins hs.window[] -- fix wrong annotation

	-- GUARD prevent unnecessary runs or duplicate triggers
	if M["winCount_" .. appName] == #wins then return end
	M["winCount_" .. appName] = #wins

	local pos = {}
	if #wins == 0 then
		app:hide() -- prevent window-less app from keeping focus
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

	-- hide on deactivation, so sketchybar is not covered
	M["appWatcher_" .. appName] = aw.new(function(name, eventType, app)
		local dontTrigger = { "Alfred", "CleanShot X", "IINA" }
		local frontApp = hs.application.frontmostApplication():name()
		if
			name == appName
			and eventType == aw.deactivated
			and hs.fnutils.every(dontTrigger, function(a) return frontApp ~= a end)
		then
			app:hide()
		end
	end):start()
end

---@param appName string
function M.resetWinCount(appName) M["winCount_" .. appName] = nil end

--------------------------------------------------------------------------------
return M
