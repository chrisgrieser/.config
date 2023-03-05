require("lua.utils")
--------------------------------------------------------------------------------

function TwitterScrollUp()
	-- after quitting, it takes a few seconds until Twitter is fully quit,
	-- therefore also checking for the main window existence
	local twitter = App("Twitter")
	if not (twitter and twitter:mainWindow()) then return end

	Keystroke({ "command" }, "left", 1, twitter) -- go back
	Keystroke({ "command" }, "1", 1, twitter) -- go to home tab
	Keystroke({ "shift", "command" }, "R", 1, twitter) -- reload

	-- needs delays to wait for tweet loading
	RunWithDelays({ 0.5, 1.5 }, function()
		Keystroke({ "command" }, "1", 1, twitter) -- scroll up
		Keystroke({ "command" }, "up", 1, twitter) -- goto top
	end)
end

function TwitterToTheSide()
	if not (AppIsRunning("Twitter") and App("Twitter"):mainWindow()) then return end
	local win = App("Twitter"):mainWindow()
	if not win then return end
	win:setFrame(ToTheSide)
	win:raise()
end

-- TWITTER: fixed size to the side, with the sidebar hidden
TwitterWatcher = Aw.new(function(appName, eventType, appObj)
	if not (AppIsRunning("Twitter") and App("Twitter"):mainWindow()) then return end

	-- move twitter and scroll it up
	if appName == "Twitter" and eventType == Aw.launched then
		RunWithDelays({ 0.5, 1, 2 }, function()
			BringAllToFront()
			TwitterToTheSide()
			TwitterScrollUp()
		end)
	elseif appName == "Twitter" and eventType == Aw.activated then
		BringAllToFront()
		TwitterScrollUp()

	-- auto-close media windows and scroll up when deactivating
	elseif appName == "Twitter" and eventType == Aw.deactivated then
		TwitterScrollUp()

		for _, win in pairs(appObj:allWindows()) do
			if win:title():find("Media") then
				win:close()
				-- HACK using keystroke, since closing window does not seem to work reliably
				Keystroke({ "command" }, "w", 1, App("Twitter")) -- close media window
			end
		end

	-- raise twitter when switching window to other app
	elseif appName and eventType == Aw.activated then
		local win = appObj:mainWindow()
		if CheckSize(win, PseudoMaximized) or CheckSize(win, Centered) then
			App("Twitter"):mainWindow():raise()
			-- in case of active split, prevent left window of covering the sketchybar
			if LEFT_SPLIT then LEFT_SPLIT:application():hide() end
		end
	end
end):start()
