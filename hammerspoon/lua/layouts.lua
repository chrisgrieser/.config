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
function movieModeLayout()
	holeCover("remove")
	iMacDisplay:setBrightness(0)

	runWithDelays({ 0, 0.5 }, function() openApp("YouTube") end)

	quitApp {
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
	setDarkmode(true)
end

function workLayout()
	if iMacDisplay then
		local brightness
		if betweenTime(1, 8) then
			brightness = 0
		elseif hs.brightness.ambient() > 120 then
			brightness = 100
		elseif hs.brightness.ambient() > 100 then
			brightness = 90
		else
			brightness = 80
		end
		iMacDisplay:setBrightness(brightness)
	end

	holeCover()
	if not isWeekend() then openApp("Slack") end
	openApp {
		"Discord",
		"Mimestream",
		"Brave Browser",
		"Twitter",
		"Drafts",
	}
	quitApp {
		"Finder",
		"YouTube",
		"Netflix",
		"CrunchyRoll",
		"IINA",
		"Twitch",
	}
	privateClosers()

	dockSwitcher("home")

	local layout = createLayout(pseudoMaximized, iMacDisplay, {
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
	twitterToTheSide()
	showAllSidebars()
	runWithDelays({ 0.5, 1 }, function()
		app("Twitter"):mainWindow():focus() -- since it is sometimes not properly raised
		app("Drafts"):activate()
		local workspace = isAtOffice() and "Office" or "Home"
		app("Drafts"):selectMenuItem { "Workspaces", workspace }
	end)

	-- wait until sync is finished, to avoid merge conflict
	hs.timer
		.waitUntil(
			function() return not (gitDotfileSyncTask and gitDotfileSyncTask:isRunning()) end,
			function() alacrittyFontSize(26) end
		)
		:start()
end

local function motherMovieModeLayout()
	iMacDisplay:setBrightness(0)
	dockSwitcher("mother-movie")
	runWithDelays({ 0, 1 }, function()
		openApp("YouTube")
		quitApp {
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
	local brightness = betweenTime(1, 8) and 0 or 0.8
	iMacDisplay:setBrightness(brightness)

	if not isWeekend() then openApp("Slack") end
	openApp {
		"Discord",
		"Obsidian",
		"Mimestream",
		"Brave Browser",
		"Twitter",
		"Drafts",
	}
	quitApp {
		"YouTube",
		"Netflix",
		"CrunchyRoll",
		"IINA",
		"Twitch",
	}
	privateClosers()

	alacrittyFontSize(25)
	dockSwitcher("home")

	local layout = createLayout(pseudoMaximized, iMacDisplay, {
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

	runWithDelays({ 0, 0.2, 0.4, 0.6 }, function()
		hs.layout.apply(layout)
		twitterToTheSide()
	end)
	showAllSidebars()
end

--------------------------------------------------------------------------------
-- SET LAYOUT AUTOMATICALLY + VIA HOTKEY
local function setLayout()
	if isIMacAtHome() and isProjector() then
		movieModeLayout()
	elseif isAtOffice() or (isIMacAtHome() and not isProjector()) then
		workLayout()
	elseif isAtMother() and isProjector() then
		motherMovieModeLayout()
	elseif isAtMother() and not isProjector() then
		motherHomeModeLayout()
	end
end

-- watcher + hotkey
displayCountWatcher = hs.screen.watcher.new(setLayout):start()
hotkey(hyper, "home", setLayout) -- hyper + eject on Apple Keyboard
hotkey({ "shift" }, "f6", setLayout) -- for Apple keyboard

--------------------------------------------------------------------------------

-- Open at Mouse Screen
wf_appsOnMouseScreen = wf.new({
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
}):subscribe(wf.windowCreated, function(newWin)
	local mouseScreen = hs.mouse.getCurrentScreen()
	if not mouseScreen then return end
	local screenOfWindow = newWin:screen()
	if not isProjector() or mouseScreen:name() == screenOfWindow:name() then return end

	local appn = newWin:application():name()
	runWithDelays({ 0.1, 0.3 }, function()
		if not (mouseScreen:name() == screenOfWindow:name()) then newWin:moveToScreen(mouseScreen) end

		if appn == "Finder" or appn == "Script Editor" or appn == "Hammerspoon" then
			moveResize(newWin, centered)
		else
			moveResize(newWin, maximized)
		end
	end)
end)
