-- prevent keeping focus when closing a window
--------------------------------------------------------------------------------
local M = {}

local u = require("meta.utils")

local wf = hs.window.filter
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- CONFIG
local config = {
	fallthroughWhenNoWin = { "Finder", "Brave Browser", "Obsidian" },
	alwaysFallthrough = { "Ivory", "Transmission" },
	noFallthroughWhenrunning = { "Steam" },
}

--------------------------------------------------------------------------------

local function focusNext()
	if hs.fnutils.contains(config.noFallthroughWhenrunning, hs.application.frontmostApplication():name()) then return end
	local nextWin = hs.fnutils.find(
		hs.window:orderedWindows(), -- all visible windows in order
		function(win)
			if not win:application() or not win:isStandard() then return false end
			local appName = win:application():name()
			local fromFallThroughApp = hs.fnutils.contains(config.alwaysFallthrough, appName)
			return not fromFallThroughApp
		end
	)
	if nextWin then nextWin:focus() end
end

---@param mode "noWin"|"always"
local function fallthrough(mode)
	if u.appRunning(config.noFallthroughWhenrunning) then return end

	u.defer({ 0.1, 0.5 }, function() -- deferring to ensure windows are already switched/created
		local frontApp = hs.application.frontmostApplication()
		local apps = mode == "noWin" and config.fallthroughWhenNoWin or config.alwaysFallthrough
		local fallthroughIsFront = hs.fnutils.contains(apps, frontApp:name())
		local noWins = #(frontApp:allWindows()) == 0 and mode == "noWin"
		if fallthroughIsFront and noWins then focusNext() end
	end)
end

--------------------------------------------------------------------------------

M.wf_fallthroughNoWin = wf
	.new(true) -- `true` = any app
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, fallthrough)

M.aw_fallthroughNoWin = aw.new(function(name, event, _app)
	-- activation of a fallthrough app
	if event == aw.activated and hs.fnutils.contains(config.fallthroughWhenNoWin, name) then
		fallthrough()
	end
end):start()

--------------------------------------------------------------------------------

-- prevent unintended focusing after closing a window / quitting app
local function fallthroughAlways()
	if u.appRunning(config.noFallthroughWhenrunning) then return end
	u.defer(0.1, function()
		local frontApp = hs.application.frontmostApplication()
		local fallthroughIsFront = hs.fnutils.contains(config.alwaysFallthrough, frontApp:name())
		if fallthroughIsFront then focusNext() end
	end)
end

M.wf_fallthroughAlways = wf
	.new(true) -- `true` -> all windows
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, fallthroughAlways)

M.aw_fallthroughAlways = aw.new(function(appName, event, _)
	if hs.fnutils.contains(config.alwaysFallthrough, appName) then return end
	if event == aw.terminated then fallthroughAlways() end
end):start()

--------------------------------------------------------------------------------
return M
