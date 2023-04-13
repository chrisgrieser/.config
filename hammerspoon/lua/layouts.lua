local darkmode = require("lua.dark-mode")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local twitter = require("lua.twitter")
--------------------------------------------------------------------------------

-- HELPERS

---@param targetMode string
local function dockSwitcher(targetMode)
	hs.execute("zsh ./helpers/dock-switching/dock-switcher.sh --load " .. targetMode)
end

---@return boolean
local function isWeekend()
	local weekday = tostring(os.date()):sub(1, 3)
	return weekday == "Sun" or weekday == "Sat"
end

local function setHigherBrightnessDuringDay()
	local hasBrightnessSensor = hs.brightness.ambient() > -1
	if not hasBrightnessSensor then return end

	local brightness
	if u.betweenTime(1, 7) or u.isProjector() then -- when turning off projector at night
		brightness = 0
	elseif hs.brightness.ambient() > 120 then
		brightness = 1
	elseif hs.brightness.ambient() > 90 then
		brightness = 0.9
	elseif hs.brightness.ambient() > 50 then
		brightness = 0.8
	else
		brightness = 0.6
	end
	wu.iMacDisplay:setBrightness(brightness)
end

local function closeAllFinderWins()
	local finder = u.app("Finder")
	if not finder then return end
	for _, win in pairs(finder:allWindows()) do
		win:close()
	end
end

--------------------------------------------------------------------------------
-- LAYOUTS

local function workLayout()
	print("🔲 WorkLayout: loading")

	-- screen & visuals
	darkmode.AutoSwitch()
	HoleCover()
	dockSwitcher("work")
	hs.execute("sketchybar --set clock popup.drawing=true")

	-- close
	u.quitApp { "YouTube", "Netflix", "CrunchyRoll", "IINA", "Twitch", "BetterTouchTool", "lo-rain" }
	require("lua.private").closer()
	closeAllFinderWins()

	-- twitter
	u.openApps("Twitter")
	u.asSoonAsAppRuns("Twitter", twitter.toTheSide)
	u.asSoonAsAppRuns("Twitter", twitter.scrollUp)

	-- open
	local appsToOpen = { "Discord", "Vivaldi", "Mimestream" }
	if not isWeekend() then table.insert(appsToOpen, 1, "Slack") end
	u.openApps(appsToOpen)
	for _, app in pairs(appsToOpen) do
		u.asSoonAsAppRuns(app, function() wu.moveResize(u.app(app):mainWindow(), wu.pseudoMax) end)
	end
	MyTimer = hs.timer.waitUntil(function() return u.appRunning(appsToOpen) end, function()
		u.app("Mimestream"):activate()
		u.restartApp("AltTab")
	end, 0.2)

	print("🔲 WorkLayout: done")
end

local function movieLayout()
	print("🔲 MovieLayout: loading")
	local targetMode = u.isAtMother() and "mother-movie" or "movie" -- different PWAs due to not being M1 device
	dockSwitcher(targetMode)
	wu.iMacDisplay:setBrightness(0)
	darkmode.set(true)
	HoleCover("remove")

	u.openApps { "YouTube", "BetterTouchTool" }
	u.quitApp {
		"Neovide",
		"lo-rain",
		"neovide",
		"Slack",
		"Discord",
		"BusyCal",
		"Mimestream",
		"Alfred Preferences",
		"Finder",
		"Highlights",
		"Alacritty",
		"alacritty",
		"Twitter",
		"Obsidian",
	}
	print("🔲 MovieModeLayout: done")
end

--------------------------------------------------------------------------------
-- TRIGGERS FOR LAYOUT CHANGE

---select layout depending on number of screens
local function selectLayout()
	if u.isProjector() then
		movieLayout()
	else
		workLayout()
	end
end

-- 1. Change of screen numbers
DisplayCountWatcher = hs.screen.watcher.new(selectLayout):start()

-- 2. Hotkey
u.hotkey(u.hyper, "home", selectLayout)

-- 3. Waking
local unlockInProgress = false
local c = hs.caffeinate.watcher
UnlockWatcher = c.new(function(event)
	if unlockInProgress or not (event == c.systemDidWake or event == c.screensDidWake) then return end
	print("🔓 System/Screen did wake.")

	UnlockTimer = hs.timer.waitUntil(u.screenIsUnlocked, function()
		unlockInProgress = true -- block multiple concurrent runs
		ReminderToSidenotes()
		u.runWithDelays(0.5, function() -- delay for recognizing screens
			setHigherBrightnessDuringDay()
			selectLayout()
		end)
		u.runWithDelays(5, function() unlockInProgress = false end)
	end, 0.2)
	-- deactivate the timer in the screen is woken but not unlocked
	u.runWithDelays(20, function()
		if UnlockTimer and UnlockTimer:running() then
			UnlockTimer:stop()
		end
	end)
end):start()
