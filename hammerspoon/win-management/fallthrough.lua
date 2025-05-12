-- prevent keeping focus when closing a window
--------------------------------------------------------------------------------
local M = {}

local u = require("meta.utils")

local wf = hs.window.filter
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- CONFIG
local fallthroughWhenNoWin = { "Finder", "Brave Browser", "Obsidian" }
local alwaysFallthrough = { "Ivory", "Transmission" }

--------------------------------------------------------------------------------

local function focusNext()
	local nextWin = hs.fnutils.find(
		hs.window:orderedWindows(), -- all visible windows in order
		function(win)
			if not win:application() or not win:isStandard() then return false end
			local appName = win:application():name()
			local fromFallThroughApp = hs.fnutils.contains(alwaysFallthrough, appName)
			return not fromFallThroughApp
		end
	)
	if nextWin then nextWin:focus() end
end

--------------------------------------------------------------------------------

local function fallthroughOnNoWin()
	u.defer(0.1, function() -- deferring to ensure windows are already switched/created
		local frontApp = hs.application.frontmostApplication()
		local fallthroughIsFront = hs.fnutils.contains(fallthroughWhenNoWin, frontApp:name())
		local noWins = #(frontApp:allWindows()) == 0
		if fallthroughIsFront and noWins then focusNext() end
	end)
end

M.wf_fallthroughNoWin = wf
	.new(true) -- `true` = any app
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, fallthroughOnNoWin)

M.aw_fallthroughNoWin = aw.new(function(name, event, _app)
	-- activation of a fallthrough app
	if event == aw.activated and hs.fnutils.contains(fallthroughWhenNoWin, name) then
		fallthroughOnNoWin()
	end
end):start()

--------------------------------------------------------------------------------

-- prevent unintended focusing after closing a window / quitting app
local function fallthroughAlways()
	u.defer(0.1, function()
		local frontApp = hs.application.frontmostApplication()
		local fallthroughIsFront = hs.fnutils.contains(alwaysFallthrough, frontApp:name())
		if fallthroughIsFront then focusNext() end
	end)
end

M.wf_fallthroughAlways = wf
	.new(true) -- `true` -> all windows
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, fallthroughAlways)

M.aw_fallthroughAlways = aw.new(function(appName, event, _)
	if hs.fnutils.contains(alwaysFallthrough, appName) then return end
	if event == aw.terminated then fallthroughAlways() end
end):start()

--------------------------------------------------------------------------------
return M
