hyper = {"cmd", "alt", "ctrl", "shift"}
hotkey = hs.hotkey.bind
keystroke = hs.eventtap.keyStroke
aw = hs.application.watcher

function trim(str)
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function deviceName()
	local name = hs.execute('scutil --get ComputerName | cut -d" " -f2-')
	name = name:gsub("\n", "")
	return name
end

function isAtMother()
	if (deviceName():find("Leuthingerweg")) then
		return true
	else
		return false
	end
end

function isIMacAtHome()
	local iMacFirstScreen = hs.screen.primaryScreen():name() == "Built-in Retina Display"
	local iMacSecondScreen
	if #hs.screen.allScreens() > 1 then
		iMacSecondScreen = hs.screen.allScreens()[2]:name() == "Built-in Retina Display"
	else
		iMacSecondScreen = false
	end
	return (iMacFirstScreen or iMacSecondScreen) and not(isAtMother())
end


function isProjector()
	local projectorHelmholtz = hs.screen.primaryScreen():name() == "ViewSonic PJ"
	local tvLeuthinger = hs.screen.primaryScreen():name() == "sonic"
	return projectorHelmholtz or tvLeuthinger
end

function isAtOffice()
	local screenOne = hs.screen.primaryScreen():name() == "HP E223"
	local screenTwo = hs.screen.primaryScreen():name() == "Acer CB241HY"
	return (screenOne or screenTwo)
end

function notify (text)
	text = (trim(text))
	hs.notify.new({title="Hammerspoon", informativeText=text}):send()
	print("notify: "..text) -- for the console
end

function alert (text)
	hs.alert.show(text)
end

function log (text, location)
	text = (trim(text))
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



