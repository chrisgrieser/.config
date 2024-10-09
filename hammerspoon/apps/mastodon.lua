local M = {} -- persist from garbage collector

local u = require("meta.utils")
local wu = require("win-management.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------

-- SHOW & MOVE TO SIDE if other window is pseudo-maximized or centered
-- HIDE if other window is maximized
local function moveToSide()
	local masto = u.app("Mona")
	if not masto then return end
	local mastodonUsername = "pseudometa"
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

	if wu.winHasSize(win, wu.pseudoMax) or wu.winHasSize(win, wu.middleHalf) then
		moveToSide()
	elseif wu.winHasSize(win, hs.layout.maximized) then
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
	u.defer(0.1, function()
		local nonMonaWin = hs.fnutils.find(
			hs.window:orderedWindows(),
			function(win) return win:application() and win:application():name() ~= "Mona" end
		)
		if u.isFront("Mona") and nonMonaWin then nonMonaWin:focus() end
	end)
end):start()

--------------------------------------------------------------------------------
-- SPECIAL WINS

-- * auto-focus compose win when activating
-- * auto-close media wins when deactivating
M.aw_forSpecialMastoWins = aw.new(function(appName, event, masto)
	if appName ~= "Mona" then return end

	if event == aw.activated then
		masto:selectMenuItem { "Window", "Bring All to Front" }
		local composeWin = masto:findWindow("Compose")
		if composeWin then composeWin:focus() end
	elseif event == aw.deactivated then
		local mediaWin = masto:findWindow("Media") or masto:findWindow("Image")
		if mediaWin then
			mediaWin:close()
			hs.eventtap.keyStroke({ "cmd" }, "w", 1, masto) -- redundancy as closing not reliable
		end
	end
end):start()

--------------------------------------------------------------------------------
-- FIX Mona's autoscroll sometimes not fully scrolling up

local function homeAndScrollUp()
	-- GUARD only scrolling when not idle, to not prevent the machine form going to sleep.
	if hs.host.idleTime() > 120 or not u.screenIsUnlocked() then return end

	-- GUARD only if Mona is running in bg
	local mona = u.app("Mona")
	if not mona or mona:isFrontmost() then return end

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

if u.isSystemStart() then homeAndScrollUp() end

--------------------------------------------------------------------------------
return M
