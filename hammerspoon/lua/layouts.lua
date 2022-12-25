require("lua.utils")
require("lua.window-management")
require("lua.private")
local useLayout = hs.layout.apply
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

local function showAllSidebars()
	if appIsRunning("Highlights") then
		app("Highlights"):selectMenuItem { "View", "Show Sidebar" }
	end
	openLinkInBackground("obsidian://sidebar?showLeft=false&showRight=true")
	openLinkInBackground("drafts://x-callback-url/runAction?text=&action=show-sidebar")
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
	holeCover()
	iMacDisplay:setBrightness(0)

	runWithDelays({ 0, 0.5, 1, 1.5 }, function() openApp("YouTube") end)

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
		"Twitterrific",
	}
	dockSwitcher("movie")
	setDarkmode(true)
end

local layoutChangeActive = false
function homeModeLayout()
	local brightness = betweenTime(1, 8) and 0 or 0.8
	iMacDisplay:setBrightness(brightness)

	holeCover()
	if not isWeekend() then openApp("Slack") end
	openApp {
		"Discord",
		"Mimestream",
		"Brave Browser",
		"Twitterrific",
		"Drafts",
	}
	quitApp {
		"Finder",
		"YouTube",
		"Netflix",
		"IINA",
		"Twitch",
	}
	privateClosers()

	dockSwitcher("home")

	local side = createLayout(iMacDisplay, pseudoMaximized, { "Twitterrific" })
	local main = createLayout(iMacDisplay, pseudoMaximized, {
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
	useLayout(hs.fnutils.concat(main, side))

	showAllSidebars()
	runWithDelays({ 0.5, 1 }, function() app("Drafts"):activate() end)

	if screenIsUnlocked() and not layoutChangeActive then
		layoutChangeActive = true
		runWithDelays(2, function()
			twitterrificAction("scrollup")
			layoutChangeActive = false
		end)
	end

	-- wait until sync is finished, to avoid merge conflict
	hs.timer
		.waitUntil(
			function() return not (gitDotfileSyncTask and gitDotfileSyncTask:isRunning()) end,
			function() alacrittyFontSize(26) end
		)
		:start()
end

function officeModeLayout()
	openApp {
		"Discord",
		"Mimestream",
		"Slack",
		"Brave Browser",
		"Obsidian",
		"TweetDeck",
		"Drafts",
	}
	dockSwitcher("office") -- separate layout to include "TweetDeck"

	local top = { x = 0, y = 0.015, w = 1, h = 0.485 }
	local bottom = { x = 0, y = 0.5, w = 1, h = 0.5 }
	local sideTop = createLayout(top, hs.screen.allScreens()[2], { "TweetDeck" })
	local sideBottom = createLayout(bottom, hs.screen.allScreens()[2], { "Discord", "Slack" })
	local main = createLayout(maximized, hs.screen.allScreens()[1], {
		"Brave Browser",
		"Obsidian",
		"Neovide",
		"neovide",
		"Drafts",
		"Mimestream",
		"alacritty",
		"Alacritty",
		"Warp",
	})
	local officeLayout = hs.fnutils.concat(sideTop, sideBottom, main)
	runWithDelays({ 0, 0.3 }, function() useLayout(officeLayout) end)

	showAllSidebars()
	runWithDelays(0.5, function() app("Drafts"):activate() end)

	-- wait until sync is finished, to avoid merge conflict
	hs.timer
		.waitUntil(
			function() return not (gitDotfileSyncTask and gitDotfileSyncTask:isRunning()) end,
			function() alacrittyFontSize(24) end
		)
		:start()
end

local function motherMovieModeLayout()
	iMacDisplay:setBrightness(0)

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
			"Twitterrific",
		}
	end)

	dockSwitcher("mother-movie")
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
		"Twitterrific",
		"Drafts",
	}
	quitApp {
		"YouTube",
		"Netflix",
		"IINA",
		"Twitch",
	}
	privateClosers()

	alacrittyFontSize(25)
	dockSwitcher("home")

	local side = createLayout(toTheSide, iMacDisplay, { "Twitterrific" })
	local main = createLayout(pseudoMaximized, iMacDisplay, {
		"Twitterrific",
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
	local motherHomeLayout = hs.fnutils.concat(main, side)

	runWithDelays({ 0, 0.1, 0.2 }, function() useLayout(motherHomeLayout) end)
	showAllSidebars()
end

--------------------------------------------------------------------------------
-- SET LAYOUT AUTOMATICALLY + VIA HOTKEY
local function setLayout()
	if isAtOffice() then
		officeModeLayout()
	elseif isIMacAtHome() and isProjector() then
		movieModeLayout()
	elseif isIMacAtHome() and not isProjector() then
		homeModeLayout()
	elseif isAtMother() and isProjector() then
		motherMovieModeLayout()
	elseif isAtMother() and not isProjector() then
		motherHomeModeLayout()
	end
end

-- watcher + hotkey
displayCountWatcher = hs.screen.watcher.new(setLayout):start()
hotkey(hyper, "home", setLayout) -- hyper + eject on Apple Keyboard

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
	"Discord",
	"Neovide",
	"neovide",
	"Espanso",
	"BusyCal",
	"Alfred Preferences",
	"System Preferences",
	"YouTube",
	"Netflix",
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
