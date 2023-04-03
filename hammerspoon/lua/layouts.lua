require("lua.utils")
require("lua.window-utils")
require("lua.twitter")
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
	if BetweenTime(1, 7) then -- when turning of projector at night
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

--------------------------------------------------------------------------------
-- LAYOUTS

local function workLayout()
	print("🔲 WorkLayout: loading")

	-- screen & visuals
	AutoSwitchDarkmode()
	HoleCover()
	dockSwitcher("work")
	hs.execute("sketchybar --set clock popup.drawing=true")

	-- apps
	QuitApp { "YouTube", "Netflix", "CrunchyRoll", "IINA", "Twitch", "BetterTouchTool" }
	for _, win in pairs(App("Finder"):allWindows()) do
		win:close()
	end
	require("lua.private").closer()

	local appsToOpen = { "Discord", "Mimestream", "Vivaldi" }
	if not isWeekend() then table.insert(appsToOpen, "Slack") end
	OpenApp(appsToOpen)
	OpenApp("Twitter")

	-- layout them when they all run
	MyTimer = hs.timer.waitUntil(function() return AppIsRunning(appsToOpen) end, function()
		for _, appName in pairs(appsToOpen) do
			MoveResize(App(appName):mainWindow(), PseudoMaximized)
		end
		RestartApp("AltTab") -- fix AltTab not picking up changes
		App("Mimestream"):activate()
		MoveResize(App("SidesNotes"):mainWindow(), SideNotesWide)
	end, 0.2)

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

-- 3. Unlocking (with idletime)
local c = hs.caffeinate.watcher
UnlockWatcher = c.new(function(event)
	if not event == c.screensDidUnlock then return end
	print("🔓 Unlockwatcher triggered.")

	-- HACK since `screensDidUnlock` actually triggered on wake, not unlock…
	MyTimer = hs.timer.waitUntil(ScreenIsUnlocked, function()
		RunWithDelays(0.5, function() 
			selectLayout()
			setHigherBrightnessDuringDay()
			UpdateSidenotes()
		end)
	end, 0.2)
	-- deactivate the timer in the screen is woken but not unlocked
	RunWithDelays(20, function ()
		if MyTimer and MyTimer:running() then 
			MyTimer:stop()
			MyTimer = nil
		end
	end)
end):start()

--------------------------------------------------------------------------------
