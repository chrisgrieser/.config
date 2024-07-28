local M = {} -- persist from garbage collector

local env = require("modules.environment-vars")
local u = require("modules.utils")
local wu = require("modules.window-utils")
local app = require("modules.utils").app

local aw = hs.application.watcher
local wf = hs.window.filter
local keystroke = hs.eventtap.keyStroke
local c = hs.caffeinate.watcher
--------------------------------------------------------------------------------

-- simply scroll up without the mouse and without focusing the app
-- necessary as auto-refreshing has subtle bugs in pretty much any app I tried
-- (not fully scrolling up, etc.)
local function scrollUp()
	local mona = app("Mona")
	if not mona or not u.screenIsUnlocked() or mona:isFrontmost() then return end

	keystroke({ "cmd" }, "left", 1, mona) -- go back
	keystroke({ "cmd" }, "1", 1, mona) -- go to home tab
	keystroke({ "cmd" }, "R", 1, mona) -- refresh/reload

	u.runWithDelays({ 1, 3, 7 }, function() -- wait for posts to load
		if not mona:isFrontmost() then -- do not interrupt when currently reading
			keystroke({ "cmd" }, "up", 1, mona) -- scroll up
		end
	end)
end

local function closeMediaWindow()
	local mona = app("Mona")
	if not mona then return end
	local mediaWin = mona:findWindow("Media") or mona:findWindow("Image")
	if not mediaWin then return end

	-- using keystroke, too, since closing the window does not work reliably
	keystroke({ "cmd" }, "w", 1, mona)
	mediaWin:close()
end

-- move the ticker-app window to the left side of the screen
local function winToTheSide()
	local masto = app("Mona")
	if not masto or u.isFront("Alfred") then return end

	if masto:isHidden() then masto:unhide() end

	-- not using mainWindow to not unintentionally move Media or new-tweet window
	local mastodonUsername = "pseudometa"
	local win = masto:findWindow("Mona") or masto:findWindow(mastodonUsername)
	if win then
		win:setFrame(wu.toTheSide)
		win:raise()
	end
end

-- SHOW if referenceWin is pseudo-maximized or centered
-- HIDE referenceWin belonging to app with transparent background is maximized
---@param referenceWin hs.window
local function showHideTickerApp(referenceWin)
	-- GUARD
	local masto = app("Mona")
	if not masto or not referenceWin then return end
	local loginWin = referenceWin:title() == "Login"
	local screenshotOverlay = referenceWin:title() == "" or u.isFront("CleanShot X")
	if loginWin or screenshotOverlay then return end

	if wu.checkSize(referenceWin, wu.pseudoMax) or wu.checkSize(referenceWin, wu.center) then
		winToTheSide()
	else
		local theApp = referenceWin:application()
		local appName = theApp and theApp:name() or ""
		local appWithTransBgWasMaximized = wu.checkSize(referenceWin, wu.maximized)
			and hs.fnutils.contains(env.transBgApps, appName)
		if appWithTransBgWasMaximized then masto:hide() end
	end
end

--------------------------------------------------------------------------------
-- TRIGGERS

-- Mona's autoscroll does not work reliably, therefore scrolling ourselves.
-- Only scrolling when not idle, to not prevent the machine form going to sleep.
local scrollEveryMins = 5 -- CONFIG
M.timer_regularScroll = hs.timer
	.doEvery(scrollEveryMins * 60, function()
		if hs.host.idleTime() < 120 then scrollUp() end
	end)
	:start()

M.aw_tickerWatcher = aw.new(function(appName, event, masto)
	if u.appRunning("Steam") then return end
	if appName == "CleanShot X" or appName == "Alfred" then return end

	-- move & scroll up
	if appName == "Mona" and (event == aw.launched or event == aw.activated) then
		u.whenAppWinAvailable("Mona", function()
			winToTheSide()
			scrollUp()
			wu.bringAllWinsToFront()

			local mediaWindow = masto:findWindow("Media") or masto:findWindow("Compose")
			if mediaWindow then mediaWindow:focus() end
		end)

	-- auto-close media windows and scroll up when deactivating
	elseif appName == "Mona" and event == aw.deactivated then
		closeMediaWindow()
		u.runWithDelays(1.5, scrollUp) -- deferred, so multiple links can be clicked

	-- raise when switching window to other app
	elseif (event == aw.activated or event == aw.launched) and appName ~= "Mona" then
		showHideTickerApp(hs.window.focusedWindow())
	end
end):start()

-- scrollup on wake
M.caff_TickerWake = c.new(function(event)
	if event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock then
		scrollUp()
	end
end):start()

-- show/hide app when any other wins move
M.wf_someWindowActivity = wf.new(true)
	:setOverrideFilter({ allowRoles = "AXStandardWindow", hasTitlebar = true })
	:subscribe(wf.windowMoved, function(movedWin) showHideTickerApp(movedWin) end)
	:subscribe(wf.windowCreated, function(createdWin) showHideTickerApp(createdWin) end)

--------------------------------------------------------------------------------
return M
