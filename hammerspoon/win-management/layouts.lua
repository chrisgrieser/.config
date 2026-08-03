local M = {} -- persist from garbage collector

local display = require("appearance.darkmode-and-brightness")
local env = require("meta.environment")
local holeCover = require("appearance.hole-cover")
local music = require("apps.music")
local u = require("meta.utils")
local wu = require("win-management.window-utils")

---HELPERS----------------------------------------------------------------------

---@param dockToUse string
local function dockSwitcher(dockToUse)
	if env.isAtMother then dockToUse = "mother-" .. dockToUse end
	local alfredUri = "alfred://runtrigger/de.chris-grieser.dock-switcher/load-dock-layout/?argument="
		.. dockToUse
	u.openUrlInBg(alfredUri)
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
	if not (u.appRunning("BetterDisplay")) then
		local app = hs.application.open("BetterDisplay")
		if not app then
			hs.alert("Could not find BetterDisplay.")
			return
		end
		delay = 2
	end
	u.defer(delay, function()
		local name = env.projectorName
		local shellScript = ('betterdisplaycli set --name="%s" --connected="%s"'):format(name, setTo)
		hs.execute(u.exportPath .. shellScript)
	end)
	u.defer(delay + 1, function()
		local success = env.hasProjector() == status
		if not success then
			u.sound("Bass", 0.4)
			hs.alert("Could not set projector to " .. setTo)
		end
	end)
end

---LAYOUTS---------------------------------------------------------------------

local function workLayout()
	if M.isLayouting then return end
	M.isLayouting = true
	u.defer(2.5, function() M.isLayouting = false end)

	-- screen
	connectProjector(false)
	u.defer(0.2, display.autoSwitch) -- defer so ambient sensor is ready
	u.defer(1, display.autoSetBrightness) -- defer to adjust to mode switch
	u.defer(1, holeCover.update) -- defer removal of external display is detected
	dockSwitcher("work")

	-- close things
	u.closeAllFinderWins()
	u.quitFullscreenAndVideoApps()

	-- open things
	u.openApps { "Ivory", isWorkWeek() and "Slack" or nil, "Gmail", "AlfredExtraPane", "Stats" }
	u.defer(1, function()
		wu.moveResize(u.app("Ivory"):mainWindow(), wu.toTheSide)
		local gmail = u.app("Gmail")
		if gmail then gmail:activate() end -- activate Gmail last
	end)

	print("🔲 Layout: work")
end

local function movieLayout()
	if env.isAtOffice then return end
	if M.isLayouting then return end
	M.isLayouting = true
	u.defer(2.5, function() M.isLayouting = false end)

	-- screen
	connectProjector(true)
	display.setDarkMode("dark")
	display.darkenImacDisplay()
	u.defer(1, holeCover.update) -- defer so external display is detected
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

	-- open / quit apps
	u.openApps { "YouTube", env.isAtHome and "BetterTouchTool" or nil }
	u.defer(1, function() -- defer so external display is detected
		local youtubeWin = u.app("YouTube") and u.app("YouTube"):mainWindow()
		if not youtubeWin or not projector then return end
		if youtubeWin:screen():id() ~= projector:id() then youtubeWin:moveToScreen(projector) end
	end)

	u.quitApps {
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
	u.sound("Hero", 0.8) -- indicate that Touchpad has triggered
	movieLayout()
end)

-- 3. Systemstart
if u.isSystemStart() then workLayout() end

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
	local alertId = hs.alert(alertMsg, config.timeToReactSecs)
	u.sound("Submarine", 0.3)

	-- remove alert earlier if user did something
	local halfTime = math.ceil(config.timeToReactSecs / 2)
	u.defer(halfTime, function()
		local userDidSth = hs.host.idleTime() < (config.timeToReactSecs / 2)
		if userDidSth then hs.alert.closeSpecific(alertId) end
	end)

	-- abort if user did something
	u.defer(config.timeToReactSecs, function()
		local userDidSth = hs.host.idleTime() < config.timeToReactSecs
		if userDidSth then return end

		-- close if user idle
		u.notify("💤 SleepTimer triggered")
		u.closeBrowserTabsWith("all")
		workLayout()
	end)
end):start()

--------------------------------------------------------------------------------
return M
