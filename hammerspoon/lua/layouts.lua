require("lua.utils")
require("lua.window-management")
require("lua.private")
require("lua.twitter")
--------------------------------------------------------------------------------

---@param targetMode string
local function dockSwitcher(targetMode)
	hs.execute("zsh ./helpers/dock-switching/dock-switcher.sh --load " .. targetMode)
end

---@param size integer
local function alacrittyFontSize(size)
	hs.execute("VALUE=" .. tostring(size) .. [[
		ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.yml"
		MAN_PAGE_CONFIG="$HOME/.config/alacritty/man-page.yml"
		sed -i '' "s/size: .*/size: $VALUE/" "$ALACRITTY_CONFIG"
		sed -i '' "s/size: .*/size: $VALUE/" "$MAN_PAGE_CONFIG"
	]])
end

---@return boolean
local function isWeekend()
	local weekday = os.date():sub(1, 3)
	return weekday == "Sun" or weekday == "Sat"
end

---creates a layout for hs.layout.apply
---@param pos hs.geometry
---@param display hs.screen
---@param apps string[]
---@return table to be used by hs.layout.apply
local function createLayout(pos, display, apps)
	local out = {}
	for _, app in pairs(apps) do
		table.insert(out, { app, nil, display, pos, nil, nil })
	end
	return out
end

--------------------------------------------------------------------------------
-- LAYOUTS
function MovieModeLayout()
	HoleCover("remove")
	IMacDisplay:setBrightness(0)

	RunWithDelays({ 0, 0.5 }, function() OpenApp("YouTube") end)

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
		"Warp",
		"Highlights",
		"Alacritty",
		"alacritty",
		"Twitter",
	}
	dockSwitcher("movie")
	SetDarkmode(true)
end

function WorkLayout()
	if IMacDisplay then
		local brightness
		if BetweenTime(1, 8) then
			brightness = 0
		elseif hs.brightness.ambient() > 120 then
			brightness = 100
		elseif hs.brightness.ambient() > 100 then
			brightness = 90
		else
			brightness = 80
		end
		IMacDisplay:setBrightness(brightness)
	end

	HoleCover()
	if not isWeekend() then OpenApp("Slack") end
	OpenApp {
		"Discord",
		"Mimestream",
		"Brave Browser",
		"Twitter",
		"Drafts",
	}
	QuitApp {
		"Finder",
		"YouTube",
		"Netflix",
		"CrunchyRoll",
		"IINA",
		"Twitch",
	}
	PrivateClosers()

	dockSwitcher("home")

	local layout = createLayout(PseudoMaximized, IMacDisplay, {
		"Brave Browser",
		"Highlights",
		"Neovide",
		"neovide",
		"Slack",
		"Discord",
		"Warp",
		"Obsidian",
		"Drafts",
		"Mimestream",
		"alacritty",
		"Alacritty",
	})
	hs.layout.apply(layout)
	TwitterToTheSide()
	ShowAllSidebars()
	RunWithDelays({ 0.5, 1 }, function()
		App("Twitter"):mainWindow():focus() -- since it is sometimes not properly raised
		App("Drafts"):activate()
		local workspace = IsAtOffice() and "Office" or "Home"
		App("Drafts"):selectMenuItem { "Workspaces", workspace }
	end)

	-- wait until sync is finished, to avoid merge conflict
	hs.timer
		.waitUntil(
			function() return not (GitDotfileSyncTask and GitDotfileSyncTask:isRunning()) end,
			function() alacrittyFontSize(26) end
		)
		:start()
end

local function motherMovieModeLayout()
	IMacDisplay:setBrightness(0)
	dockSwitcher("mother-movie")
	RunWithDelays({ 0, 1 }, function()
		OpenApp("YouTube")
		QuitApp {
			"Obsidian",
			"Drafts",
			"Slack",
			"Discord",
			"Mimestream",
			"Alfred Preferences",
			"Warp",
			"neovide",
			"Neovide",
			"alacritty",
			"Alacritty",
			"Twitter",
		}
	end)
end

local function motherHomeModeLayout()
	local brightness = BetweenTime(1, 8) and 0 or 0.8
	IMacDisplay:setBrightness(brightness)

	if not isWeekend() then OpenApp("Slack") end
	OpenApp {
		"Discord",
		"Obsidian",
		"Mimestream",
		"Brave Browser",
		"Twitter",
		"Drafts",
	}
	QuitApp {
		"YouTube",
		"Netflix",
		"CrunchyRoll",
		"IINA",
		"Twitch",
	}
	PrivateClosers()

	alacrittyFontSize(25)
	dockSwitcher("home")

	local layout = createLayout(PseudoMaximized, IMacDisplay, {
		"Brave Browser",
		"Warp",
		"Slack",
		"Discord",
		"Obsidian",
		"Drafts",
		"Mimestream",
		"alacritty",
		"Alacritty",
	})

	RunWithDelays({ 0, 0.2, 0.4, 0.6 }, function()
		hs.layout.apply(layout)
		TwitterToTheSide()
	end)
	ShowAllSidebars()
end

--------------------------------------------------------------------------------
-- SET LAYOUT AUTOMATICALLY + VIA HOTKEY
local function setLayout()
	if IsIMacAtHome() and IsProjector() then
		MovieModeLayout()
	elseif IsAtOffice() or (IsIMacAtHome() and not IsProjector()) then
		WorkLayout()
	elseif IsAtMother() and IsProjector() then
		motherMovieModeLayout()
	elseif IsAtMother() and not IsProjector() then
		motherHomeModeLayout()
	end
end

-- watcher + hotkey
DisplayCountWatcher = hs.screen.watcher.new(setLayout):start()
Hotkey(Hyper, "home", setLayout) -- hyper + eject on Apple Keyboard
Hotkey({ "shift" }, "f6", setLayout) -- for Apple keyboard

--------------------------------------------------------------------------------

-- Open at Mouse Screen
Wf_appsOnMouseScreen = Wf.new({
	"Drafts",
	"Brave Browser",
	"Mimestream",
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
	"System Preferences",
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
	RunWithDelays({ 0.1, 0.3 }, function()
		if not (mouseScreen:name() == screenOfWindow:name()) then newWin:moveToScreen(mouseScreen) end

		if appn == "Finder" or appn == "Script Editor" or appn == "Hammerspoon" then
			MoveResize(newWin, Centered)
		else
			MoveResize(newWin, Maximized)
		end
	end)
end)
