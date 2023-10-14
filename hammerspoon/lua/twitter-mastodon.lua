local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter

local g = {} -- persist from garbage collector
--------------------------------------------------------------------------------

-- simply scroll up without the mouse and without focusing the app
local function scrollUp()
	-- after quitting, it takes a few seconds until Twitter is fully quit,
	-- therefore also checking for the main window existence
	-- when browsing twitter itself, to not change tabs
	local app = u.app(env.tickerApp)
	if not (app and app:mainWindow() and u.screenIsUnlocked()) then return end
	if app:isFrontmost() then return end

	u.keystroke({ "cmd" }, "left", 1, app) -- go back
	u.keystroke({ "cmd" }, "1", 1, app) -- go to home tab
	u.keystroke({ "shift", "cmd" }, "R", 1, app) -- reload

	-- needs delays to wait for tweets loading
	u.runWithDelays({ 0.5, 1.5 }, function()
		if app:isFrontmost() then return end
		u.keystroke({ "cmd" }, "1", 1, app) -- scroll up
		u.keystroke({ "cmd" }, "up", 1, app) -- goto top
	end)
end

local function closeMediaWindow()
	local app = u.app(env.tickerApp)
	if not app then return end
	local mediaWin = app:findWindow("Media") or app:findWindow("Ivory")
	if not mediaWin then return end

	-- HACK using keystroke, since closing the window does not
	-- seem to work reliably
	mediaWin:raise()
	u.keystroke({ "cmd" }, "w", 1, app)

	if mediaWin then mediaWin:close() end
end

-- move the ticker-app window to the left side of the screen
local function winToTheSide()
	local app = u.app(env.tickerApp)
	if not app or u.isFront("Alfred") then return end

	if app:isHidden() then app:unhide() end

	-- not using mainWindow to not unintentionally move Media or new-tweet window
	-- Twitter's window is called "Twitter", Ivory's "Home"
	local win = env.tickerApp == "Twitter" and app:findWindow("Twitter") or app:findWindow("Home")
	if not win then return end

	win:setFrame(wu.toTheSide)
	win:raise()
end

-- SHOW if referenceWin is pseudo-maximized or centered
-- HIDE referenceWin belongs to app with transparent background is maximized
---@param referenceWin hs.window
local function showHideTickerApp(referenceWin)
	local app = u.app(env.tickerApp)
	if not app or not referenceWin or u.isFront("CleanShot X") then return end

	if wu.CheckSize(referenceWin, wu.pseudoMax) or wu.CheckSize(referenceWin, wu.centerHalf) then
		winToTheSide()
		return
	end

	local transBgApps = { "neovide", "Neovide", "Obsidian", "wezterm-gui", "WezTerm" }
	local appWithTransBgWasMaximized = wu.CheckSize(referenceWin, wu.maximized)
		and u.tbl_contains(transBgApps, referenceWin:title())

	if appWithTransBgWasMaximized then
		local loginWin = referenceWin:title() == "Login"
		local screenshotOverlay = referenceWin:title() == ""
		if loginWin or screenshotOverlay then return end
		app:hide()
	end
end

--------------------------------------------------------------------------------
-- TRIGGERS

-- toggle mute when Zoom is running, otherwise scroll up
u.hotkey({}, "home", scrollUp)

g.aw_tickerWatcher = aw.new(function(appName, event)
	if appName == "CleanShot X" or appName == "Alfred" then return end
	local app = u.app(env.tickerApp)

	-- move twitter and scroll up
	if appName == env.tickerApp and (event == aw.launched or event == aw.activated) then
		u.whenAppWinAvailable(env.tickerApp, function()
			winToTheSide()
			scrollUp()
			wu.bringAllWinsToFront()

			-- focus new tweet / media window if there is one
			if not app then return end
			local newTweetWindow = app:findWindow("Tweet")
			if newTweetWindow then newTweetWindow:focus() end
			local mediaWindow = app:findWindow("Media") or app:findWindow("Ivory")
			if mediaWindow then mediaWindow:focus() end
		end)

		-- auto-close media windows and scroll up when deactivating
	elseif appName == env.tickerApp and event == aw.deactivated then
		if u.isFront("CleanShot X") then return end
		closeMediaWindow()
		u.runWithDelays(1.5, scrollUp) -- deferred, so multiple links can be clicked

		-- raise twitter when switching window to other app
	elseif (event == aw.activated or event == aw.launched) and appName ~= env.tickerApp then
		showHideTickerApp(hs.window.focusedWindow())
	end
end):start()

-- scrollup on wake
local c = hs.caffeinate.watcher
g.caff_TickerWak = c.new(function(event)
	if event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock then
		scrollUp()
	end
end):start()

-- show/hide twitter when other wins move
g.wf_someWindowActivity = wf.new(true)
	:setOverrideFilter({ allowRoles = "AXStandardWindow", hasTitlebar = true })
	:subscribe(wf.windowMoved, function(movedWin) showHideTickerApp(movedWin) end)
	:subscribe(wf.windowCreated, function(createdWin) showHideTickerApp(createdWin) end)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- FIX pin to top not working yet in Ivory https://tapbots.social/@ivory/110651107834916828
if env.tickerApp ~= "Ivory" then return end

local reloadMins = 3
g.timer_ivoryReload = hs.timer
	.doEvery(reloadMins * 60, function()
		local ivory = u.app(env.tickerApp)
		if not ivory then return end

		-- only reload when not idle, so this does not prevent screensaver/sleep
		-- also do not reload when app is frontmost, since that may interrupt reading
		local idle = hs.host.idleTime() > (reloadMins * 60 / 2)
		if idle or ivory:isFrontmost() then return end

		scrollUp()
	end)
	:start()

--------------------------------------------------------------------------------
return nil, g
