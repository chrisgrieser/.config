require("lua.utils")
--------------------------------------------------------------------------------

function TwitterScrollUp()
	-- after quitting, it takes a few seconds until Twitter is fully quit,
	-- therefore also checking for the main window existence
	-- when browsing twitter itself, to not change tabs
	local twitter = u.app("Twitter")
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

function TwitterToTheSide()
	-- in case of active split, prevent left window of covering the sketchybar
	if LEFT_SPLIT and LEFT_SPLIT:application() then LEFT_SPLIT:application():hide() end

	if u.isFront("Alfred") then return end

	local twitter = u.app("Twitter")
	if not twitter then return end

	if twitter:isHidden() then twitter:unhide() end

	-- not using mainWindow to not unintentionally move Media or new-tweet window
	local win = twitter:findWindow("Twitter")
	if not win then return end

	win:raise()
	win:setFrame(ToTheSide)
end

-- ensure that twitter does not get focus, "falling through" to the next window
local function twitterFallThrough()
	if not u.isFront("Twitter") then return end

	local visibleWins = hs.window:orderedWindows()
	local nextWin
	for _, win in pairs(visibleWins) do
		if win:application():name() ~= "Twitter" then
			nextWin = win
			break
		end
	end
	if not nextWin or nextWin:id() == hs.window.frontmostWindow():id() then return end

	nextWin:focus()
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
	local twitter = u.app("Twitter")
	if not twitter then return end
	local mediaWin = twitter:findWindow("Media")
	if not mediaWin then return end

	-- HACK using keystroke, since closing the window does not
	-- seem to work reliably
	mediaWin:raise()
	u.keystroke({ "cmd" }, "w", 1, twitter)

	if mediaWin then mediaWin:close() end
end
--------------------------------------------------------------------------------

-- TWITTER: fixed size to the side, with the sidebar hidden
TwitterWatcher = u.aw.new(function(appName, event)
	if appName == "CleanShot X" or appName == "Alfred" then return end
	local twitter = u.app("Twitter")

	-- move twitter and scroll it up
	if appName == "Twitter" and (event == u.aw.launched or event == u.aw.activated) then
		u.asSoonAsAppRuns("Twitter", function()
			TwitterToTheSide()
			TwitterScrollUp()
			BringAllWinsToFront()

			-- focus new tweet window if there is one
			local newTweetWindow = twitter:findWindow("Tweet")
			if newTweetWindow then newTweetWindow:focus() end
		end)

	-- auto-close media windows and scroll up when deactivating
	elseif appName == "Twitter" and event == u.aw.deactivated then
		if u.isFront("CleanShot X") then return end
		TwitterScrollUp()
		twitterCleanupLink()
		twitterCloseMediaWindow()

	-- do not focus Twitter after an app is terminated
	elseif event == u.aw.terminated and appName ~= "Twitter" then
		u.runWithDelays({ 0.1, 0.3 }, twitterFallThrough)

	-- raise twitter when switching window to other app
	elseif event == u.aw.activated and appName ~= "Twitter" then
		local frontWin = hs.window.focusedWindow()
		if not frontWin or not twitter then return end

		if CheckSize(frontWin, PseudoMaximized) or CheckSize(frontWin, Centered) then
			TwitterToTheSide()
		elseif CheckSize(frontWin, Maximized) then
			twitter:hide()
		end
	end
end):start()
