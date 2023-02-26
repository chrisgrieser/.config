require("lua.utils")
--------------------------------------------------------------------------------

function TwitterScrollUp()
	if not (AppIsRunning("Twitter")) then return end
	Keystroke({ "command" }, "left", 1, App("Twitter")) -- go back
	Keystroke({ "command" }, "1", 1, App("Twitter")) -- go to home tab
	Keystroke({ "shift", "command" }, "R", 1, App("Twitter")) -- reload

	-- needs delays to wait for tweet loading
	RunWithDelays({ 0.2, 0.4, 0.6, 0.9, 1.2 }, function()
		Keystroke({ "command" }, "1", 1, App("Twitter")) -- scroll up
		Keystroke({ "command" }, "up", 1, App("Twitter")) -- goto top
	end)
end

function TwitterToTheSide()
	if not (AppIsRunning("Twitter")) then return end
	local win = App("Twitter"):findWindow("Twitter")
	if not win then return end
	win:raise()
	win:setFrame(ToTheSide)
end

-- TWITTER: fixed size to the side, with the sidebar hidden
TwitterWatcher = Aw.new(function(appName, eventType, appObj)
	-- move twitter and scroll it up
	if appName == "Twitter" and (eventType == Aw.launched or eventType == Aw.activated) then
		BringAllToFront()
		RunWithDelays({ 0.05, 0.2 }, function()
			TwitterToTheSide()
			if eventType == Aw.launched then TwitterScrollUp() end
		end)

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

	-- raise twitter when switching window to any app
	elseif appName and eventType == Aw.activated then
		local win = appObj:mainWindow()
		if CheckSize(win, PseudoMaximized) and AppIsRunning("Twitter") then App("Twitter"):mainWindow():raise() end
	end
end):start()

