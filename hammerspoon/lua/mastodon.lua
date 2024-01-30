local M = {} -- persist from garbage collector

local mastodonApp = require("lua.environment-vars").mastodonApp
local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
local keystroke = hs.eventtap.keyStroke
--------------------------------------------------------------------------------

-- simply scroll up without the mouse and without focusing the app
-- necessary as auto-refreshing has subtle bugs in pretty much any app I tried
-- (not correctly scrolling up, etc.)
local function scrollUp()
	local app = u.app(mastodonApp)
	if not app or not u.screenIsUnlocked() or app:isFrontmost() then return end

	keystroke({ "cmd" }, "left", 1, app) -- go back
	keystroke({ "cmd" }, "1", 1, app) -- go to home tab

	local modifiers = mastodonApp == "Mona" and { "cmd" } or { "cmd", "shift" }
	keystroke(modifiers, "R", 1, app) -- refresh/reload

	u.runWithDelays({ 1, 5 }, function() -- wait for posts to load
		if app:isFrontmost() then return end -- do not interrupt when currently reading
		keystroke({ "cmd" }, "up", 1, app) -- scroll up
	end)
end

local function closeMediaWindow()
	local app = u.app(mastodonApp)
	if not app then return end
	local mediaWin = app:findWindow("Media") or app:findWindow("Image")
	if not mediaWin then return end

	-- HACK using keystroke, too, since closing the window does not work reliably
	mediaWin:raise()
	keystroke({ "cmd" }, "w", 1, app)
	if mediaWin then mediaWin:close() end
end

-- move the ticker-app window to the left side of the screen
local function winToTheSide()
	local app = u.app(mastodonApp)
	if not app or u.isFront("Alfred") then return end

	if app:isHidden() then app:unhide() end

	-- not using mainWindow to not unintentionally move Media or new-tweet window
	-- Ivory's main window is called "Home", Mona's the username
	local win = app:findWindow("Home") or app:findWindow("pseudometa")
	if win then
		win:setFrame(wu.toTheSide)
		win:raise()
	end
end

-- SHOW if referenceWin is pseudo-maximized or centered
-- HIDE referenceWin belonging to app with transparent background is maximized
---@param referenceWin hs.window
local function showHideTickerApp(referenceWin)
	local app = u.app(mastodonApp)
	if not app or not referenceWin or u.isFront("CleanShot X") then return end

	if wu.checkSize(referenceWin, wu.pseudoMax) or wu.checkSize(referenceWin, wu.centerHalf) then
		winToTheSide()
		return
	end

	local appWithTransBgWasMaximized = wu.checkSize(referenceWin, wu.maximized)
		and u.tbl_contains(env.transBgApps, referenceWin:title())

	if appWithTransBgWasMaximized then
		local loginWin = referenceWin:title() == "Login"
		local screenshotOverlay = referenceWin:title() == ""
		if loginWin or screenshotOverlay then return end
		app:hide()
	end
end

--------------------------------------------------------------------------------
-- TRIGGERS

-- scroll
hs.hotkey.bind({}, "home", scrollUp)

if mastodonApp == "Mona" then M.timer_regularScroll = hs.timer.doEvery(5 * 60, scrollUp):start() end

M.aw_tickerWatcher = aw.new(function(appName, event, app)
	if appName == "CleanShot X" or appName == "Alfred" then return end

	-- move scroll up
	if appName == mastodonApp and (event == aw.launched or event == aw.activated) then
		u.whenAppWinAvailable(mastodonApp, function()
			winToTheSide()
			scrollUp()
			wu.bringAllWinsToFront()

			-- focus media window if there is one
			local mediaWindow = app:findWindow("Media") or app:findWindow(mastodonApp)
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
local c = hs.caffeinate.watcher
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
