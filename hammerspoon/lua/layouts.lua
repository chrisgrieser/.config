require("lua.utils")
require("lua.window-management")
require("lua.private")
local useLayout = hs.layout.apply
--------------------------------------------------------------------------------
-- HELPERS
function dockSwitcher (targetMode)
	hs.execute("zsh ./helpers/dock-switching/dock-switcher.sh --load "..targetMode)
end

function alacrittyFontSize (size)
	hs.execute("VALUE="..tostring(size)..[[
		ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.yml"
		MAN_PAGE_CONFIG="$HOME/.config/alacritty/man-page.yml"
		sed -i '' "s/size: .*/size: $VALUE/" "$ALACRITTY_CONFIG"
		sed -i '' "s/size: .*/size: $VALUE/" "$MAN_PAGE_CONFIG"
	]])
end


function showAllSidebars()
	if appIsRunning("Highlights") then app("Highlights"):selectMenuItem{"View", "Show Sidebar"} end
	openLinkInBackground("obsidian://sidebar?showLeft=true&showRight=false")
	openLinkInBackground("drafts://x-callback-url/runAction?text=&action=show-sidebar")
end

--------------------------------------------------------------------------------
-- LAYOUTS
function movieModeLayout()
	holeCover()
	iMacDisplay:setBrightness(0)

	repeatFunc({0, 0.5}, function () openIfNotRunning("YouTube") end)

	killIfRunning("Obsidian")
	killIfRunning("Marta")
	killIfRunning("Drafts")
	killIfRunning("Neovide")
	killIfRunning("neovide")
	killIfRunning("Slack")
	killIfRunning("Discord")
	killIfRunning("BusyCal")
	killIfRunning("Mimestream")
	killIfRunning("Alfred Preferences")
	killIfRunning("Finder")
	killIfRunning("Warp")
	killIfRunning("Highlights")
	killIfRunning("Alacritty")
	killIfRunning("alacritty")

	dockSwitcher("movie")
	setDarkmode(true)

	local twitterrificWin = hs.application("Twitterrific"):mainWindow()
	moveResize(twitterrificWin, toTheSide)
end

currentlyRunning = false
function homeModeLayout ()
	if betweenTime(1, 8) then
		iMacDisplay:setBrightness(0)
	else
		iMacDisplay:setBrightness(0.8)
	end
	holeCover()
	hs.execute("brew services restart sketchybar") -- restart instead of reload to update theme

	openIfNotRunning("Discord")
	openIfNotRunning("Mimestream")
	openIfNotRunning("Slack")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Twitterrific")
	openIfNotRunning("Drafts")

	killIfRunning("Finder")
	killIfRunning("YouTube")
	killIfRunning("Netflix")
	killIfRunning("IINA")
	killIfRunning("Twitch")
	privateClosers()

	dockSwitcher("home")
	
	local homeLayout = {
		{"Twitterrific", nil, iMacDisplay, toTheSide, nil, nil},
		{"Marta", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Brave Browser", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Highlights", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Neovide", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"neovide", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Slack", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Discord", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Warp", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Obsidian", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Drafts", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Mimestream", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"alacritty", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Alacritty", nil, iMacDisplay, pseudoMaximized, nil, nil},
	}

	showAllSidebars()
	useLayout(homeLayout)
	repeatFunc({0.5, 1}, function () app("Drafts"):activate() end)

	if screenIsUnlocked() and not(currentlyRunning) then
		currentlyRunning = true
		runDelayed (2, function()
         twitterrificAction("scrollup")
			currentlyRunning = false
      end)
	end

	-- wait until sync is finished, to avoid merge conflict
	hs.timer.waitUntil (
		function ()
			return not(gitDotfileSyncTask and gitDotfileSyncTask:isRunning())
		end,
		function()
			alacrittyFontSize(26)
		end
	):start()
end

