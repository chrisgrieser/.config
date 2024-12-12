local M = {} -- persist from garbage collector

local u = require("meta.utils")
local wu = require("win-management.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter

--------------------------------------------------------------------------------
-- MOVE TO THE SIDE

local function moveToSide()
	local masto = u.app("Ivory")
	if not masto then return end

	local mastoWin = masto:mainWindow()
	if not mastoWin then return end
	if masto:isHidden() then masto:unhide() end
	mastoWin:setFrame(wu.toTheSide)
	mastoWin:raise()
end

if u.isSystemStart() then moveToSide() end

M.aw_mastoLaunched = aw.new(function(appName, event)
	if appName == "Ivory" and event == aw.launched then u.defer(1, moveToSide) end
end):start()

--------------------------------------------------------------------------------
-- SHOW/HIDE APP

---@param win? hs.window
local function showAndMoveOrHide(win)
	-- GUARD
	local masto = u.app("Ivory")
	local frontWin = hs.window.focusedWindow()
	if not (masto and win and frontWin) then return end
	local winNotFrontmost = win:id() ~= frontWin:id()
	if winNotFrontmost then return end

	-- SHOW & MOVE TO SIDE if other window is pseudo-maximized or centered
	if wu.winHasSize(win, wu.pseudoMax) or wu.winHasSize(win, wu.middleHalf) then
		moveToSide()
		return
	end

	-- HIDE when transparent app is maximized
	local transBgApps = { "Neovide", "neovide", "Obsidian", "wezterm-gui", "WezTerm" }
	local winApp = win:application() and win:application():name() ---@diagnostic disable-line: undefined-field
	if wu.winHasSize(win, hs.layout.maximized) and (hs.fnutils.contains(transBgApps, winApp)) then
		masto:hide()
	end
end

M.wf_someWindowActivity = wf
	.new(true) -- `true` -> all windows
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowMoved, showAndMoveOrHide)
	:subscribe(wf.windowFocused, showAndMoveOrHide)
	:subscribe(wf.windowCreated, showAndMoveOrHide)

-- redundancy to `windowFocused`, which is for some reason not always triggered
M.aw_windowActivation = aw.new(function(appName, event, _appObj)
	if appName ~= "Ivory" and event == aw.activated then
		showAndMoveOrHide(hs.window.focusedWindow())
	end
end):start()

--------------------------------------------------------------------------------,
-- FALLTHROUGH

-- prevent unintended focusing after closing a window / quitting app
local function fallthrough()
	u.defer(0.15, function()
		local nonMastoWin = hs.fnutils.find(
			hs.window:orderedWindows(),
			function(win) return win:application() and win:application():name() ~= "Ivory" end
		)
		if nonMastoWin and u.isFront("Ivory") then nonMastoWin:focus() end
	end)
end

M.wf_fallthrough = wf
	.new(true) -- `true` -> all windows
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, fallthrough)
M.aw_fallthrough = aw.new(function(appName, event, _)
	if event == aw.terminated and appName ~= "Ivory" then fallthrough() end
end):start()

--------------------------------------------------------------------------------
-- RESET ON DEACTIVATION

function M.scrollUp()
	local masto = u.app("Ivory")
	if not masto then return end
	hs.eventtap.keyStroke({}, "left", 1, masto) -- go back
	hs.eventtap.keyStroke({ "cmd" }, "1", 1, masto) -- go to home tab
	hs.eventtap.keyStroke({ "cmd" }, "up", 1, masto) -- scroll up
end

M.aw_mastoDeavtivated = aw.new(function(appName, event, masto)
	if appName == "Ivory" and event == aw.deactivated then
		-- close any media windows
		local mediaWin = masto:findWindow("Ivory")
		local frontApp = hs.application.frontmostApplication():name()
		if mediaWin and frontApp ~= "Alfred" then hs.eventtap.keyStroke({ "cmd" }, "w", 1, masto) end

		-- go back to home tab
		if #masto:allWindows() == 1 and not M.isScrolling then
			M.isScrolling = true
			u.defer(1, M.scrollUp)
			u.defer(10, function() M.isScrolling = false end)
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
