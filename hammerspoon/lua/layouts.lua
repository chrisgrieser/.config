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
		brightness = 100
	elseif hs.brightness.ambient() > 90 then
		brightness = 90
	elseif hs.brightness.ambient() > 50 then
		brightness = 80
	else
		brightness = 60
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
	QuitApp { "YouTube", "Netflix", "CrunchyRoll", "IINA", "Twitch", "Finder", "BetterTouchTool" }
	require("lua.private").closer()
	if not isWeekend() then OpenApp("Slack") end
	OpenApp { "Discord", "Mimestream", "Vivaldi", "Twitter", "Drafts" }
	OpenLinkInBackground("discord://discord.com/channels/686053708261228577/700466324840775831")
	OpenLinkInBackground("drafts://x-callback-url/runAction?text=&action=show-sidebar")
	Wait(0.7)

	-- layout apps
	TwitterToTheSide()
	local layout = {
		{ "Vivaldi", nil, IMacDisplay, PseudoMaximized, nil, nil },
		{ "Discord", nil, IMacDisplay, PseudoMaximized, nil, nil },
		{ "Drafts", nil, IMacDisplay, PseudoMaximized, nil, nil },
		{ "Mimestream", nil, IMacDisplay, PseudoMaximized, nil, nil },
		{ "Slack", nil, IMacDisplay, PseudoMaximized, nil, nil },
	}
	hs.layout.apply(layout)

	-- setup apps
	TwitterScrollUp()
	RestartApp("AltTab")
	RunWithDelays(0.5, function() App("Drafts"):activate() end)

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
		"Drafts",
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
---@param darken? any darken the display on the iMac as well
local function selectLayout(darken)
	if IsProjector() then
		movieLayout()
		hs.brightness.set(0)
	else
		workLayout()
		if darken then
			hs.brightness.set(0)
		else
			setHigherBrightnessDuringDay()
		end
	end
end

-- 1. Change of screen numbers
DisplayCountWatcher = hs.screen.watcher.new(function() selectLayout("darken") end):start()

-- 2. Hotkey
Hotkey(Hyper, "home", selectLayout) -- hyper + eject on Apple Keyboard

-- 3. Unlocking (with idletime)
local c = hs.caffeinate.watcher
UnlockWatcher = c.new(function(event)
	if event == c.screensDidUnlock then
		print("🔓 Unlockwatcher triggered.")
		-- delay needed to ensure displays are recognized after waking
		RunWithDelays(0.5, selectLayout)
	end
end):start()

--------------------------------------------------------------------------------
