local M = {}

local env = require("lua.environment-vars")

MyTimers = {} -- need to catch timers in global vars to ensure they don't get garbage collected
--------------------------------------------------------------------------------

-- shorthands
M.hotkey = hs.hotkey.bind
M.keystroke = hs.eventtap.keyStroke
M.aw = hs.application.watcher
M.wf = hs.window.filter
M.applescript = hs.osascript.applescript
M.urischeme = hs.urlevent.bind
M.tbl_contains = hs.fnutils.contains

-- bound to capslock via Karabiner elements
M.hyper = { "cmd", "alt", "ctrl", "shift" }

-- add path for `hs.execute()`
M.exportPath = [[export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; ]]

-- global to inspect tables in the console more quickly
I = hs.inspect

--------------------------------------------------------------------------------

---@nodiscard
---differentiate code to be run on reload and code to be run on startup.
---dependent on the setup in `reload.lua`
---@return boolean
function M.isReloading()
	local _, isReloading = hs.execute("test -f /tmp/hs-is-reloading")
	return isReloading ~= nil
end

---Whether the current time is between startHour & endHour. Also works for
---ranges that go beyond midnight, e.g. 23 to 6.
---@param startHour number, time between 0 and 24. also accepts floats e.g. 13.5 for 13:30
---@param endHour number, time between 0 and 24
---@nodiscard
---@return boolean|nil isInBetween nil for invalid time ranges (e.g., 2 to 66)
function M.betweenTime(startHour, endHour)
	if startHour >= 24 or endHour >= 24 or startHour < 0 or endHour < 0 then
		print("⚠️ BetweenTime: Invalid time range")
		return nil
	end
	local currentHour = hs.timer.localTime() / 60 / 60
	local goesBeyondMightnight = startHour > endHour
	local isInBetween
	if goesBeyondMightnight then
		isInBetween = (currentHour > startHour) or (currentHour < endHour)
	else
		isInBetween = (currentHour > startHour) and (currentHour < endHour)
	end
	return isInBetween
end

-- CAVEAT: won't work with Chromium browsers due to bug, but works for URI schemes
---@param url string
function M.openLinkInBg(url) hs.execute('open -g "' .. url .. '"') end

---write to file (overwriting)
---@param filePath string
---@param str string
---@param append boolean
function M.writeToFile(filePath, str, append)
	local mode = append and "a" or "w"
	local file, err = io.open(filePath, mode)
	if file then
		file:write(str)
		file:close()
	else
		print("Error:", err)
	end
end

---read the full file
---@param filePath string
---@nodiscard
---@return string|nil file content or nil when reading not successful
function M.readFile(filePath)
	local file = io.open(filePath, "r")
	if not file then return end
	local content = file:read("*a")
	file:close()
	return content
end

---@nodiscard
---@return boolean
function M.isDarkMode() return hs.execute([[defaults read -g AppleInterfaceStyle]]) == "Dark\n" end

---Repeat a function multiple times
---@param delaySecs number|number[]
---@param callbackFn function function to be run on delay(s)
function M.runWithDelays(delaySecs, callbackFn)
	if type(delaySecs) == "number" then delaySecs = { delaySecs } end
	local rng = tostring(math.random())
	for _, delay in pairs(delaySecs) do
		MyTimers[rng] = hs.timer.doAfter(delay, callbackFn):start()
	end
end

---close all tabs which contain urlPart
---@param urlPart string
function M.closeTabsContaining(urlPart)
	local applescript = ([[
		tell application "%s"
			set window_list to every window
			repeat with the_window in window_list
				set tab_list to every tab in the_window
				repeat with the_tab in tab_list
					set the_url to the url of the_tab
					if the_url contains ("%s") then close the_tab
				end repeat
			end repeat
		end tell
	]]):format(env.browserApp, urlPart)
	hs.osascript.applescript(applescript)
end

---@nodiscard
---@return boolean
function M.screenIsUnlocked()
	local _, success = hs.execute(
		'[[ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]] && exit 0 || exit 1'
	)
	return success == true -- convert to Boolean
end

---Send Notification, accepting any number of arguments of any type. Converts
---everything into strings, concatenates them, and then sends it.
function M.notify(...)
	local args = hs.fnutils.map({ ... }, function(arg)
		local safeArg = (type(arg) == "table") and hs.inspect(arg) or tostring(arg)
		return safeArg
	end)
	local out = table.concat(args, " ") ---@diagnostic disable-line: param-type-mismatch
	hs.notify.show("Hammerspoon", "", out)
	print("💬 " .. out)
end

--------------------------------------------------------------------------------
-- APP UTILS

---get appObject
---@param appName string (literal & exact match)
---@nodiscard
---@return hs.application
function M.app(appName) return hs.application.find(appName, true, true) end

---@param appNames string|string[] app or apps that should be checked
---@nodiscard
---@return boolean true when *one* of the apps is frontmost
function M.isFront(appNames)
	if appNames == nil then return false end
	if type(appNames) == "string" then appNames = { appNames } end
	local oneIsFrontmost = false
	for _, name in pairs(appNames) do
		if M.app(name) and M.app(name):isFrontmost() then oneIsFrontmost = true end
	end
	return oneIsFrontmost
end

---@param appNames string|string[] app or apps that should be running
---@nodiscard
---@return boolean true when all apps are running
function M.appRunning(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	local allAreRunning = true
	for _, name in pairs(appNames) do
		if not M.app(name) then allAreRunning = false end
	end
	return allAreRunning
end

---If app is not running, will simply start the app instead
---@param appName string
---@async
function M.restartApp(appName)
	local app = M.app(appName)
	if app then app:kill() end
	MyTimers[appName] = hs.timer.waitUntil(
		function() return M.app(appName) == nil end,
		function() hs.application.open(appName) end,
		0.05
	)
end

---@param appName string
---@param callbackFn function function to execute when the app is available
---@async
function M.asSoonAsAppRuns(appName, callbackFn)
	MyTimers[appName] = hs.timer.waitUntil(function()
		local app = M.app(appName)
		local appRuns = app ~= nil
		local windowAvailable = app and app:mainWindow()
		return appRuns and windowAvailable
	end, callbackFn, 0.05)
end

---@param appNames string|string[]
function M.openApps(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local runs = M.app(name) ~= nil
		if not runs then
			if name == "Discord" then
				-- Open in `#off-topic`
				-- (using the `launched` app watcher trigger is too slow)	
				M.openLinkInBg("discord://discord.com/channels/686053708261228577/700466324840775831")
			else
				hs.application.open(name)
			end
		end
	end
end

---@param appNames string|string[]
function M.quitApp(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local appObj = M.app(name)
		if appObj then appObj:kill() end
	end
end

--------------------------------------------------------------------------------
return M
