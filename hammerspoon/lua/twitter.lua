local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")

--------------------------------------------------------------------------------

-- ensure that twitter does not get focus, "falling through" to the next window
local function fallThrough()
	if not u.isFront(env.tickerApp) then return end

	local visibleWins = hs.window:orderedWindows()
	local nextWin
	for _, win in pairs(visibleWins) do
		if win:application():name() ~= env.tickerApp then
			nextWin = win
			break
		end
	end
	if not nextWin or nextWin:id() == hs.window.frontmostWindow():id() then return end

	nextWin:focus()
end

local function scrollUp()
	-- after quitting, it takes a few seconds until Twitter is fully quit,
	-- therefore also checking for the main window existence
	-- when browsing twitter itself, to not change tabs
	local app = u.app(env.tickerApp)
	if not app or not app:mainWindow() then return end

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

---Checks clipboard for URL and cleans tracking stuff
local function cleanUpLink()
	if env.tickerApp ~= "Twitter" then return end
	local clipb = hs.pasteboard.getContents()
	if not clipb then return end
	local isTweet = clipb:find("^https?://twitter%.com")
	if not isTweet then return end -- to not overwrite the clipboard to often for clipboard watchers

	local cleanURL = clipb:gsub("%?s=.*t=.*", "")
	hs.pasteboard.setContents(cleanURL)
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

local function winToTheSide()
	local app = u.app(env.tickerApp)
	if not app or u.isFront("Alfred") then return end

	if app:isHidden() then app:unhide() end

	-- not using mainWindow to not unintentionally move Media or new-tweet window
	-- Twitter's window is called "Twitter", Ivory's "Home"
	local win = app:findWindow(env.tickerApp) or app:findWindow("Home")
	if not win then return end

	win:setFrame(wu.toTheSide)
	win:raise()
end

---@param referenceWin hs.window
local function showHideTickerApp(referenceWin)
	if u.isFront("CleanShot X") then return end

	local app = u.app(env.tickerApp)
	if not app or not referenceWin then return end
	if wu.CheckSize(referenceWin, wu.pseudoMax) or wu.CheckSize(referenceWin, wu.centered) then
		winToTheSide()
	elseif wu.CheckSize(referenceWin, wu.maximized) then
		app:hide()
	end
end

--------------------------------------------------------------------------------
-- TRIGGERS

-- once on system startup or reload
scrollUp()

-- fixed size to the side, with the sidebar hidden
TickerAppWatcher = u.aw
	.new(function(appName, event)
		if appName == "CleanShot X" or appName == "Alfred" then return end
		local app = u.app(env.tickerApp)

		-- move twitter and scroll up
		if appName == env.tickerApp and (event == u.aw.launched or event == u.aw.activated) then
			u.asSoonAsAppRuns(env.tickerApp, function()
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
		elseif appName == env.tickerApp and event == u.aw.deactivated then
			if u.isFront("CleanShot X") then return end
			scrollUp()
			cleanUpLink()
			closeMediaWindow()

		-- do not focus Twitter after an app is terminated
		elseif event == u.aw.terminated and appName ~= env.tickerApp then
			u.runWithDelays({ 0.1, 0.3 }, fallThrough)

		-- raise twitter when switching window to other app
		elseif (event == u.aw.activated or event == u.aw.launched) and appName ~= env.tickerApp then
			showHideTickerApp(hs.window.focusedWindow())
		end
	end)
	:start()

-- show/hide twitter when other wins move
Wf_SomeWindowActivity = u.wf
	.new(true)
	:setOverrideFilter({ allowRoles = "AXStandardWindow", hasTitlebar = true })
	:subscribe(u.wf.windowMoved, function(movedWin) showHideTickerApp(movedWin) end)
	:subscribe(u.wf.windowCreated, function(createdWin) showHideTickerApp(createdWin) end)

--------------------------------------------------------------------------------

-- toggle mute when Zoom is running, otherwise scroll up
u.hotkey({}, "home", function()
	if u.app("zoom.us") then
		hs.alert.show("🔉/🔇")
		u.keystroke({ "cmd", "shift" }, "a")
	else
		scrollUp()
	end
end)

--------------------------------------------------------------------------------
-- FIX pin to top not working yet in Ivory https://tapbots.social/@ivory/110651107834916828
if env.tickerApp == "Ivory" then
	local reloadSecs = 30
	hs.timer.doEvery(reloadSecs, scrollUp):start()
end
