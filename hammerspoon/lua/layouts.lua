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
	if hs.brightness.ambient() > 120 then
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

	-- start apps
	QuitApp { "YouTube", "Netflix", "CrunchyRoll", "IINA", "Twitch", "BetterTouchTool" }
	require("lua.private").closer()
	if not isWeekend() then OpenApp("Slack") end
	OpenApp { "Discord", "Mimestream", "Vivaldi", "Twitter", "SideNotes" }

	-- layout them when they all run
	hs.timer.waitUntil(
		function() return AppIsRunning { "Discord", "Mimestream", "Twitter", "SideNotes", "Vivaldi" } end,
		function()
			hs.layout.apply {
				{ "Vivaldi", nil, IMacDisplay, PseudoMaximized, nil, nil },
				{ "Discord", nil, IMacDisplay, PseudoMaximized, nil, nil },
				{ "Mimestream", nil, IMacDisplay, PseudoMaximized, nil, nil },
			}
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
	SetDarkmode(true)
	HoleCover("remove")

	OpenApp { "YouTube", "BetterTouchTool" }
	QuitApp {
		"SideNotes",
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
-- REMINDERS -> SIDENOTES
local function updateSidenotes()
	local _, success =
		hs.execute("osascript -l JavaScript './helpers/push-todays-reminders-to-sidenotes.js'")
	if not success then Notify("⚠️ Reminder-to-Sidenote failed") end
end

SideNotesTimer = hs.timer.doAt("05:00", "01d", updateSidenotes)

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
DisplayCountWatcher = hs.screen.watcher
	.new(function()
		selectLayout()
		IMacDisplay:setBrightness(0)
	end)
	:start()

-- 2. Hotkey
Hotkey(Hyper, "home", selectLayout)

-- 3. Unlocking (with idletime)
local c = hs.caffeinate.watcher
UnlockWatcher = c.new(function(event)
	if event ~= c.screensDidUnlock then return end
	print("🔓 Unlockwatcher triggered.")
	RunWithDelays(0.5, function() -- delay needed to ensure displays are recognized after waking
		selectLayout()
		setHigherBrightnessDuringDay()
		updateSidenotes()
	end)
end):start()

--------------------------------------------------------------------------------