function officeModeLayout ()
	local screen1 = hs.screen.allScreens()[1]
	local screen2 = hs.screen.allScreens()[2]

	openIfNotRunning("Discord")
	openIfNotRunning("Mimestream")
	openIfNotRunning("Slack")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Obsidian")
	openIfNotRunning("TweetDeck")
	openIfNotRunning("Drafts")

	dockSwitcher("office") -- separate layout to include "TweetDeck"

	local top = {x=0, y=0.015, w=1, h=0.485}
	local bottom = {x=0, y=0.5, w=1, h=0.5}
	local officeLayout = {
		-- screen 2
		{"TweetDeck", nil, screen2, top, nil, nil},
		{"Discord", nil, screen2, bottom, nil, nil},
		{"Slack", nil, screen2, bottom, nil, nil},
		-- screen 1
		{"Brave Browser", nil, screen1, maximized, nil, nil},
		{"Marta", nil, screen1, maximized, nil, nil},
		{"Sublime Text", nil, screen1, maximized, nil, nil},
		{"Obsidian", nil, screen1, maximized, nil, nil},
		{"Neovide", nil, screen1, maximized, nil, nil},
		{"neovide", nil, screen1, maximized, nil, nil},
		{"Drafts", nil, screen1, maximized, nil, nil},
		{"Mimestream", nil, screen1, maximized, nil, nil},
		{"alacritty", nil, screen1, maximized, nil, nil},
		{"Alacritty", nil, screen1, maximized, nil, nil},
		{"Warp", nil, screen1, maximized, nil, nil},
	}

	useLayout(officeLayout)
	showAllSidebars()
	runDelayed(0.3, function () useLayout(officeLayout) end)
	runDelayed(0.5, function () app("Drafts"):activate() end)

	-- wait until sync is finished, to avoid merge conflict
	hs.timer.waitUntil (
		function ()
			return not(gitDotfileSyncTask and gitDotfileSyncTask:isRunning())
		end,
		function()
			alacrittyFontSize(24)
		end
	):start()
end

function motherMovieModeLayout()
	if not(isProjector()) then return end
	iMacDisplay:setBrightness(0)

	openIfNotRunning("YouTube")
	runDelayed(1, function () openIfNotRunning("YouTube") end) -- safety redundancy

	killIfRunning("Obsidian")
	killIfRunning("Marta")
	killIfRunning("Drafts")
	killIfRunning("Slack")
	killIfRunning("Discord")
	killIfRunning("Mimestream")
	killIfRunning("Alfred Preferences")
	killIfRunning("Sublime Text")
	killIfRunning("alacritty")
	killIfRunning("Twitterrific")

	dockSwitcher("mother-movie")
end

function motherHomeModeLayout()
	iMacDisplay:setBrightness(0.8)
	openIfNotRunning("Discord")
	openIfNotRunning("Slack")
	openIfNotRunning("Obsidian")
	openIfNotRunning("Mimestream")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Twitterrific")
	openIfNotRunning("Drafts")

	killIfRunning("YouTube")
	killIfRunning("Netflix")
	killIfRunning("IINA")
	killIfRunning("Twitch")
	privateClosers()

	alacrittyFontSize(25)
	dockSwitcher("home")

	local motherHomeLayout = {
		{"Twitterrific", nil, iMacDisplay, toTheSide, nil, nil},
		{"Marta", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Brave Browser", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Warp", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Sublime Text", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Slack", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Discord", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Obsidian", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Drafts", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Mimestream", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"alacritty", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Alacritty", nil, iMacDisplay, pseudoMaximized, nil, nil},
	}

	useLayout(motherHomeLayout)
	showAllSidebars()

	repeatFunc({0.05, 0.2}, function() useLayout(motherHomeLayout) end)
end

--------------------------------------------------------------------------------
-- SET LAYOUT AUTOMATICALLY + VIA HOTKEY
function setLayout()
	if isAtOffice() then officeModeLayout()
	elseif isIMacAtHome() then
		if isProjector() then movieModeLayout()
		else homeModeLayout() end
	elseif isAtMother() then
		if isProjector() then motherMovieModeLayout()
		else motherHomeModeLayout() end
	end
end

-- watcher + hotkey
displayCountWatcher = hs.screen.watcher.new(setLayout)
displayCountWatcher:start()
hotkey(hyper, "home", setLayout) -- hyper + eject on Apple Keyboard

--------------------------------------------------------------------------------

-- Open at Mouse Screen
wf_appsOnMouseScreen = wf.new{
	"Drafts",
	"Brave Browser",
	"Mimestream",
	"Obsidian",
	"Sublime Text",
	"Alacritty",
	"alacritty",
	"Warp",
	"Slack",
	"IINA",
	"Discord",
	"Neovide",
	"neovide",
	"Marta",
	"Espanso",
	"BusyCal",
	"Alfred Preferences",
	"System Preferences",
	"BetterTouchTool",
	"YouTube",
	"Netflix",
	"Finder"
}

wf_appsOnMouseScreen:subscribe(wf.windowCreated, function (newWindow)
	local mouseScreen = hs.mouse.getCurrentScreen()
	if not(mouseScreen) then return end
	local screenOfWindow = newWindow:screen()
	if isProjector() and not(mouseScreen:name() == screenOfWindow:name()) then
		repeatFunc({0, 0.1, 0.2, 0.4, 0.6}, function()
			newWindow:moveToScreen(mouseScreen)
		end)
	end
end)
