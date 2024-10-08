local M = {} -- persist from garbage collector

local u = require("meta.utils")
local wu = require("win-management.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------

-- SHOW & MOVE TO SIDE if window is pseudo-maximized or centered
-- HIDE if maximized
---@param win? hs.window
local function showAndMoveOrHideTickerApp(win)
	-- GUARD
	local masto = u.app("Mona")
	if not masto then return end

	if win == nil or wu.winHasSize(win, wu.pseudoMax) or wu.winHasSize(win, wu.middleHalf) then
		local mastodonUsername = "pseudometa"
		local mastoWin = masto:findWindow("Mona") or masto:findWindow(mastodonUsername)
		if not mastoWin then return end
		masto:unhide()
		mastoWin:setFrame(wu.toTheSide)
		mastoWin:raise()
	elseif wu.winHasSize(win, hs.layout.maximized) then
		masto:hide()
	end
end

M.wf_someWindowActivity = wf
	.new(true) -- `true` -> all windows
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowMoved, showAndMoveOrHideTickerApp)
	:subscribe(wf.windowFocused, showAndMoveOrHideTickerApp)
	:subscribe(wf.windowCreated, function(newWin)
		-- FIX WezTerm resizes during opening
		if newWin:application() and newWin:application():name() == "WezTerm" then return end 
		showAndMoveOrHideTickerApp(newWin)
	end)

if u.isSystemStart() then showAndMoveOrHideTickerApp() end

M.aw_monaLaunched = aw.new(function(appName, event)
	if appName == "Mona" and event == aw.launched then u.defer(1, showAndMoveOrHideTickerApp) end
end):start()

--------------------------------------------------------------------------------
-- SPECIAL WINS

-- - auto-focus when composeWin when activating
-- - auto-close when deactivating
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

M.aw_monaDeavtivated = aw.new(function(appName, event)
	if appName == "Mona" and event == aw.deactivated then homeAndScrollUp() end
end):start()

--------------------------------------------------------------------------------
return M
