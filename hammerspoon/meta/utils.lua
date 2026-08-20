_G.U = {} -- globally accessible for convenience

---SETTINGS---------------------------------------------------------------------

-- bound to capslock via Karabiner elements
U.hyper = { "cmd", "alt", "ctrl" }

-- Add path for `hs.execute()`.
-- (On system start, hammerspoon sometimes does not correctly inherit PATH.)
U.exportPath = "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; "

U.videoAndAudioApps = {
	"zoom.us",
	"IINA",
	"FaceTime",
	"Netflix",
	"YouTube",
	"Crunchyroll - Watch Popular Anime", -- for some reason PWA name stay in this long form
	"Prime Video",
}

---UTILS------------------------------------------------------------------------

---Differentiate code to be run on reload and code to be run on startup.
---REQUIRED dependent on the setup in `reload.lua`.
---@return boolean
---@nodiscard
function U.isSystemStart()
	local _, isReloading = hs.execute("test -f /tmp/hs-is-reloading")
	return not isReloading
end

---Whether the current time is between startHour & endHour. Also works for
---ranges that go beyond midnight, e.g. 23 to 6.
---@param startHour integer time between 0 and 24. Also accepts floats like 13.5 for 13:30
---@param endHour integer time between 0 and 24
---@return boolean isInBetween
---@nodiscard
function U.betweenTime(startHour, endHour)
	if startHour >= 24 or endHour >= 24 or startHour < 0 or endHour < 0 then
		error("⚠️ BetweenTime: Invalid time range")
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
function U.openUrlInBg(url) hs.execute(("open -g %q"):format(url)) end

---@param filePath string
---@param str string
---@param append boolean append or overwrite
function U.writeToFile(filePath, str, append)
	local mode = append and "a" or "w"
	local file, err = io.open(filePath, mode)
	if file then
		file:write(str)
		file:close()
	else
		print("Error writing to file:", err)
	end
end

---@param filePath string
---@return string|nil file content or nil when reading not successful
---@nodiscard
function U.readFile(filePath)
	local file, err = io.open(filePath, "r")
	if not file then return "ERROR: " .. err end
	local content = file:read("*a")
	file:close()
	return content
end

---@return boolean
---@nodiscard
function U.isDarkMode() return hs.execute("defaults read -g AppleInterfaceStyle") == "Dark\n" end

---Repeat a function multiple times, catching timers in table to avoid garbage
---collection. To avoid accumulating too many, only a certain number are kept.
---@param delaySecs number|number[]
---@param callbackFn function
function U.defer(delaySecs, callbackFn)
	if type(delaySecs) == "number" then delaySecs = { delaySecs } end
	for _, delay in pairs(delaySecs) do
		U.defer_timer_idx = (U.defer_timer_idx or 0) + 1
		U[U.defer_timer_idx] = hs.timer.doAfter(delay, callbackFn):start()
		if U.defer_timer_idx > 30 then U.defer_timer_idx = 0 end
	end
end

---@return boolean
---@nodiscard
function U.screenIsUnlocked()
	local _, success = hs.execute(
		'[[ "$(/usr/libexec/PlistBuddy -c "print :IOConsoleUsers:0:CGSSessionScreenIsLocked" /dev/stdin 2>/dev/null <<< "$(ioreg -n Root -d1 -a)")" != "true" ]]'
	)
	return success == true -- convert to Boolean
end

---@param msg string
function U.notify(msg)
	hs.notify.show("Hammerspoon", "", msg)
	print("💬 " .. msg)
end

---@param durationSecs? number
---@param msg string
---@return string alertUuid
function U.alertAndLog(msg, durationSecs)
	print("🔔 " .. msg)
	return hs.alert(msg, durationSecs)
end

--------------------------------------------------------------------------------
-- APP UTILS

---get appObject based on literal string (`hs.application(appname)` uses pattern)
---@param appName string literal match
---@return hs.application|nil
---@nodiscard
function U.app(appName) return hs.application.find(appName, true, true) end

