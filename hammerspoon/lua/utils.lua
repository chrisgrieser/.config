Hotkey = hs.hotkey.bind
Alert = hs.alert.show
Keystroke = hs.eventtap.keyStroke
Aw = hs.application.watcher
Wf = hs.window.filter
Pw = hs.pathwatcher.new
App = hs.application
Applescript = hs.osascript.applescript
UriScheme = hs.urlevent.bind
TableContains = hs.fnutils.contains

Hyper = { "cmd", "alt", "ctrl", "shift" }
I = hs.inspect -- to inspect tables in the console

--------------------------------------------------------------------------------
-- ENVIRONMENT: retrieve configs from zshenv; sometimes not loading properly
local i = 0
while not DotfilesFolder do
	DotfilesFolder = os.getenv("DOTFILE_FOLDER")
	PasswordStore = os.getenv("PASSWORD_STORE_DIR")
	VaultLocation = os.getenv("VAULT_PATH")
	FileHub = os.getenv("WD")
	hs.execute("sleep 0.2") -- since lua has no own wait command
	if i > 30 then
		Notify("⚠️ Could not retrieve .zshenv")
		return
	end
end

--------------------------------------------------------------------------------

---trims whitespace from string
---@param str string
---@return string
function Trim(str)
	if not str then return "" end
	str, _ = str:gsub("^%s*(.-)%s*$", "%1")
	return str
end

---Whether the current time is between startHour & endHour
---@param startHour number, time between 0 and 24, also accepts floats e.g. 13.5 for 13:30
---@param endHour number, time between 0 and 24, also accepts floats e.g. 13.5 for 13:30
---@return boolean|nil
function BetweenTime(startHour, endHour)
	if startHour >= 24 or endHour >= 24 or startHour < 0 or endHour < 0 then
		Notify("BetweenTime: Invalid time range")
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

---write to file
---@param filePath any
---@param str any
function WriteToFile(filePath, str)
	local file, err = io.open(filePath, "w")
	if file then
		file:write(str)
		file:close()
	else
		print("Error:", err)
	end
end

---reads the full fill
---@param filePath string
---@return string|nil file content or nil when not reading no successful
function ReadFile(filePath)
	local file = io.open(filePath, "r")
	if not file then return end
	local content = file:read("*a")
	file:close()
	return content
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

---@return string
local function deviceName()
	-- hs.host.localizedName() is similar to `scutil --get ComputerName`,
	-- only native to hammerspoon and therefore a bit more reliable
	local name, _ = hs.host.localizedName():gsub(".- ", "", 1)
	return name
end

---Repeat a function multiple times
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
function IsAtMother() return deviceName():find("Mother") ~= nil end

---@return boolean
function IsIMacAtHome() return (deviceName():find("iMac") and deviceName():find("Home")) ~= nil end

--------------------------------------------------------------------------------

---@return boolean|nil
function ScreenIsUnlocked()
	local _, success = hs.execute(
		'[[ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]] && exit 0 || exit 1'
	)
	return success = true 
end

---Send Notification, accepting any number of arguments of any type. Converts
---everything into strings, concatenates them, and then sends it.
function Notify(...)
	local safe_args = {}
	local args = { ... }
	for _, arg in pairs(args) do
		local safe = (type(arg) == "table") and hs.inspect(arg) or tostring(arg)
		table.insert(safe_args, safe)
	end
	local out = table.concat(safe_args, " ")
	hs.notify.show("Hammerspoon", "", out)
	print("Notify: " .. out)
end

---@return string
function FrontAppName()
	return hs.application.frontmostApplication():name() ---@diagnostic disable-line: return-type-mismatch
end

---@param appName string
---@return boolean
function AppIsRunning(appName)
	local app = hs.application.get(appName)
	if not app then return false end
	return app:isRunning()
end

---@param appName string
function RestartApp(appName)
	local app = hs.application(appName)
	if not app then return end
	app:kill()
	hs.timer.waitUntil(
		function() return hs.application(appName) == nil end,
		function() hs.application.open(appName) end,
		0.1
	)
end

---@param appNames string|string[]
function OpenApp(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local runs = hs.application(name) ~= nil
		if not runs then hs.application.open(name) end
	end
end

function QuitFinderIfNoWindow()
	-- quitting Finder requires `defaults write com.apple.finder QuitMenuItem -bool true`
	local finder = hs.application("Finder")
	if finder and #(finder:allWindows()) == 0 then finder:kill() end
end

---@param appNames string|string[]
function QuitApp(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		RunWithDelays({ 0, 1, 1.5 }, function()
			local appObj = hs.application.get(name)
			if appObj then appObj:kill() end
		end)
	end
end
