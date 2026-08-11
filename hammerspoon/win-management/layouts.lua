local M = {} -- persist from garbage collector

local display = require("appearance.darkmode-and-brightness")
local env = require("meta.environment")
local holeCover = require("appearance.hole-cover")
local music = require("apps.music")
local wu = require("win-management.window-utils")

---HELPERS----------------------------------------------------------------------

---@param dockToUse string
local function dockSwitcher(dockToUse)
	if env.isAtMother then dockToUse = "mother-" .. dockToUse end
	local alfredUri = "alfred://runtrigger/de.chris-grieser.dock-switcher/load-dock-layout/?argument="
		.. dockToUse
	U.openUrlInBg(alfredUri)
end

local function isWorkWeek()
	local weekday = tostring(os.date("%a"))
	return weekday ~= "Sat" and weekday ~= "Sun"
end

---@param status boolean
local function connectProjector(status)
	if not (env.isAtHome or env.isAtMother) then return end
	if env.hasProjector() == status then return end

	local setTo = status and "on" or "off"
	local delay = 0
	if not (U.appRunning("BetterDisplay")) then
		local app = hs.application.open("BetterDisplay")
		if not app then
			U.alertAndLog("Could not find BetterDisplay.")
			return
		end
		delay = 2
	end
	U.defer(delay, function()
		local name = env.projectorName
		local shellScript = ('betterdisplaycli set --name="%s" --connected="%s"'):format(name, setTo)
		hs.execute(U.exportPath .. shellScript)
	end)
	U.defer(delay + 1, function()
		local success = env.hasProjector() == status
		if not success then
			local msg = "Could not set projector to " .. setTo
			U.sound("Basso", 0.4)
			U.alertAndLog(msg, 4)
		end
	end)
end

---LAYOUTS---------------------------------------------------------------------

---@param brightness "dark"|"auto"
local function workLayout(brightness)
	if M.isLayouting then return end
	M.isLayouting = true
	U.defer(2.5, function() M.isLayouting = false end)

	-- screen
	connectProjector(false)
	U.defer(0.2, display.autoSwitch) -- defer so ambient sensor is ready
	U.defer(1, holeCover.update) -- defer removal of external display is detected
	dockSwitcher("work")
	if brightness == "auto" then
		U.defer(1, display.autoSetBrightness) -- defer to adjust to mode switch
	elseif brightness == "auto" then
		display.darkenImacDisplay()
	end

	-- close things
	U.closeAllFinderWins()
	U.quitFullscreenAndVideoApps()

	-- open things
	U.openApps { "Ivory", isWorkWeek() and "Slack" or nil, "Gmail", "AlfredExtraPane", "Stats" }
	U.defer(1, function()
		local gmail, ivory = U.app("Gmail"), U.app("Ivory")
		if ivory then wu.moveResize(ivory:mainWindow(), wu.toTheSide) end
		if gmail then
			wu.moveResize(gmail:mainWindow(), wu.pseudoMax)
			gmail:activate() -- activate Gmail last to make it frontmost
		end
	end)

	print("🔲 Layout: work")
end

local function movieLayout()
	if env.isAtOffice then return end
	if M.isLayouting then return end
	M.isLayouting = true
	U.defer(2.5, function() M.isLayouting = false end)

	-- screen
	connectProjector(true)
	display.setDarkMode("dark")
	display.darkenImacDisplay()
	U.defer({ 1, 3 }, holeCover.update) -- defer so external display is detected
	dockSwitcher("movie")
	music.music_trigger("pause")

	-- move mouse to center of projector
	local projector = hs.screen.find(env.projectorName)
	if projector then
		local frame = projector:fullFrame()
		local centerPos = { x = frame.w / 2, y = frame.h / 2 }
		hs.mouse.setRelativePosition(centerPos, projector)
	end

	-- turn off showing hidden files
	hs.execute("defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder")

	do -- when resetting movie layout
		U.closeBrowserTabsWith("all", "youtube")
		U.quitApps("IINA")
		U.closeAllFinderWins()
	end

	-- open / quit apps
	U.openApps { "YouTube", env.isAtHome and "BetterTouchTool" or nil }
	U.defer({ 0, 1 }, function() -- defer so external display is detected
		local youtubeWin = U.app("YouTube") and U.app("YouTube"):mainWindow()
		if not youtubeWin or not projector then return end
		if youtubeWin:screen():id() ~= projector:id() then youtubeWin:moveToScreen(projector) end
	end)

	U.quitApps {
		"Stats",
		"Signal",
		"Granola",
		"Slack",
		"Alfred Preferences",
		"Highlights",
		"Obsidian",
		"Gmail",
		"Ivory",
		"Reminders",
		"Calendar",
	}
	print("🔲 Layout: movie")
end

---WHEN TO SET LAYOUT-----------------------------------------------------------

-- 1. Hotkeys
hs.hotkey.bind({}, "home", workLayout)
hs.hotkey.bind({}, "end", movieLayout)

-- 2. URI (for Touchpad via BetterTouchTool)
hs.urlevent.bind("movie-layout", function()
	U.sound("Hero", 0.7) -- indicate that Touchpad was triggered
	movieLayout()
end)

-- 3. Systemstart
if U.isSystemStart() then workLayout("auto") end

---SLEEP TIMER------------------------------------------------------------------
-- When projector is connected, check every x min if device has been idle for y
-- minutes. If so, alert and wait for z secs. If still idle then, quit
-- all video apps.
local config = {
	checkIntervalMins = 10,
	idleMins = 50,
	timeToReactSecs = 20,
}

local doEvery = hs.timer.doEvery
M.sleeptimer = doEvery(config.checkIntervalMins * 60, function()
	local isIdle = (hs.host.idleTime() / 60) > config.idleMins
	if not env.hasProjector() or not isIdle then return end

	-- inform user about upcoming sleep
	local alertMsg = ("💤 Will sleep in %ds if idle."):format(config.timeToReactSecs)
	local alertId = U.alertAndLog(alertMsg, config.timeToReactSecs)
	U.sound("Submarine", 0.3)

	-- remove alert earlier if user did something
	local halfTime = math.ceil(config.timeToReactSecs / 2)
	U.defer(halfTime, function()
		local userDidSth = hs.host.idleTime() < (config.timeToReactSecs / 2)
		if userDidSth then hs.alert.closeSpecific(alertId) end
	end)

	-- abort if user did something
	U.defer(config.timeToReactSecs, function()
		local userDidSth = hs.host.idleTime() < config.timeToReactSecs
		if userDidSth then return end

		-- close if user idle
		U.notify("💤 SleepTimer triggered")
		U.closeBrowserTabsWith("all")
		workLayout("dark") -- workLayout for login next day & darken display for sleeping
	end)
end):start()

--------------------------------------------------------------------------------
return M
