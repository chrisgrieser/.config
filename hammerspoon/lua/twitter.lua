require("lua.utils")
--------------------------------------------------------------------------------

function TwitterScrollUp()
	-- after quitting, it takes a few seconds until Twitter is fully quit,
	-- therefore also checking for the main window existence
	-- when browsing twitter itself, to not change tabs
	local twitter = App("Twitter")
	if not twitter or not twitter:mainWindow() or FrontAppName() == "Twitter" then return end

	Keystroke({ "cmd" }, "left", 1, twitter) -- go back
	Keystroke({ "cmd" }, "1", 1, twitter) -- go to home tab
	Keystroke({ "shift", "cmd" }, "R", 1, twitter) -- reload

	-- needs delays to wait for tweets loading
	RunWithDelays({ 0.5, 1.5 }, function()
		if FrontAppName() == "Twitter" then return end
		Keystroke({ "cmd" }, "1", 1, twitter) -- scroll up
		Keystroke({ "cmd" }, "up", 1, twitter) -- goto top
	end)
end

function TwitterToTheSide()
	-- in case of active split, prevent left window of covering the sketchybar
	if LEFT_SPLIT then LEFT_SPLIT:application():hide() end

	local twitter = App("Twitter")
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
	Notify("beep")
	if FrontAppName() ~= "Twitter" then return end

	local visibleWins = hs.window:orderedWindows()
	local nextWin
	for _, win in pairs(visibleWins) do
		if win:application():name() ~= "Twitter" then
			nextWin = win
			break
		end
	end
	Notify("nextWin:", nextWin:title())
	if nextWin and nextWin:id() ~= hs.window.frontmostWindow():id() then nextWin:focus() end
end

---Checks clipboard for URL and cleans tracking stuff
local function twitterCleanupLink()
	local clipb = hs.pasteboard.getContents()
	if not clipb then return end
	local isTweet = clipb:find("^https?://twitter%.com")
	if not isTweet then return end -- to not overwrite the clipboard to often for clipboard watchers

	-- https://twitter.com/niklashoehne/status/1634896659992965122?s=61&t=UsI8J7q5JQmZp8X73Kr_Tw
	local cleanURL = clipb:gsub("%?s=.*t=.*", "")
	hs.pasteboard.setContents(cleanURL)
end

local function twitterCloseMediaWindow()
	local twitter = App("Twitter")
	local mediaWin = twitter:findWindow("Media")
	if not mediaWin then return end
	mediaWin:close()

	-- HACK using keystroke, since closing the window does not
	-- seem to work reliably
	if mediaWin then
		mediaWin:raise()
		Keystroke({ "cmd" }, "w", 1, twitter)
	end
end
--------------------------------------------------------------------------------

-- TWITTER: fixed size to the side, with the sidebar hidden
TwitterWatcher = Aw.new(function(appName, event)
	-- move twitter and scroll it up
	if appName == "Twitter" and (event == Aw.launched or event == Aw.activated) then
		AsSoonAsAppRuns("Twitter", function()
			BringAllToFront()
			TwitterToTheSide()
			TwitterScrollUp()
		end)

	-- auto-close media windows and scroll up when deactivating
	elseif appName == "Twitter" and event == Aw.deactivated then
		TwitterScrollUp()
		twitterCleanupLink()
		twitterCloseMediaWindow()

	-- do not focus Twitter after an app is terminated
	elseif event == Aw.terminated and appName ~= "Twitter" then
		RunWithDelays(0.2, function ()
			Notify("beep")
			twitterFallThrough()	
		end)

	-- raise twitter when switching window to other app
	elseif event == Aw.activated and appName ~= "Twitter" then
		local frontWin = hs.window.focusedWindow()
		local twitter = App("Twitter")
		if not frontWin or not twitter then return end

		if CheckSize(frontWin, PseudoMaximized) or CheckSize(frontWin, Centered) then
			TwitterToTheSide()
		elseif CheckSize(frontWin, Maximized) then
			twitter:hide()
		end
	end
end):start()
