require("lua.utils")
--------------------------------------------------------------------------------

function twitterScrollUp()
	if not (appIsRunning("Twitter")) then return end
	keystroke({ "shift", "command" }, "R", 1, app("Twitter")) -- reload
	-- needs delay to wait for tweet loading
	runWithDelays({ 0.2, 0.4, 0.6, 0.9, 1.2 }, function()
		keystroke({ "command" }, "1", 1, app("Twitter")) -- scroll up
		keystroke({ "command" }, "up", 1, app("Twitter")) -- goto top
	end)
end

function twitterToTheSide()
	if not (appIsRunning("Twitter")) then return end
	local win = app("Twitter"):findWindow("Twitter")
	if not win then return end
	win:raise()
	win:setFrame(toTheSide)
	keystroke({ "command" }, "1", 1, app("Twitter")) -- home tab
end

-- TWITTER: fixed size to the side, with the sidebar hidden
twitterWatcher = aw.new(function(appName, eventType, appObj)
	-- move twitter and scroll it up
	if appName == "Twitter" and (eventType == aw.launched or eventType == aw.activated) then
		runWithDelays({ 0.05, 0.2 }, function()
			twitterToTheSide()
			if eventType == aw.launched then twitterScrollUp() end
		end)

	-- auto-close media windows
	elseif appName == "Twitter" and eventType == aw.deactivated then
		keystroke({ "command" }, "left", 1, app("Twitter")) -- go back
		keystroke({ "command" }, "1", 1, app("Twitter")) -- home tab

		for _, win in pairs(appObj:allWindows()) do
			if win:title():find("Media") then
				win:close()
				-- HACK using keystroke, since closing window does not seem to work reliably
				keystroke({ "command" }, "w", 1, app("Twitter")) -- close media window
			end
		end

	-- raise twitter
	elseif eventType == aw.activated then
		local win = appObj:mainWindow()
		if checkSize(win, pseudoMaximized) and appIsRunning("Twitter") then app("Twitter"):mainWindow():raise() end
	end
end):start()

