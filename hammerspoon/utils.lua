hyper = {"cmd", "alt", "ctrl", "shift"}
hotkey = hs.hotkey.bind
alert = hs.alert.show
keystroke = hs.eventtap.keyStroke
aw = hs.application.watcher
wf = hs.window.filter
runDelayed = hs.timer.doAfter

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
	if deviceName():find("iMac") and not(deviceName():find("Leuthingerweg")) then
		return true
	else
		return false
	end
end


function isProjector()
	local projectorHelmholtz = hs.screen.primaryScreen():name() == "ViewSonic PJ"
	local tvLeuthinger = hs.screen.primaryScreen():name() == "TV_MONITOR"
	return projectorHelmholtz or tvLeuthinger
end

function isAtOffice()
	local screenOne = hs.screen.primaryScreen():name() == "HP E223"
	local screenTwo = hs.screen.primaryScreen():name() == "Acer CB241HY"
	return (screenOne or screenTwo)
end

function notify (text)
	text = trim(text)
	hs.notify.new({title="Hammerspoon", informativeText=text}):send()
	print("notify: "..text) -- for the console
end

function log (text, logpath)
	text = trim(text)
	hs.execute('mkdir -p "$(dirname "'..logpath..'")"')
	hs.execute('echo "$(date "+%Y-%m-%d %H:%M")" "'..text..'" >> "'..logpath..'"')
	print ("log: "..text) -- for the console
end

function frontapp ()
	return hs.application.frontmostApplication():name()
end

function appIsRunning (appName)
	-- can't use ":isRunning()", since the application object is nil when it
	-- wasn't running before
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
