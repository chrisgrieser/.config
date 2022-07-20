hyper = {"cmd", "alt", "ctrl", "shift"}
hotkey = hs.hotkey.bind
keystroke = hs.eventtap.keyStroke

function trim(str)
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function deviceName()
	local name = hs.execute('scutil --get ComputerName | cut -d" " -f2-')
	name = name:gsub("\n", "")
	return name
end

function isIMacAtHome ()
	local iMacFirstScreen = hs.screen.primaryScreen():name() == "Built-in Retina Display"
	local iMacSecondScreen
	if numberOfScreens() > 1 then
		iMacSecondScreen = hs.screen.allScreens()[2]:name() == "Built-in Retina Display"
	else
		iMacSecondScreen = false
	end
	return iMacFirstScreen or iMacSecondScreen
end

function isProjector()
	return hs.screen.primaryScreen():name() == "ViewSonic PJ"
end

function isAtOffice()
	local screenOne = hs.screen.primaryScreen():name() == "HP E223"
	local screenTwo = hs.screen.primaryScreen():name() == "Acer CB241HY"
	return (screenOne or screenTwo)
end

function isDarkMode()
	local _, isDark = hs.osascript.applescript('tell application "System Events" to return dark mode of appearance preferences')
	return isDark
end

function setDarkmode (toDark)
	local darkStr
	if toDark then darkStr = "true"
	else darkStr = "false" end
	hs.osascript.applescript([[
		tell application "System Events"
			tell appearance preferences
				if (dark mode is not ]]..darkStr..[[) then tell application id "com.runningwithcrayons.Alfred" to run trigger "toggle-dark-mode" in workflow "de.chris-grieser.dark-mode-toggle"
			end tell
		end tell
	]])
	log("🌒 Dark Mode: "..darkStr.." ("..deviceName()..")", "$HOME/dotfiles/Cron Jobs/some.log")
end

function notify (text)
	text = (trim(text)):gsub("\n", " –– ")
	hs.notify.new({title="Hammerspoon", informativeText=text}):send()
	print("notify: "..text) -- for the console
end

function alert (text)
	hs.alert.show(text)
end

function log (text, location)
	text = (trim(text)):gsub("\n", " –– ")
	hs.execute('echo "$(date "+%Y-%m-%d %H:%M")" "'..text..'" >> "'..location..'"')
	print ("log: "..text) -- for the console
end

function frontapp ()
	return hs.application.frontmostApplication():name()
end

function appIsRunning (appName)
	-- can't use ":isRunning()", since the application object is nil when it
	-- wasn't wasn't running before
	local runs = hs.application.get(appName)
	if runs then return true
	else return false	end
end

function openIfNotRunning (appName)
	local runs = hs.application.get(appName)
	if runs then
		return
	else
		hs.application.open(appName)
	end
end

function killIfRunning (appName)
	local runs = hs.application.get(appName)
	if runs then runs:kill() end
	hs.timer.doAfter(1, function ()
		runs = hs.application.get(appName)
		if runs then runs:kill9() end
	end)
end

function runDelayed (delaySecs, fn)
	hs.timer.doAfter(delaySecs, function () fn() end)
end



