local M = {} -- persist from garbage collector
--------------------------------------------------------------------------------

-- bound to capslock via Karabiner elements
M.hyper = { "cmd", "alt", "ctrl" }

-- Add path for `hs.execute()`.
-- (On system start, hammerspoon sometimes does not correctly inherit PATH.)
M.exportPath = "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; "

M.videoAndAudioApps = {
	"IINA",
	"zoom.us",
	"FaceTime",
	"Netflix",
	"YouTube",
	"Crunchyroll",
	"TikTok",
	"Twitch",
}

--------------------------------------------------------------------------------

---Differentiate code to be run on reload and code to be run on startup.
---REQUIRED dependent on the setup in `reload.lua`.
---@return boolean
---@nodiscard
function M.isSystemStart()
	local _, isReloading = hs.execute("test -f /tmp/hs-is-reloading")
	return not isReloading
end

---Whether the current time is between startHour & endHour. Also works for
---ranges that go beyond midnight, e.g. 23 to 6.
---@param startHour integer time between 0 and 24. Also accepts floats like 13.5 for 13:30
---@param endHour integer time between 0 and 24
---@nodiscard
---@return boolean isInBetween
function M.betweenTime(startHour, endHour)
	if startHour >= 24 or endHour >= 24 or startHour < 0 or endHour < 0 then
		error("⚠️ BetweenTime: Invalid time range")
		return false
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
function M.openUrlInBg(url) hs.execute(("open -g %q"):format(url)) end

---@param filePath string
---@param str string
---@param append boolean append or overwrite
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

---Repeat a function multiple times, catching timers in table to avoid garbage
---collection. To avoid accumulating too many, only a certain number are kept.
---@param delaySecs number|number[]
---@param callbackFn function
function M.defer(delaySecs, callbackFn)
	if type(delaySecs) == "number" then delaySecs = { delaySecs } end
	for _, delay in pairs(delaySecs) do
		M.delayIdx = (M.delayIdx or 0) + 1
		M[M.delayIdx] = hs.timer.doAfter(delay, callbackFn):start()
		if M.delayIdx > 30 then M.delayIdx = 1 end
	end
end

---@nodiscard
---@return boolean
function M.screenIsUnlocked()
	local _, success = hs.execute(
		'[[ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]]'
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
---@return hs.application? nil if not found
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
		if not runs then hs.application.open(name) end
	end
end

---@param appNames string|string[]
function M.quitApps(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local appObj = M.app(name)
		if appObj then
			if name == "WezTerm" or name == "wezterm-gui" then
				appObj:kill9() -- avoid confirmation
			else
				appObj:kill()
			end
		end
	end
end

---close all tabs instead of closing all windows to avoid confirmation prompt
---"do you really want to x tabs?"
---@param urlPart string
function M.closeBrowserTabsWith(urlPart)
	local browser = "Brave Browser"
	hs.osascript.applescript(([[
		tell application %q
			repeat with win in (every window)
				repeat with theTab in (every tab in win)
					if the URL of theTab contains %q then close theTab
				end repeat
			end repeat
		end tell
	]]):format(browser, urlPart))

	require("win-management.auto-tile").resetWinCount(browser)
end

function M.closeAllFinderWins()
	M.defer({ 0, 3 }, function()
		local finder = M.app("Finder")
		if not finder then return end
		for _, win in ipairs(finder:allWindows()) do
			win:close()
		end
	end)
	require("win-management.auto-tile").resetWinCount("Finder")
end

function M.quitFullscreenAndVideoApps()
	-- close fullscreen wins
	for _, win in pairs(hs.window.allWindows()) do
		if win:isFullScreen() then win:setFullScreen(false) end
	end

	-- prevent the automatic quitting of audio-apps from triggering a spotify start
	require("apps.spotify").aw_spotify:stop()
	M.quitApps(M.videoAndAudioApps)
	require("apps.spotify").aw_spotify:start()
end

---@param title string
function M.createReminder(title)
	hs.osascript.javascript(([[
		const rem = Application("Reminders");
		const today = new Date();
		const newReminder = rem.Reminder({ name: %q, alldayDueDate: today });
		rem.defaultList().reminders.push(newReminder);
		rem.quit();
	]]):format(title))
end

---Also notifies if the path is not executable
---(needed, as `hs.task.new` fails if the path is not executable)
---@param path string
function M.isExecutable(path)
	local permissions = hs.fs.attributes(path, "permissions") or ""
	local executable = permissions:find("x")
	if not executable then M.notify(("❌ %q is not executable"):format(path)) end
	return executable
end

--------------------------------------------------------------------------------
return M
