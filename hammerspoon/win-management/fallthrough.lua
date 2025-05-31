local M = {}

local u = require("meta.utils")
local wf = hs.window.filter
local aw = hs.application.watcher
--------------------------------------------------------------------------------

local config = {
	fallthrough = {
		whenNoWin = { "Finder", "Brave Browser", "Obsidian" },
		always = { "Ivory", "Transmission" },
	},
	disableFallthroughWhenRunning = { "Steam" },
}

--------------------------------------------------------------------------------

local function fallthrough()
	if u.appRunning(config.disableFallthroughWhenRunning) then return end

	u.defer(0.1, function() -- deferring to ensure windows are already switched/created
		local frontApp = hs.application.frontmostApplication()
		local fallthroughWhenNoWin = hs.fnutils.contains(
			config.fallthrough.whenNoWin,
			frontApp:name()
		) and #(frontApp:allWindows()) == 0
		local fallThroughAlways = hs.fnutils.contains(config.fallthrough.always, frontApp:name())
		if not fallthroughWhenNoWin and not fallThroughAlways then return end

		local nextWin = hs.fnutils.find(
			hs.window:orderedWindows(), -- all visible windows in order
			function(win)
				if not win:application() or not win:isStandard() then return false end
				local appName = win:application():name()
				local fromFallThroughApp = hs.fnutils.contains(config.fallthrough.always, appName)
				return not fromFallThroughApp
			end
		)
		if not nextWin then return end

		nextWin:focus()
	end)
end

--------------------------------------------------------------------------------
-- TRIGGERS
M.wf_windowDestroyed = wf
	.new(true) -- `true` = any app
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, fallthrough)

M.aw_noWinActivated = aw.new(function(name, event, _app)
	if event == aw.activated and hs.fnutils.contains(config.fallthrough.whenNoWin, name) then
		fallthrough()
	end
end):start()

--------------------------------------------------------------------------------
return M
