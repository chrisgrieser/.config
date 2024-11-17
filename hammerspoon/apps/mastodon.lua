local M = {} -- persist from garbage collector

local u = require("meta.utils")
local wu = require("win-management.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------

local function moveToSide()
	local masto = u.app("Ivory")
	if not masto then return end

	local mastoWin = masto:mainWindow()
	if masto:isHidden() then masto:unhide() end
	mastoWin:setFrame(wu.toTheSide)
	mastoWin:raise()
end

---@param win? hs.window
local function showAndMoveOrHideTickerApp(win)
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
	local winApp = win:application():name() ---@diagnostic disable-line: undefined-field
	if wu.winHasSize(win, hs.layout.maximized) and (hs.fnutils.contains(transBgApps, winApp)) then
		masto:hide()
	end
end

M.wf_someWindowActivity = wf
	.new(true) -- `true` -> all windows
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowMoved, showAndMoveOrHideTickerApp)
	:subscribe(wf.windowFocused, showAndMoveOrHideTickerApp)
	:subscribe(wf.windowCreated, showAndMoveOrHideTickerApp)

if u.isSystemStart() then moveToSide() end

M.aw_mastoLaunched = aw.new(function(appName, event)
	if appName == "Ivory" and event == aw.launched then u.defer(1, moveToSide) end
end):start()

--------------------------------------------------------------------------------

-- FALLTHROUGH
-- prevent unintended focusing after closing a window
M.wf_fallthrough = wf
	.new(true) -- `true` -> all windows
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, function()
		u.defer(0.15, function()
			local nonMastoWin = hs.fnutils.find(
				hs.window:orderedWindows(),
				function(win) return win:application() and win:application():name() ~= "Ivory" end
			)
			if nonMastoWin and u.isFront("Ivory") then nonMastoWin:focus() end
		end)
	end)

--------------------------------------------------------------------------------
-- SPECIAL WINS

-- * auto-focus compose win when activating
-- * auto-close media wins when deactivating
M.aw_forSpecialMastoWins = aw.new(function(appName, event, masto)
	if appName == "Ivory" and event == aw.activated then
		masto:selectMenuItem { "Window", "Bring All to Front" }
		local composeWin = masto:findWindow("Compose")
		if composeWin then composeWin:focus() end
	elseif appName == "Ivory" and event == aw.deactivated then
		local mediaWin = masto:findWindow("Media") or masto:findWindow("Image")
		local frontApp = hs.application.frontmostApplication():name()
		if mediaWin and frontApp ~= "Alfred" then
			mediaWin:close()
			hs.eventtap.keyStroke({ "cmd" }, "w", 1, masto) -- redundancy as closing not reliable
		end
	end
end):start()

--------------------------------------------------------------------------------

local function homeAndScrollUp()
	-- GUARD concurrent calls
	if M.isScrolling then return end
	M.isScrolling = true
	u.defer(10, function() M.isScrolling = false end)

	-- GUARD only when not idle, to not prevent the device from going to sleep
	if hs.host.idleTime() > 120 or not u.screenIsUnlocked() then return end

	-- GUARD only if app is running in background and already has window
	local masto = u.app("Ivory")
	if not masto or masto:isFrontmost() or #masto:allWindows() ~= 1 then return end

	local key = hs.eventtap.keyStroke
	key({}, "left", 1, masto) -- go back
	key({ "cmd" }, "1", 1, masto) -- go to home tab
	key({ "cmd", "shift" }, "R", 1, masto) -- refresh
	u.defer({ 1, 2, 4 }, function() -- wait for posts to load
		key({ "cmd" }, "up", 1, masto) -- scroll up
	end)
end

-- triggers
M.aw_mastoDeavtivated = aw.new(function(appName, event)
	if appName == "Ivory" and event == aw.deactivated then homeAndScrollUp() end
end):start()

--------------------------------------------------------------------------------
return M
