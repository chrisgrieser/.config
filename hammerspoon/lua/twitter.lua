require("lua.utils")
--------------------------------------------------------------------------------

function TwitterScrollUp()
	-- after quitting, it takes a few seconds until Twitter is fully quit,
	-- therefore also checking for the main window existence
	local twitter = App("Twitter")
	if not twitter or not twitter:mainWindow() then return end

	Keystroke({ "cmd" }, "left", 1, twitter) -- go back
	Keystroke({ "cmd" }, "1", 1, twitter) -- go to home tab
	Keystroke({ "shift", "cmd" }, "R", 1, twitter) -- reload

	-- needs delays to wait for tweets loading
	RunWithDelays({ 0.5, 1.5 }, function()
		Keystroke({ "cmd" }, "1", 1, twitter) -- scroll up
		Keystroke({ "cmd" }, "up", 1, twitter) -- goto top
	end)
end

function TwitterToTheSide()
	if not AppIsRunning("Twitter") then return end

	-- not using mainWindow to not unintentionally move Media or new-tweet window
	local win = App("Twitter"):findWindow("Twitter") 
	if not win then return end

	win:setFrame(ToTheSide)
end

-- ensure that twitter does get focus, "falling through" to the next window
function TwitterFallThrough()
	if FrontAppName() == "Alfred" then return end -- needed for Alfred Compatibility Mode
	local visibleWins = hs.window:orderedWindows()
	local nextWin
	for _, win in pairs(visibleWins) do
		if win:application():name() ~= "Twitter" then
			nextWin = win
			break
		end
	end
	if nextWin and nextWin:id() ~= hs.window.frontmostWindow():id() then
		nextWin:focus()
	end
end

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

		local twitter = App("Twitter")
		for _, win in pairs(twitter:allWindows()) do
			if win:title():find("Media") then
				win:close()
				-- HACK using keystroke, since closing window does not seem to work reliably
				Keystroke({ "cmd" }, "w", 1, twitter)
			end
		end

	-- raise twitter when switching window to other app
	elseif event == Aw.activated and appName ~= "Twitter" then
		if not AppIsRunning("Twitter") then return end
		local win = App("Twitter"):mainWindow()
		if not win then return end

		if CheckSize(win, PseudoMaximized) or CheckSize(win, Centered) then
			win:raise()
			-- in case of active split, prevent left window of covering the sketchybar
			if LEFT_SPLIT then LEFT_SPLIT:application():hide() end
		end

	-- do not focus Twitter after an app is terminated
	elseif event == Aw.terminated and appName ~= "Twitter" then
		RunWithDelays(0.1, TwitterFallThrough)
	end
end):start()
