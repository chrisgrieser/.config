local M = {}
local wu = require("win-management.window-utils")
--------------------------------------------------------------------------------

local config = {
	appsToAutoTile = {
		-- appName -> ignoredWinTitles
		Finder = { "^Move$", "^Copy$", "^Delete$", "^Finder Settings$", " Info$" },
		["Brave Browser"] = {
			"^Picture in Picture$",
			"^Task Manager$",
			"^Developer Tools",
			"^DevTools",
		},
	},
	---@type fun(appName: string): hs.geometry
	oneWindowSizer = function(appName)
		if require("meta.environment").isProjector() then return hs.layout.maximized end
		return appName == "Finder" and wu.middleHalf or wu.pseudoMax
	end,
}

--------------------------------------------------------------------------------

---@param winfilter hs.window.filter
---@param appName string
local function autoTile(winfilter, appName)
	local wins = winfilter:getWindows()

	-- GUARD prevent unnecessary runs or duplicate triggers
	if M["winCount_" .. appName] == #wins then return end
	M["winCount_" .. appName] = #wins

	local app = hs.application.find(appName, true, true)
	if not app then return end
	local pos = {}
	app:selectMenuItem { "Window", "Bring All to Front" }

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
for appName, ignoredWins in pairs(config.appsToAutoTile) do
	M["winFilter_" .. appName] = wf.new(appName)
		:setOverrideFilter({ rejectTitles = ignoredWins, allowRoles = "AXStandardWindow" })
		:subscribe(wf.windowCreated, function() autoTile(M["winFilter_" .. appName], appName) end)
		:subscribe(wf.windowFocused, function() autoTile(M["winFilter_" .. appName], appName) end)
		:subscribe(wf.windowDestroyed, function()
			M.timer2 = hs.timer.doAfter(
				0.1,
				function() autoTile(M["winFilter_" .. appName], appName) end
			)
		end)

	-- INFO `windowFocused` is required as trigger, since ssometimes windows
	-- are created in the background without triggering the other triggers.
	-- Cannot check via app watcher and the `activation` event, since passing
	-- the win-filter does not contain windows when not passed via window filter
	-- trigger.
end

--------------------------------------------------------------------------------
return M
