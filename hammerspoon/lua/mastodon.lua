local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local app = require("lua.utils").app
local mastodonApp = require("lua.environment-vars").mastodonApp

local aw = hs.application.watcher
local wf = hs.window.filter
local keystroke = hs.eventtap.keyStroke
local c = hs.caffeinate.watcher
--------------------------------------------------------------------------------

-- ensure scrolling up is not triggered when system is asleep, which prevents
-- the system from ever going to sleep
M.caff_TickerWake = c.new(function(event)
	if event == c.screensDidSleep then
		M.isSleeping = true
	elseif event == c.screensDidWake then
		M.isSleeping = false
	end
end):start()

-- simply scroll up without the mouse and without focusing the app
-- necessary as auto-refreshing has subtle bugs in pretty much any app I tried
-- (not fully scrolling up, etc.)
local function scrollUp()
	local masto = app(mastodonApp)
	if not masto or not u.screenIsUnlocked() or masto:isFrontmost() or M.isSleeping then return end

	keystroke({ "cmd" }, "left", 1, masto) -- go back
	keystroke({ "cmd" }, "1", 1, masto) -- go to home tab

	local modifiers = mastodonApp == "Mona" and { "cmd" } or { "cmd", "shift" }
	keystroke(modifiers, "R", 1, masto) -- refresh/reload

	u.runWithDelays({ 1, 5 }, function() -- wait for posts to load
		if not masto:isFrontmost() then -- do not interrupt when currently reading
			print("❗ beep 🔵")
			keystroke({ "cmd" }, "up", 1, masto) -- scroll up
		end
	end)
end

local function closeMediaWindow()
	local masto = app(mastodonApp)
	if not masto then return end
	local mediaWin = masto:findWindow("Media") or masto:findWindow("Image")
	if not mediaWin then return end

	-- using keystroke, too, since closing the window does not work reliably
	keystroke({ "cmd" }, "w", 1, masto)
	mediaWin:close()
end

-- move the ticker-app window to the left side of the screen
local function winToTheSide()
	local masto = app(mastodonApp)
	if not masto or u.isFront("Alfred") then return end

	if masto:isHidden() then masto:unhide() end

	-- not using mainWindow to not unintentionally move Media or new-tweet window
	-- Ivory's main window is called "Home", Mona's the username
	local win = masto:findWindow("Home") or masto:findWindow("pseudometa")
	if win then
		win:setFrame(wu.toTheSide)
		win:raise()
	end
end

-- SHOW if referenceWin is pseudo-maximized or centered
-- HIDE referenceWin belonging to app with transparent background is maximized
---@param referenceWin hs.window
local function showHideTickerApp(referenceWin)
	local masto = app(mastodonApp)
	if not masto or not referenceWin or u.isFront("CleanShot X") then return end

	if wu.checkSize(referenceWin, wu.pseudoMax) or wu.checkSize(referenceWin, wu.center) then
		winToTheSide()
		return
	end

	local appWithTransBgWasMaximized = wu.checkSize(referenceWin, wu.maximized)
		and hs.fnutils.contains(env.transBgApps, referenceWin:title())

	if appWithTransBgWasMaximized then
		local loginWin = referenceWin:title() == "Login"
		local screenshotOverlay = referenceWin:title() == ""
		if loginWin or screenshotOverlay then return end
		masto:hide()
	end
end

--------------------------------------------------------------------------------
-- TRIGGERS

-- scroll
hs.hotkey.bind({}, "home", scrollUp)

-- Mona's autoscroll does not work reliably, therefore scrolling ourselves.
-- Only scrolling when not idle, to not prevent the machine going to sleep.
if mastodonApp == "Mona" then
	local scrollEveryMins = 5 -- CONFIG
	M.timer_regularScroll = hs.timer
		.doEvery(scrollEveryMins * 60, function()
			if hs.host.idleTime() < 120 then scrollUp() end
		end)
		:start()
end

M.aw_tickerWatcher = aw.new(function(appName, event, masto)
	if appName == "CleanShot X" or appName == "Alfred" then return end

	-- move scroll up
	if appName == mastodonApp and (event == aw.launched or event == aw.activated) then
		u.whenAppWinAvailable(mastodonApp, function()
			winToTheSide()
			scrollUp()
			wu.bringAllWinsToFront()

			-- focus media window if there is one
			local mediaWindow = masto:findWindow("Media") or masto:findWindow(mastodonApp)
			if mediaWindow then mediaWindow:focus() end
		end)

		-- auto-close media windows and scroll up when deactivating
	elseif appName == mastodonApp and event == aw.deactivated then
		closeMediaWindow()
		u.runWithDelays(1.5, scrollUp) -- deferred, so multiple links can be clicked

		-- raise when switching window to other app
	elseif (event == aw.activated or event == aw.launched) and appName ~= mastodonApp then
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
