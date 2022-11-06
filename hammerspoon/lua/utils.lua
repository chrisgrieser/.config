require("lua.lua-utils") -- does not work with symlink, therefore hardlink
--------------------------------------------------------------------------------

hyper = {"cmd", "alt", "ctrl", "shift"}
hotkey = hs.hotkey.bind
alert = hs.alert.show
keystroke = hs.eventtap.keyStroke
aw = hs.application.watcher
wf = hs.window.filter
runDelayed = hs.timer.doAfter
app = hs.application
I = hs.inspect -- to inspect tables in the console

--------------------------------------------------------------------------------

local mainDisplayName = hs.screen.primaryScreen():name()

function isProjector()
	local projectorHelmholtz = mainDisplayName == "ViewSonic PJ"
	local tvLeuthinger = mainDisplayName == "TV_MONITOR"
	return projectorHelmholtz or tvLeuthinger
end

function isAtOffice()
	local screenOne = mainDisplayName == "HP E223"
	local screenTwo = mainDisplayName == "Acer CB241HY"
	return screenOne or screenTwo
end

function screenIsUnlocked()
	local _, success = hs.execute('[[ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]] && exit 0 || exit 1')
	return success
end

function deviceName()
	-- similar to `scutil --get ComputerName`, only native to hammerspoon and therefore a bit more reliable
	local name, _ = hs.host.localizedName():gsub(".- ", "", 1)
	return name
end

function isAtMother()
	if deviceName():find("Mother") then
		return true
	end
	return false
end

function isIMacAtHome()
	if deviceName():find("iMac") and deviceName():find("Home") then
		return true
	end
	return false
end

function notify(text)
	if text then
		text = trim(text)
	else
		text = "empty string"
	end
	hs.notify.new {title = "Hammerspoon", informativeText = text}:send()
	print("notify: " .. text) -- for the console
end

---whether the current time is between start & end
---@param startHour integer
---@param endHour integer
---@return boolean
function betweenTime(startHour, endHour)
	local currentHour = hs.timer.localTime() / 60 / 60
	return currentHour > startHour and currentHour < endHour
end

---general log util
---@param text string
---@param logpath any
function log(text, logpath)
	text = trim(text)
	hs.execute('mkdir -p "$(dirname "' .. logpath .. '")"')
	hs.execute('echo "$(date "+%Y-%m-%d %H:%M")" "' .. text .. '" >> "' .. logpath .. '"')
	print("log: " .. text) -- for the console
end

---name of frontapp
---@return string
function frontApp()
	return hs.application.frontmostApplication():name()
end

function appIsRunning(appName)
	-- can't use ":isRunning()", since the application object is nil when it
	-- wasn't running before
	local runs = hs.application.get(appName)
	if runs then return true
	else return false end
end

function openIfNotRunning(appName)
	local runs = hs.application.get(appName)
	if runs then
		return
	else
		hs.application.open(appName)
	end
end

function killIfRunning(appName)
	local runs = hs.application.get(appName)
	if runs then runs:kill() end
	hs.timer.doAfter(1, function()
		runs = hs.application.get(appName)
		if runs then runs:kill9() end
	end)
end

-- won't work with Chromium browsers due to bug
function openLinkInBackground(url)
	hs.execute('open -g "' .. url .. '"')
end
