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
	if BetweenTime(1, 7) or IsProjector() then -- when turning off projector at night
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
	IMacDisplay:setBrightness(brightness)
end

local function closeAllFinderWins()
	local finder = App("Finder")
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
	AutoSwitchDarkmode()
	HoleCover()
	dockSwitcher("work")
	hs.execute("sketchybar --set clock popup.drawing=true")

	-- close
	QuitApp { "YouTube", "Netflix", "CrunchyRoll", "IINA", "Twitch", "BetterTouchTool", "lo-rain" }
	require("lua.private").closer()
	closeAllFinderWins()

	-- twitter
	OpenApp("Twitter")
	AsSoonAsAppRuns("Twitter", TwitterToTheSide)
	AsSoonAsAppRuns("Twitter", TwitterScrollUp)

	-- open
	local appsToOpen = { "Discord", "Vivaldi", "Mimestream" }
	if not isWeekend() then table.insert(appsToOpen, 1, "Slack") end
	OpenApp(appsToOpen)
	for _, app in pairs(appsToOpen) do
		AsSoonAsAppRuns(app, function() MoveResize(App(app):mainWindow(), PseudoMaximized) end)
	end
	MyTimer = hs.timer.waitUntil(
		function() return AppRunning(appsToOpen) end,
		function()
			App("Mimestream"):activate()
			RestartApp("AltTab")
		end,
		0.2
	)

	print("🔲 WorkLayout: done")
end

local function movieLayout()
	print("🔲 MovieLayout: loading")
	local targetMode = IsAtMother() and "mother-movie" or "movie" -- different PWAs due to not being M1 device
	dockSwitcher(targetMode)
	IMacDisplay:setBrightness(0)
	SetDarkmode(true)
	HoleCover("remove")

	OpenApp { "YouTube", "BetterTouchTool" }
	QuitApp {
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
	if IsProjector() then
		movieLayout()
	else
		workLayout()
	end
end

-- 1. Change of screen numbers
DisplayCountWatcher = hs.screen.watcher.new(selectLayout):start()

-- 2. Hotkey
Hotkey(Hyper, "home", selectLayout)

-- 3. Waking
local unlockInProgress = false
local c = hs.caffeinate.watcher
UnlockWatcher = c.new(function(event)
	if unlockInProgress or not (event == c.systemDidWake or event == c.screensDidWake) then return end
	print("🔓 System/Screen did wake.")

	UnlockTimer = hs.timer.waitUntil(ScreenIsUnlocked, function()
		unlockInProgress = true -- block multiple concurrent runs
		reminderToSidenotes()
		RunWithDelays(0.5, function() -- delay for recognizing screens
			setHigherBrightnessDuringDay()
			selectLayout()
		end)
		RunWithDelays(5, function() unlockInProgress = false end)
	end, 0.2)
	-- deactivate the timer in the screen is woken but not unlocked
	RunWithDelays(20, function()
		if UnlockTimer and UnlockTimer:running() then
			UnlockTimer:stop()
			UnlockTimer = nil ---@diagnostic disable-line: assign-type-mismatch
		end
	end)
end):start()
