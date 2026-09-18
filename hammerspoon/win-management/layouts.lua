local M = {} -- persist from garbage collector

local display = require("appearance.darkmode-and-brightness")
local env = require("meta.environment")
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
---@param callback? function
local function connectProjector(status, callback)
	if not (env.isAtHome or env.isAtMother) then return end
	if env.hasProjector() == status then return end

	local setTo = status and "on" or "off"
	local delayForBetterDisplayStart = 0
	if not (U.app("BetterDisplay")) then
		local app = hs.application.open("BetterDisplay")
		if not app then
			U.alertAndLog("Could not find BetterDisplay.")
			return
		end
		delayForBetterDisplayStart = 3
	end

	-----------------------------------------------------------------------------
	local maxAttempts = 3
	local attempts = 0
	local function switch()
		attempts = attempts + 1

		-- DOCS https://github.com/waydabber/BetterDisplay/wiki/Integration-features,-CLI#cli-access-by-installing-betterdisplaycli
		-- alternative URI Scheme: BetterDisplay://set?name=P62_Pro&connected=on
		local name = env.projectorName
		local shellScript = ("betterdisplaycli set --name=%q --connected=%q"):format(name, setTo)
		hs.execute(U.exportPath .. shellScript)

		U.defer(2, function()
			local success = env.hasProjector() == status -- exit code of `betterdisplaycli` is not reliable
			if not success and (attempts < maxAttempts) then
				U.defer(1, switch)
				return
			end

			if success then
				require("appearance.hole-cover").update()
				if callback then callback() end
				print("📽️✅ Projector set to [" .. setTo .. "]")
			else
				U.sound("Basso")
				print("📽️❌ Could not set projector to [" .. setTo .. "].")
			end
		end)
	end

	U.defer(delayForBetterDisplayStart, function() switch() end)
end

---LAYOUTS---------------------------------------------------------------------

---@param setDisplay? "dark"
local function workLayout(setDisplay)
	if M.isLayouting then return end
	M.isLayouting = true
	U.defer(2.5, function() M.isLayouting = false end)
	print("🔲 Layout: work")

	-- dock
	dockSwitcher("work")

	-- screen
	connectProjector(false, U.quitFullscreenSpaces)
	display.autoSwitch()
	if setDisplay == "dark" then
		display.darkenImacDisplay()
	else
		U.defer(1, function() display.autoSetBrightness() end) -- await auto-switch
	end

	-- close & open things
	U.closeAllFinderWins()
	U.closeBrowserTabsWith("all")
	U.closeVideoApps()

	U.openApps { "Ivory", isWorkWeek() and "Slack" or nil, "Gmail", "AlfredExtraPane", "Stats" }
	U.defer(2, function()
		local gmail, ivory, slack = U.app("Gmail"), U.app("Ivory"), U.app("Slack")
		if ivory then wu.moveResize(ivory:mainWindow(), wu.toTheSide) end
		if slack then wu.moveResize(slack:mainWindow(), wu.pseudoMax) end
		if gmail then
			wu.moveResize(gmail:mainWindow(), wu.pseudoMax)
			gmail:activate() -- activate Gmail last to make it frontmost
		end
	end)
end

local function movieLayout()
	if env.isAtOffice then return end
	if M.isLayouting then return end
	M.isLayouting = true
	U.defer(2.5, function() M.isLayouting = false end)
	print("🔲 Layout: movie")

	-- basic
	dockSwitcher("movie")
	music.music_trigger("pause")
	-- turn off showing hidden files
	hs.execute("defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder")

	-- screen
	connectProjector(true)
	display.setDarkMode("dark")
	display.darkenImacDisplay()

	-- move mouse to center of projector
	local projector = hs.screen.find(env.projectorName)
	if projector then
		local frame = projector:fullFrame()
		local centerPos = { x = frame.w / 2, y = frame.h / 2 }
		hs.mouse.setRelativePosition(centerPos, projector)
	end

	do -- for when resetting movie layout
		U.closeBrowserTabsWith("all", "youtube")
		U.quitApps("IINA")
		U.closeAllFinderWins()
	end

	-- open / quit apps
	U.openApps { "YouTube", env.isAtHome and "BetterTouchTool" or nil }
	U.defer(1, function() -- defer so external display is detected
		local youtube = U.app("YouTube")
		if not youtube then return end
		youtube:activate()

		local youtubeWin = youtube:mainWindow()
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
end

---WHEN TO SET LAYOUT-----------------------------------------------------------

-- 1. Hotkeys
hs.hotkey.bind({}, "home", workLayout)
hs.hotkey.bind({}, "end", movieLayout)

-- 2. URI (for Touchpad via BetterTouchTool)
hs.urlevent.bind("movie-layout", function()
	U.sound("Hero", 0.6) -- indicate that Touchpad was triggered
	movieLayout()
end)

-- 3. Systemstart
if U.isSystemStart() then workLayout() end

---SLEEP TIMER------------------------------------------------------------------
-- When projector is connected, check every x min if device has been idle for y mins
local config = {
	checkIntervalMins = 15,
	quitVideoapps = {
		timeToReactSecs = 20,
		triggerAfterMins = 50,
	},
	disconnectProjector = {
		triggerAfterMins = 50, -- should be lower than "Lock screen -> require password after"
	},
}

local doEvery = hs.timer.doEvery
M.sleepTimer = doEvery(config.checkIntervalMins * 60, function()
	if not env.hasProjector() then return end

	local userInActiveFor = {
		projector = (hs.host.idleTime() / 60) > config.disconnectProjector.triggerAfterMins,
		videoapps = (hs.host.idleTime() / 60) > config.quitVideoapps.triggerAfterMins,
	}

	if userInActiveFor.projector then
		connectProjector(false)
		workLayout()
		local mins = config.triggerAfterMins.disconnectProjector
		print("💤💤 Reset to work layout after idle for " .. mins .. " mins.")
	elseif userInActiveFor.videoapps then
		local noVideoAppRunning = not hs.fnutils.some(U.videoAndAudioApps, U.app)
		if noVideoAppRunning then return end

		-- inform user about upcoming sleep
		local timeToReactSecs = config.quitVideoapps.timeToReactSecs
		local alertMsg = ("💤 Will sleep in %ds if idle."):format(timeToReactSecs)
		U.alertAndLog(alertMsg, config.timeToReactSecs)
		U.sound("Submarine")

		-- remove alert earlier if user reacted
		local halfTime = math.ceil(timeToReactSecs / 2)
		U.defer(halfTime, function()
			U.sound("Submarine") -- second alert
			local userDidSth = hs.host.idleTime() < (timeToReactSecs / 2)
			if userDidSth then hs.alert.closeAll() end
		end)

		-- close if *still* idle, abort otherwise
		U.defer(config.timeToReactSecs, function()
			local userDidSth = hs.host.idleTime() < timeToReactSecs
			if userDidSth then return end

			U.closeBrowserTabsWith("all")
			U.closeVideoApps()
			U.defer(1, U.quitFullscreenSpaces)
			U.notifyOnPhone("💤 Sleep timer", "triggered at " .. os.date("%H:%M"))
		end)
	end
end):start()

--------------------------------------------------------------------------------
return M
