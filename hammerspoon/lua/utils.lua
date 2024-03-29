local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
--------------------------------------------------------------------------------

-- bound to capslock via Karabiner elements
M.hyper = { "cmd", "alt", "ctrl" }

-- add path for `hs.execute()`
M.exportPath = "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; "

--------------------------------------------------------------------------------

---binds a hotkey for a specific application only
---@param appName string
---@param modifier string|string[]
---@param key string
---@param action function
function M.appHotkey(appName, modifier, key, action)
	hs.hotkey.bind(modifier, key, function()
		local frontApp = hs.application.frontmostApplication()
		if frontApp:name() == appName then
			action()
		else
			hs.eventtap.keyStroke(modifier, key, 1, frontApp)
		end
	end)
end

---differentiate code to be run on reload and code to be run on startup.
---dependent on the setup in `reload.lua`
---@return boolean
---@nodiscard
function M.isSystemStart()
	local _, isReloading = hs.execute("test -f /tmp/hs-is-reloading")
	return not isReloading
end

---Whether the current time is between startHour & endHour. Also works for
---ranges that go beyond midnight, e.g. 23 to 6.
---@param startHour integer, time between 0 and 24. also accepts floats e.g. 13.5 for 13:30
---@param endHour integer, time between 0 and 24
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
function M.openLinkInBg(url) hs.execute(("open -g %q"):format(url)) end

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
	local file, err = io.open(filePath, "r")
	if not file then return "ERROR: " .. err end
	local content = file:read("*a")
	file:close()
	return content
end

---@nodiscard
---@return boolean
function M.isDarkMode() return hs.execute("defaults read -g AppleInterfaceStyle") == "Dark\n" end

---Repeat a function multiple times
---@param delaySecs number|number[]
---@param callbackFn function function to be run on delay(s)
function M.runWithDelays(delaySecs, callbackFn)
	if type(delaySecs) == "number" then delaySecs = { delaySecs } end
	for _, delay in pairs(delaySecs) do
		M[hs.host.uuid()] = hs.timer.doAfter(delay, callbackFn):start()
	end
end

---close all tabs which contain urlPart
---@param urlPart string
function M.closeTabsContaining(urlPart)
	local applescript = ([[
		tell application %q
			set window_list to every window
			repeat with the_window in window_list
				set tab_list to every tab in the_window
				repeat with the_tab in tab_list
					set the_url to the url of the_tab
					if the_url contains (%q) then close the_tab
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

---Send system Notification, accepting any number of arguments of any type.
---Converts everything into strings, concatenates them, and then sends it.
function M.notify(...)
	local args = hs.fnutils.map({ ... }, function(arg)
		local safeArg = (type(arg) == "table") and hs.inspect(arg) or tostring(arg)
		return safeArg
	end)
	if not args then return end
	local out = table.concat(args, " ")
	hs.notify.show("Hammerspoon", "", out)
	print("💬 " .. out)
end

--------------------------------------------------------------------------------
-- APP UTILS

---get exact appObject, avoiding the imprecision of hs.application(appname)
---@param appName string (literal & exact match)
---@return hs.application
---@nodiscard
function M.app(appName)
	-- FIX neovide and wezterm have differing CLI and app names
	if appName:find("[Nn]eovide") then
		return hs.application.find("^[Nn]eovide$")
	elseif appName:find("[wW]ezterm") then
		return hs.application.find("^[Ww]ezterm%-?g?u?i?$")
	end

	return hs.application.find(appName, true, true)
end

---@param appNames string|string[] app or apps that should be checked
---@nodiscard
---@return boolean true when *one* of the apps is frontmost
function M.isFront(appNames)
	if appNames == nil then return false end
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		if M.app(name) and M.app(name):isFrontmost() then return true end
	end
	return false
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

---@async
---@param appName string
---@param callbackFn function function to execute when a window of the app is available
function M.whenAppWinAvailable(appName, callbackFn)
	M[appName .. "WinAvailable"] = hs.timer.waitUntil(function()
		local app = M.app(appName)
		local windowAvailable = app and app:mainWindow()
		return windowAvailable
	end, callbackFn, 0.1)
end

---@param appNames string|string[]
function M.openApps(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local runs = M.app(name) ~= nil
		if not runs then
			if name == "Discord" then
				-- Open in `#off-topic` (using the `launched` app watcher trigger is too slow)
				M.openLinkInBg("discord://discord.com/channels/686053708261228577/700466324840775831")
			else
				hs.application.open(name)
			end
		end
	end
end

---@param appNames string|string[]
function M.quitApps(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local appObj = M.app(name)
		if appObj then
			if name == "WezTerm" or name == "wezterm-gui" then -- avoid confirmation
				appObj:kill9()
			else
				appObj:kill()
			end
		end
	end
end

function M.closeFinderWins()
	M.runWithDelays({ 0, 3, 5 }, function()
		local finder = hs.application("Finder")
		if not finder then return end
		for _, win in ipairs(finder:allWindows()) do
			win:close()
		end
	end)
end

function M.closeAllTheThings()
	M.closeFinderWins()

	-- close fullscreen wins
	for _, win in pairs(hs.window.allWindows()) do
		if win:isFullScreen() then win:setFullScreen(false) end
	end

	-- close browser tabs and various apps
	M.closeTabsContaining(".") -- closes all tabs, since all URLs include `.`
	M.quitApps(env.videoAndAudioApps)
end

--------------------------------------------------------------------------------
return M
