-- prevent keeping focus when closing a window
--------------------------------------------------------------------------------

local M = {}

local u = require("meta.utils")

local wf = hs.window.filter
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- CONFIG
local fallthroughApps = { "Finder", "Brave Browser", "Obsidian" }

local function fallthroughOnNoWin()
	u.defer(0.1, function() -- deferring to ensure windows are already switched/created
		local frontApp = hs.application.frontmostApplication()
		local isFront = hs.fnutils.contains(fallthroughApps, frontApp:name())
		local noWins = #(frontApp:allWindows()) == 0
		if not (isFront and noWins) then return end

		local nextWin = hs.fnutils.find(
			hs.window:orderedWindows(), -- all visible windows in order
			function(win)
				local fromFallThroughApp =
					hs.fnutils.contains(fallthroughApps, win:application():name()) ---@diagnostic disable-line: undefined-field
				return win:isStandard() and not fromFallThroughApp
			end
		)
		if nextWin then nextWin:focus() end -- hiding fallthrough-app does not work, must focus next win
	end)
end

M.wf_fallthroughNoWin = wf
	.new(true) -- `true` = any app
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, fallthroughOnNoWin)

M.aw_fallthroughNoWin = aw.new(function(name, event, _app)
	-- activation of a fallthrough app
	if event == aw.activated and hs.fnutils.contains(fallthroughApps, name) then
		fallthroughOnNoWin()
	end
end):start()

--------------------------------------------------------------------------------

-- prevent unintended focusing after closing a window / quitting app
local function fallthroughMastodon()
	u.defer(0.1, function()
		local nonMastoWin = hs.fnutils.find(
			hs.window:orderedWindows(),
			function(win) return win:application() and win:application():name() ~= "Ivory" end
		)
		if nonMastoWin and u.isFront("Ivory") then nonMastoWin:focus() end
	end)
end

M.wf_fallthroughMasto = wf
	.new(true) -- `true` -> all windows
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, fallthroughMastodon)

M.aw_fallthroughMasto = aw.new(function(appName, event, _)
	if event == aw.terminated and appName ~= "Ivory" then fallthroughMastodon() end
end):start()

--------------------------------------------------------------------------------
return M
