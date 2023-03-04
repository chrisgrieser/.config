require("lua.utils")
require("lua.window-management")
require("lua.twitter")
--------------------------------------------------------------------------------
-- HELPERS

---@param targetMode string
local function dockSwitcher(targetMode)
	hs.execute("zsh ./helpers/dock-switching/dock-switcher.sh --load " .. targetMode)
end

---@return boolean
local function isWeekend()
	local weekday = os.date():sub(1, 3)
	return weekday == "Sun" or weekday == "Sat"
end

local function setHigherBrightnessDuringDay()
	local hasBrightnessSensor = hs.brightness.ambient() > -1
	if not hasBrightnessSensor then return end

	local brightness
	if BetweenTime(1, 8) then
		brightness = 0
	elseif hs.brightness.ambient() > 120 then
		brightness = 100
	elseif hs.brightness.ambient() > 100 then
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

function WorkLayout()
	print("🔲 WorkLayout: loading")
	setHigherBrightnessDuringDay()
	HoleCover()

	QuitApp { "YouTube", "Netflix", "CrunchyRoll", "IINA", "Twitch", "Finder", "BetterTouchTool" }

	OpenApp { "Discord", "Mimestream", "Vivaldi", "Twitter", "Drafts" }
	if not isWeekend() then OpenApp("Slack") end
	require("lua.private").closer()

	hs.layout.apply {
		{ "Vivaldi", nil, IMacDisplay, PseudoMaximized, nil, nil },
		{ "Discord", nil, IMacDisplay, PseudoMaximized, nil, nil },
		{ "Obsidian", nil, IMacDisplay, PseudoMaximized, nil, nil },
		{ "Drafts", nil, IMacDisplay, PseudoMaximized, nil, nil },
		{ "Mimestream", nil, IMacDisplay, PseudoMaximized, nil, nil },
		{ "Slack", nil, IMacDisplay, PseudoMaximized, nil, nil },
	}

	ShowAllSidebars()
	dockSwitcher("work")
	RestartApp("AltTab")
	hs.execute("sketchybar --set clock popup.drawing=true")

	RunWithDelays({ 0.5, 1 }, function()
		local workspace = IsAtOffice() and "Office" or "Home"
		App("Drafts"):selectMenuItem { "Workspaces", workspace }
		TwitterScrollUp()
		TwitterToTheSide()
		App("Drafts"):activate()
		App("Twitter"):mainWindow():raise()
	end)
	CleanupConsole()
	print("🔲 WorkLayout: finished layouting")
end

function MovieModeLayout()
	print("🔲 MovieModeLayout: loading")
	-- different PWAs due to not being M1 device
	local targetMode = IsAtMother() and "mother-movie" or "movie"
	dockSwitcher(targetMode)

	SetDarkmode(true)
	HoleCover("remove")
	IMacDisplay:setBrightness(0)

	RunWithDelays({ 0, 1 }, function() OpenApp { "YouTube", "BetterTouchTool" } end)
	QuitApp {
		"Obsidian",
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
	}
	-- redundancy apparently sometimes needed
	RunWithDelays(1.5, function() QuitApp("Twitter") end)
	print("🔲 MovieModeLayout: finished layouting")
end

--------------------------------------------------------------------------------
-- SET LAYOUT AUTOMATICALLY + VIA HOTKEY
local function setLayout()
	if IsProjector() then
		MovieModeLayout()
	else
		WorkLayout()
	end
end

-- watcher + hotkey
DisplayCountWatcher = hs.screen.watcher.new(setLayout):start()
Hotkey(Hyper, "home", setLayout) -- hyper + eject on Apple Keyboard
Hotkey({ "shift" }, "f6", setLayout) -- for Apple keyboard

--------------------------------------------------------------------------------

-- Open Apps always at Mouse Screen
Wf_appsOnMouseScreen = Wf.new({
	"Drafts",
	"Vivaldi",
	"Mimestream",
	"BetterTouchTool",
	"Obsidian",
	"Alacritty",
	"alacritty",
	"Warp",
	"Slack",
	"IINA",
	"Hammerspoon",
	"System Settings",
	"Discord",
	"Neovide",
	"neovide",
	"Espanso",
	"BusyCal",
	"Alfred Preferences",
	"YouTube",
	"Netflix",
	"CrunchyRoll",
	"Finder",
}):subscribe(Wf.windowCreated, function(newWin)
	local mouseScreen = hs.mouse.getCurrentScreen()
	if not mouseScreen then return end
	local screenOfWindow = newWin:screen()
	if not IsProjector() or mouseScreen:name() == screenOfWindow:name() then return end

	local appn = newWin:application():name()
	RunWithDelays({ 0.2, 0.5 }, function()
		if not (mouseScreen:name() == screenOfWindow:name()) then newWin:moveToScreen(mouseScreen) end

		if appn == "Finder" or appn == "Script Editor" or appn == "Hammerspoon" then
			MoveResize(newWin, Centered)
		else
			MoveResize(newWin, Maximized)
		end
	end)
end)
