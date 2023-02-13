Hotkey = hs.hotkey.bind
Alert = hs.alert.show
Keystroke = hs.eventtap.keyStroke
Aw = hs.application.watcher
Wf = hs.window.filter
App = hs.application
Applescript = hs.osascript.applescript
UriScheme = hs.urlevent.bind
Pw = hs.pathwatcher.new
TableContains = hs.fnutils.contains
--------------------------------------------------------------------------------

Hyper = { "cmd", "alt", "ctrl", "shift" }
I = hs.inspect -- to inspect tables in the console

--------------------------------------------------------------------------------
-- general lua utils

---trims whitespace from string
---@param str string
---@return string
function Trim(str)
	if not str then return "" end
	str = str:gsub("^%s*(.-)%s*$", "%1")
	return str
end

---write to a file, using lua io
---@param filepath string
---@param textToAppend string
function AppendToFile(filepath, textToAppend)
	local file, err = io.open(filepath, "a")
	if file then
		file:write(textToAppend)
		file:close()
	else
		print("error:", err) 
	end
end

--------------------------------------------------------------------------------

---gets shell environment variable. WARN: if .zshenv is changed during
--Hammerspoon's runtime, this	will not work.
---@param VAR string
---@return string
function Getenv(VAR)
	local out = hs.execute("echo $" .. VAR):gsub("\n$", "")
	if not out or out == "" then
		Notify("⚠️️ $" .. VAR .. " could not be retrieved.")
		return ""
	else
		return out
	end
end

---Repeat a Function multiple times
---@param delaySecs number|number[]
---@param func function function to repeat
function RunWithDelays(delaySecs, func)
	if type(delaySecs) == "number" then delaySecs = { delaySecs } end
	for _, delay in pairs(delaySecs) do
		hs.timer.doAfter(delay, func)
	end
end

---@return boolean
function IsProjector()
	local mainDisplayName = hs.screen.primaryScreen():name()
	local projectorHelmholtz = mainDisplayName == "ViewSonic PJ"
	local tvLeuthinger = mainDisplayName == "TV_MONITOR"
	return projectorHelmholtz or tvLeuthinger
end

---@return boolean
function IsAtOffice()
	local mainDisplayName = hs.screen.primaryScreen():name()
	local screenOne = mainDisplayName == "HP E223"
	local screenTwo = mainDisplayName == "Acer CB241HY"
	return screenOne or screenTwo
end

---@return boolean
function ScreenIsUnlocked()
	local _, success = hs.execute(
		'[[ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]] && exit 0 || exit 1'
	)
	return success ---@diagnostic disable-line: return-type-mismatch
end

---@return string
function DeviceName()
	-- similar to `scutil --get ComputerName`, only native to hammerspoon and therefore a bit more reliable
	local name, _ = hs.host.localizedName():gsub(".- ", "", 1)
	return name
end

---@return boolean
function IsAtMother() return DeviceName():find("Mother") ~= nil end

---@return boolean
function IsIMacAtHome() return (DeviceName():find("iMac") and DeviceName():find("Home")) ~= nil end

---Send Notification
function Notify(...)
	local safe_args = {}
	local args = { ... }
	for _, arg in pairs(args) do
		table.insert(safe_args, tostring(arg))
	end
	local out = table.concat(safe_args, " ")
	hs.notify.show("Hammerspoon", "", out)
	print("notify: " .. out) -- log in the console, too
end

---Whether the current time is between startHour & endHour
---@param startHour number, e.g. 13.5 = 13:30
---@param endHour number
---@return boolean
function BetweenTime(startHour, endHour)
	local currentHour = hs.timer.localTime() / 60 / 60
	return currentHour > startHour and currentHour < endHour
end

---@return string
function FrontAppName()
	return hs.application.frontmostApplication():name() ---@diagnostic disable-line: return-type-mismatch
end

---@param appName string
---@return boolean
function AppIsRunning(appName)
	-- can't use ":isRunning()", since the application object is nil when it
	-- wasn't running before
	return hs.application.get(appName) ~= nil
end

---@param appNames string|string[]
function OpenApp(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local runs = App.get(name)
		if not runs then App.open(name) end
	end
end

---@param appNames string|string[]
function QuitApp(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		RunWithDelays({ 0, 0.5 }, function()
			local appObj = App.get(name)
			if appObj then appObj:kill() end
		end)
	end
end

-- won't work with Chromium browsers due to bug, but good for URI schemes
---@param url string
function OpenLinkInBackground(url) hs.execute('open -g "' .. url .. '"') end
