local M = {} -- persist from garbage collector

local u = require("meta.utils")
local wu = require("win-management.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------

local function moveToSide()
	local masto = u.app("Mona")
	if not masto then return end
	local mastodonUsername = "pseudometa" -- CONFIG
	local mastoWin = masto:findWindow("Mona") or masto:findWindow(mastodonUsername)
	if not mastoWin then return end

	if masto:isHidden() then masto:unhide() end
	mastoWin:setFrame(wu.toTheSide)
	mastoWin:raise()
end

---@param win? hs.window
local function showAndMoveOrHideTickerApp(win)
	-- GUARD
	local masto = u.app("Mona")
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

M.aw_monaLaunched = aw.new(function(appName, event)
	if appName == "Mona" and event == aw.launched then u.defer(1, moveToSide) end
end):start()

--------------------------------------------------------------------------------

-- FALLTHROUGH
-- prevent unintended focusing after qutting another app or closing last window
M.aw_fallthrough = aw.new(function(_, event)
	if event ~= aw.terminated then return end
	u.defer(0.15, function()
		local nonMonaWin = hs.fnutils.find(
			hs.window:orderedWindows(),
			function(win) return win:application() and win:application():name() ~= "Mona" end
		)
		if nonMonaWin and u.isFront("Mona") then nonMonaWin:focus() end
	end)
end):start()

--------------------------------------------------------------------------------
-- SPECIAL WINS

-- * auto-focus compose win when activating
-- * auto-close media wins when deactivating
M.aw_forSpecialMastoWins = aw.new(function(appName, event, masto)
	if appName == "Mona" and event == aw.activated then
		masto:selectMenuItem { "Window", "Bring All to Front" }
		local composeWin = masto:findWindow("Compose")
		if composeWin then composeWin:focus() end
	elseif appName == "Mona" and event == aw.deactivated then
		local mediaWin = masto:findWindow("Media") or masto:findWindow("Image")
		local frontApp = hs.application.frontmostApplication():name()
		if mediaWin and frontApp ~= "Alfred" then
			mediaWin:close()
			hs.eventtap.keyStroke({ "cmd" }, "w", 1, masto) -- redundancy as closing not reliable
		end
	end
end):start()

--------------------------------------------------------------------------------
-- FIX Mona's autoscroll often not fully scrolling up

local function homeAndScrollUp()
	-- prevent too many concurrent calls
	if M.isScrolling then return end
	M.isScrolling = true
	u.defer(10, function() M.isScrolling = false end)

	-- GUARD only scrolling when not idle, to not prevent the machine from going to sleep
	if hs.host.idleTime() > 120 or not u.screenIsUnlocked() then return end

	-- GUARD only if Mona is running in background and already has window
	local mona = u.app("Mona")
	if not mona or mona:isFrontmost() or not mona:mainWindow() then return end

	local key = hs.eventtap.keyStroke
	key({ "cmd" }, "left", 1, mona) -- go back
	key({ "cmd" }, "1", 1, mona) -- go to home tab
	key({ "cmd" }, "R", 1, mona) -- refresh
	u.defer({ 1, 4 }, function() -- wait for posts to load
		key({ "cmd" }, "up", 1, mona) -- scroll up
	end)
end

-- triggers
local scrollEveryMins = 5 -- CONFIG
M.timer_regularScroll = hs.timer.doEvery(scrollEveryMins * 60, homeAndScrollUp):start()

M.aw_monaDeavtivated = aw.new(function(appName, event)
	if appName == "Mona" and event == aw.deactivated then homeAndScrollUp() end
end):start()

if u.isSystemStart() then homeAndScrollUp() end

--------------------------------------------------------------------------------
return M
