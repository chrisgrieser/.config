-- CONFIG
home = os.getenv("HOME")

dotfilesFolder = home.."/.config/"
fileHub = home .. "/Library/Mobile Documents/com~apple~CloudDocs/File Hub/"
vaultLocation = home .. "/main-vault/"

--------------------------------------------------------------------------------

---returns current date in ISO 8601 format
---@return string|osdate
function isodate()
	return os.date("!%Y-%m-%d")
end

---appends t2 to t1 in-place
---@param t1 table
---@param t2 table
function concatTables(t1, t2)
	for _,v in ipairs(t2) do
		table.insert(t1, v)
	end
end

---@param str string
---@param separator string uses Lua Pattern, so requires escaping
---@return table
function split(str, separator)
	str = str .. separator
	local output = {}
	-- https://www.lua.org/manual/5.4/manual.html#pdf-string.gmatch
	for i in str:gmatch("(.-)" .. separator) do
		table.insert(output, i)
	end
	return output
end

---trims whitespace from string
---@param str string
---@return string
function trim(str)
	if not(str) then return "" end
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------
hyper = {"cmd", "alt", "ctrl", "shift"}
hotkey = hs.hotkey.bind
alert = hs.alert.show
keystroke = hs.eventtap.keyStroke
aw = hs.application.watcher
wf = hs.window.filter
runDelayed = hs.timer.doAfter
app = hs.application
applescript = hs.osascript.applescript
uriScheme = hs.urlevent.bind
I = hs.inspect -- to inspect tables in the console

--------------------------------------------------------------------------------

---Repeat a Function multiple times
---@param delaySecs table<number>
---@param func function what to repeat
function repeatFunc(delaySecs, func)
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
	if deviceName():find("Mother") then
		return true
	end
	return false
end

---@return boolean
function isIMacAtHome()
	if deviceName():find("iMac") and deviceName():find("Home") then
		return true
	end
	return false
end

---Send Notification
---@param text string
function notify(text)
	if text then
		text = trim(text)
	else
		text = "empty string"
	end
	hs.notify.new {title = "Hammerspoon", informativeText = text}:send()
	print("notify: " .. text) -- for the console
end

---Whether the current time is between start & end
---@param startHour integer 13.5 = 13:30
---@param endHour integer
---@return boolean
function betweenTime(startHour, endHour)
	local currentHour = hs.timer.localTime() / 60 / 60
	return currentHour > startHour and currentHour < endHour
end

---name of frontapp
---@return string
function frontApp()
	return hs.application.frontmostApplication():name() ---@diagnostic disable-line: return-type-mismatch
end

---Check whether app is running
---@param appName string
---@return boolean
function appIsRunning(appName)
	-- can't use ":isRunning()", since the application object is nil when it
	-- wasn't running before
	local runs = hs.application.get(appName)
	if runs then return true end
	return false
end

---Open App
---@param appName string
function openIfNotRunning(appName)
	local runs = hs.application.get(appName)
	if runs then return end
	hs.application.open(appName)
end

---@param appName string
function killIfRunning(appName)
	local runs = hs.application.get(appName)
	if runs then runs:kill() end
	hs.timer.doAfter(1, function()
		runs = hs.application.get(appName)
		if runs then runs:kill9() end
	end)
end

-- won't work with Chromium browsers due to bug
---@param url string
function openLinkInBackground(url)
	hs.execute('open -g "' .. url .. '"')
end
