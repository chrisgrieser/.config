local u = require("lua.utils")
local wu = require("lua.window-utils")
local env = require("lua.environment-vars")
--------------------------------------------------------------------------------

-- ensure that twitter does not get focus, "falling through" to the next window
local function twitterFallThrough()
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

local function twitterScrollUp()
	-- after quitting, it takes a few seconds until Twitter is fully quit,
	-- therefore also checking for the main window existence
	-- when browsing twitter itself, to not change tabs
	local twitter = u.app(env.tickerApp)
	if not twitter or not twitter:mainWindow() then return end

	u.keystroke({ "cmd" }, "left", 1, twitter) -- go back
	u.keystroke({ "cmd" }, "1", 1, twitter) -- go to home tab
	u.keystroke({ "shift", "cmd" }, "R", 1, twitter) -- reload

	-- needs delays to wait for tweets loading
	u.runWithDelays({ 0.5, 1.5 }, function()
		if twitter:isFrontmost() then return end
		u.keystroke({ "cmd" }, "1", 1, twitter) -- scroll up
		u.keystroke({ "cmd" }, "up", 1, twitter) -- goto top
	end)
end

---Checks clipboard for URL and cleans tracking stuff
local function twitterCleanupLink()
	local clipb = hs.pasteboard.getContents()
	if not clipb then return end
	local isTweet = clipb:find("^https?://twitter%.com")
	if not isTweet then return end -- to not overwrite the clipboard to often for clipboard watchers

	local cleanURL = clipb:gsub("%?s=.*t=.*", "")
	hs.pasteboard.setContents(cleanURL)
end

local function twitterCloseMediaWindow()
	local twitter = u.app(env.tickerApp)
	if not twitter then return end
	local mediaWin = twitter:findWindow("Media")
	if not mediaWin then return end

	-- HACK using keystroke, since closing the window does not
	-- seem to work reliably
	mediaWin:raise()
	u.keystroke({ "cmd" }, "w", 1, twitter)

	if mediaWin then mediaWin:close() end
end

local function twitterToTheSide()
	local twitter = u.app(env.tickerApp)
	if not twitter or u.isFront("Alfred") then return end

	if twitter:isHidden() then twitter:unhide() end

	-- not using mainWindow to not unintentionally move Media or new-tweet window
	-- Twitter's window is called "Twitter", Ivory's "Home"
	local win = twitter:findWindow(env.tickerApp) or twitter:findWindow("Home")
	if not win then return end

	win:setFrame(wu.toTheSide)
	win:raise()
end

---@param referenceWin hs.window
local function showHideTwitter(referenceWin)
	if u.isFront("CleanShot X") then return end

	local twitter = u.app(env.tickerApp)
	if not twitter or not referenceWin then return end
	if wu.CheckSize(referenceWin, wu.pseudoMax) or wu.CheckSize(referenceWin, wu.centered) then
		twitterToTheSide()
	elseif wu.CheckSize(referenceWin, wu.maximized) then
		twitter:hide()
	end
end

--------------------------------------------------------------------------------
-- TRIGGERS

-- once on system startup or reload
twitterScrollUp()

-- fixed size to the side, with the sidebar hidden
TwitterWatcher = u.aw
	.new(function(appName, event)
		if appName == "CleanShot X" or appName == "Alfred" then return end
		local twitter = u.app(env.tickerApp)

		-- move twitter and scroll up
		if appName == env.tickerApp and (event == u.aw.launched or event == u.aw.activated) then
			u.asSoonAsAppRuns(env.tickerApp, function()
				twitterToTheSide()
				twitterScrollUp()
				wu.bringAllWinsToFront()

				-- focus new tweet / media window if there is one
				if not twitter then return end
				local newTweetWindow = twitter:findWindow("Tweet")
				if newTweetWindow then newTweetWindow:focus() end
				local mediaWindow = twitter:findWindow("Media")
				if mediaWindow then mediaWindow:focus() end
			end)

		-- auto-close media windows and scroll up when deactivating
		elseif appName == env.tickerApp and event == u.aw.deactivated then
			if u.isFront("CleanShot X") then return end
			twitterScrollUp()
			twitterCleanupLink()
			twitterCloseMediaWindow()

		-- do not focus Twitter after an app is terminated
		elseif event == u.aw.terminated and appName ~= env.tickerApp then
			u.runWithDelays({ 0.1, 0.3 }, twitterFallThrough)

		-- raise twitter when switching window to other app
		elseif (event == u.aw.activated or event == u.aw.launched) and appName ~= env.tickerApp then
			showHideTwitter(hs.window.focusedWindow())
		end
	end)
	:start()

-- show/hide twitter when other wins move
Wf_SomeWindowActivity = u.wf
	.new(true)
	:setOverrideFilter({ allowRoles = "AXStandardWindow", hasTitlebar = true })
	:subscribe(u.wf.windowMoved, function(movedWin) showHideTwitter(movedWin) end)
	:subscribe(u.wf.windowCreated, function(createdWin) showHideTwitter(createdWin) end)

--------------------------------------------------------------------------------

-- toggle mute when Zoom is running, otherwise scroll up in Twitter
u.hotkey({}, "home", function()
	if u.app("zoom.us") then
		hs.alert.show("🔉/🔇")
		u.keystroke({ "cmd", "shift" }, "a")
	else
		twitterScrollUp()
	end
end)