---@param appNames string|string[] app or apps that should be running
---@return boolean true when all apps are running
---@nodiscard
function U.appRunning(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	local allAreRunning = true
	for _, name in pairs(appNames) do
		if not U.app(name) then allAreRunning = false end
	end
	return allAreRunning
end

---@param appNames string|string[]
function U.openApps(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local runs = U.app(name) ~= nil
		if not runs then hs.application.open(name) end
	end
end

---@param appNames string|string[]
function U.quitApps(appNames)
	if type(appNames) == "string" then appNames = { appNames } end
	for _, name in pairs(appNames) do
		local appObj = U.app(name)
		if appObj then appObj:kill() end
	end
end

---close all tabs instead of closing all windows to avoid confirmation prompt
---"do you really want to x tabs?"
---@param urlPart string|"all"
---@param except? string
function U.closeBrowserTabsWith(urlPart, except)
	if not except then except = "__NEVER__" end
	if urlPart == "all" then urlPart = "." end
	local browser = "Brave Browser" -- config

	local script = ([[
		tell application %q
			repeat with win in (every window)
				set tabsToClose to {}

				repeat with theTab in every tab in win
					if (URL of theTab contains %q) and (URL of theTab does not contain %q) then
						set end of tabsToClose to theTab
					end if
				end repeat

				repeat with theTab in tabsToClose
					close theTab
				end repeat
			end repeat
		end tell
	]]):format(browser, urlPart, except)
	hs.osascript.applescript(script)

	require("win-management.auto-tile").resetWinCount(browser)
end

function U.closeAllFinderWins()
	U.defer({ 0, 3 }, function()
		local finder = U.app("Finder")
		if not finder then return end
		for _, win in ipairs(finder:allWindows()) do
			win:close()
		end
	end)
	require("win-management.auto-tile").resetWinCount("Finder")
end

function U.quitFullscreenAndVideoApps()
	-- close fullscreen spaces
	local success, err = pcall(function()
		local spacesPerScreen = hs.spaces.allSpaces() --[[@as hs.canvas]]
		if not spacesPerScreen then 
			print("⚠️Could not close fullscreens: No spaces found.")
			return
		end
		for _screen, spaceIdsOfScreen in pairs(spacesPerScreen) do
			local unfocussedSpace = hs.fnutils.find(spaceIdsOfScreen, function(id)
				local isNormalSpace = hs.spaces.spaceType(id) == "user"
				local notFocused = hs.spaces.focusedSpace() ~= id
				return isNormalSpace and notFocused
			end)
			for _, id in ipairs(spaceIdsOfScreen) do
				local isFullScreen = hs.spaces.spaceType(id) ~= "user" -- "fullscreen" or nil
				if isFullScreen then
					if hs.spaces.focusedSpace() == id then -- focussed spaces cannot be closed
						local success, err = hs.spaces.gotoSpace(unfocussedSpace)
						if not success then print("⚠️Could goto next space: " .. err) end
					end
					local success, err = hs.spaces.removeSpace(id)
					print(
						success and "🧹 Closed fullscreen"
							or "⚠️Could not close fullscreen: " .. err
					)
				end
			end
		end
	end)
	if not success then U.alertAndLog("⚠️ Exiting fullscreen spaces failed:" .. err, 5) end

	-- prevent the automatic quitting of audio-apps from triggering a music start
	require("apps.music").aw_music:stop()
	U.quitApps(U.videoAndAudioApps)
	U.defer(1, function() require("apps.music").aw_music:start() end)

	-- extra video apps
	local extraVideoAppDir = os.getenv("HOME")
		.. "/Library/Mobile Documents/com~apple~CloudDocs/Apps/Love/"
	for file in hs.fs.dir(extraVideoAppDir) do
		local app = file:match("([^/]+)%.app$")
		if app then U.quitApps(app) end
	end
end

---@param name string
---@param volume number
function U.sound(name, volume)
	hs.sound.getByName(name):volume(volume):play() ---@diagnostic disable-line: undefined-field
end

---@param title string
function U.createReminderToday(title)
	hs.osascript.javascript(([[
		const rem = Application("Reminders");
		const today = new Date();
		const newReminder = rem.Reminder({ name: %q, alldayDueDate: today });
		rem.defaultList().reminders.push(newReminder);
		rem.quit();
	]]):format(title))
end

---Also notifies if the path is not executable
---(needed as `hs.task.new` fails if the path is not executable)
---@param path string
---@return boolean
---@nodiscard
function U.isExecutableFile(path)
	local isFile = hs.fs.attributes(path, "mode") == "file"
	if not isFile then return false end
	local permissions = hs.fs.attributes(path, "permissions") or ""
	local executable = permissions:find("x") ~= nil
	if not executable then U.notify(("❌ %q is not executable"):format(path)) end
	return executable
end
