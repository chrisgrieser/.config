hotkey = hs.hotkey.bind
alert = hs.alert.show
keystroke = hs.eventtap.keyStroke
aw = hs.application.watcher
wf = hs.window.filter
app = hs.application
applescript = hs.osascript.applescript
uriScheme = hs.urlevent.bind
pw = hs.pathwatcher.new
tableContains = hs.fnutils.contains
--------------------------------------------------------------------------------

hyper = {"cmd", "alt", "ctrl", "shift"}
I = hs.inspect -- to inspect tables in the console

--------------------------------------------------------------------------------

---gets shell environment variable
---@param VAR string
---@return string
function getenv(VAR)
	local out = hs.execute("echo $"..VAR):gsub("\n$", "")
	return out
end

---trims whitespace from string
---@param str string
---@return string
function trim(str)
	if not(str) then return "" end
	str = str:gsub("^%s*(.-)%s*$", "%1")
	return str
end

---Repeat a Function multiple times
---@param delaySecs number|number[]
---@param func function function to repeat
function runWithDelays(delaySecs, func)
	if type(delaySecs) == "number" then delaySecs = {delaySecs} end
	for _, delay in pairs(delaySecs) do
		hs.timer.doAfter(delay, func)
	end
end

---@return boolean
function isProjector()
	local mainDisplayName = hs.screen.primaryScreen():name()
	local projectorHelmholtz = mainDisplayName == "ViewSonic PJ"
	local tvLeuthinger = mainDisplayName == "TV_MONITOR"
	return projectorHelmholtz or tvLeuthinger
end

---@return boolean
function isAtOffice()
	local mainDisplayName = hs.screen.primaryScreen():name()
	local screenOne = mainDisplayName == "HP E223"
	local screenTwo = mainDisplayName == "Acer CB241HY"
	return screenOne or screenTwo
end

---@return boolean
function screenIsUnlocked()
	local _, success = hs.execute('[[ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]] && exit 0 || exit 1')
	return success ---@diagnostic disable-line: return-type-mismatch
end

---@return string
function deviceName()
	-- similar to `scutil --get ComputerName`, only native to hammerspoon and therefore a bit more reliable
	local name, _ = hs.host.localizedName():gsub(".- ", "", 1)
	return name
end

---@return boolean
function isAtMother()
	return deviceName():find("Mother") ~= nil
end

---@return boolean
function isIMacAtHome()
	return (deviceName():find("iMac") and deviceName():find("Home")) ~= nil
end

---Send Notification
---@param text string
function notify(text)
	local out = text and trim(text) or "empty string"
	hs.notify.new {title = "Hammerspoon", informativeText = text}:send()
	print("notify: " .. out) -- for the console
end

---Whether the current time is between startHour & endHour
---@param startHour number, e.g. 13.5 = 13:30
---@param endHour number
---@return boolean
function betweenTime(startHour, endHour)
	local currentHour = hs.timer.localTime() / 60 / 60
	return currentHour > startHour and currentHour < endHour
end

---@return string
function frontAppName()
	return hs.application.frontmostApplication():name() ---@diagnostic disable-line: return-type-mismatch
end

---@param appName string
---@return boolean
function appIsRunning(appName)
	-- can't use ":isRunning()", since the application object is nil when it
	-- wasn't running before
	return hs.application.get(appName) ~= nil
end

---@param appNames string|string[]
function openApp(appNames)
	if type(appNames) == "string" then appNames = {appNames} end
	for _, name in pairs(appNames) do
		local runs = app.get(name)
		if not(runs) then app.open(name) end
	end
end

---@param appNames string|string[]
function quitApp(appNames)
	if type(appNames) == "string" then appNames = {appNames} end
	for _, name in pairs(appNames) do
		runWithDelays({0, 0.5}, function ()
			local appObj = app.get(name)
			if appObj then appObj:kill() end
		end)
	end
end

-- won't work with Chromium browsers due to bug, but good for URI schemes
---@param url string
function openLinkInBackground(url)
	hs.execute('open -g "' .. url .. '"')
end
