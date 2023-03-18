Hotkey = hs.hotkey.bind
Keystroke = hs.eventtap.keyStroke
Aw = hs.application.watcher
Wf = hs.window.filter
Pw = hs.pathwatcher.new
Applescript = hs.osascript.applescript
UriScheme = hs.urlevent.bind
TableContains = hs.fnutils.contains

Hyper = { "cmd", "alt", "ctrl", "shift" } -- bound to capslock via Karabiner elements
I = hs.inspect -- to inspect tables in the console

--------------------------------------------------------------------------------
-- ENVIRONMENT
-- retrieve configs from zshenv; looped since sometimes not loading properly
local i = 0
while not DotfilesFolder do
	DotfilesFolder = os.getenv("DOTFILE_FOLDER")
	PasswordStore = os.getenv("PASSWORD_STORE_DIR")
	VaultLocation = os.getenv("VAULT_PATH")
	FileHub = os.getenv("WD")
	hs.execute("sleep 0.2") -- since lua has no wait command, using the blocking hs.execute
	if i > 30 then
		Notify("⚠️ Could not retrieve .zshenv")
		return
	end
end

--------------------------------------------------------------------------------

---trims all whitespace from string, like javascript's .trim()
---@param str string
---@return string
function Trim(str)
	if not str then return "" end
	str, _ = str:gsub("^%s*(.-)%s*$", "%1")
	return str
end

---Whether the current time is between startHour & endHour
---@param startHour number, time between 0 and 24, also accepts floats e.g. 13.5 for 13:30
---@param endHour number, time between 0 and 24
---@return boolean|nil true/false for valid time ranges, nil for invalid time range
function BetweenTime(startHour, endHour)
	if startHour >= 24 or endHour >= 24 or startHour < 0 or endHour < 0 then
		print("⚠️ BetweenTime: Invalid time range")
		return nil
	end
	local currentHour = hs.timer.localTime() / 60 / 60
	local goesBeyondMightnight = startHour > endHour
	if goesBeyondMightnight then
		return (currentHour > startHour) or (currentHour < endHour)
	else
		return (currentHour > startHour) and (currentHour < endHour)
	end
end

-- Caveat: won't work with Chromium browsers due to bug, but works for URI schemes
---@param url string
function OpenLinkInBackground(url) hs.execute('open -g "' .. url .. '"') end

---write to file (overwriting)
---@param filePath string
---@param str string
function WriteToFile(filePath, str)
	local file, err = io.open(filePath, "w")
	if file then
		file:write(str)
		file:close()
	else
		print("Error:", err)
	end
end

---read the full file
---@param filePath string
---@return string|nil file content or nil when reading not successful
function ReadFile(filePath)
	local file = io.open(filePath, "r")
	if not file then return end
	local content = file:read("*a")
	file:close()
	return content
end

---delay (blocking)
---@param secs number
function Wait(secs)
	-- since lua has not blocking delay, executing shells' sleep since os.execute
	-- is blocking
	-- os.execute("sleep " .. tostring(secs))

	hs.timer.usleep(secs * 1000000)
end

---@return boolean
function IsDarkMode()
	return hs.execute([[defaults read -g AppleInterfaceStyle]]) == "Dark\n"
end

--------------------------------------------------------------------------------

---@return string
local function deviceName()
	-- host.localizedName() is essentially equivalent to `scutil --get ComputerName`
	local name, _ = hs.host.localizedName():gsub(".- ", "", 1)
	return name
end

---Repeat a function multiple times
---@param delaySecs number|number[]
---@param callbackFn function function to be run on delay(s)
function RunWithDelays(delaySecs, callbackFn)
	if type(delaySecs) == "number" then delaySecs = { delaySecs } end
	for _, delay in pairs(delaySecs) do
		hs.timer.doAfter(delay, callbackFn)
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
function IsAtMother() return deviceName():find("Mother") ~= nil end

---@return boolean
function IsIMacAtHome() return (deviceName():find("iMac") and deviceName():find("Home")) ~= nil end

--------------------------------------------------------------------------------

---@return boolean
function ScreenIsUnlocked()
	local _, success = hs.execute(
		'[[ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]] && exit 0 || exit 1'
	)
	return success == true -- convert to Boolean
end

---whether device has been idle
---@param mins number Time idle
---@return boolean
function IdleMins(mins)
	local minutesIdle = hs.host.idleTime() / 60
	return minutesIdle > mins
end

---Send Notification, accepting any number of arguments of any type. Converts
---everything into strings, concatenates them, and then sends it.
function Notify(...)
	local safe_args = {}
	local args = { ... }
	for _, arg in pairs(args) do
		local str = (type(arg) == "table") and hs.inspect(arg) or tostring(arg)
		table.insert(safe_args, str)
	end
	local out = table.concat(safe_args, " ")
	hs.notify.show("Hammerspoon", "", out)
	print("ℹ️ [Notification] " .. out)
end

--------------------------------------------------------------------------------
-- APP UTILS

---get appObject
---@param appName string (literal & exact match)
---@return hs.application
function App(appName)
	return hs.application.find(appName, true, true)	
end

---@return string|nil
function FrontAppName() return hs.application.frontmostApplication():name() end

---@param appName string
---@return boolean
function AppIsRunning(appName)
	local app = App(appName)
	return app ~= nil
end

---If app is not running, will simply start the app instead
---@param appName string
function RestartApp(appName)
	local app = App(appName)
	if app then app:kill() end
	hs.timer.waitUntil(
		function() return App(appName) == nil end,
		function() hs.application.open(appName) end,
		0.1
	)
end

---@param app string|hs.application appName or appObj of app to wait for
---@param callbackFn function function to execute when the app is available
function AsSoonAsAppRuns(app, callbackFn)
	if type(app) == "string" then app = App(app) end
	hs.timer.waitUntil(function()
		local appRuns = app ~= nil
		local windowAvailable = app and app:mainWindow()
		return appRuns and windowAvailable
	end, callbackFn, 0.2)
end

---@param appNames string|string[]
function OpenApp(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local runs = App(name) ~= nil
		if not runs then hs.application.open(name) end
	end
end

---quitting Finder requires `defaults write com.apple.finder QuitMenuItem -bool true`
function QuitFinderIfNoWindow()
	local finder = App("Finder")
	if finder and #(finder:allWindows()) == 0 then finder:kill() end
end

---@param appNames string|string[]
function QuitApp(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local appObj = App(name)
		if appObj then appObj:kill() end
	end
end
