require("utils")
require("window-management")
require("private")

--------------------------------------------------------------------------------
-- HELPERS
function dockSwitcher (targetMode)
	hs.execute("zsh ./dock-switching/dock-switcher.sh --load "..targetMode)
end

function sublimeFontSize (size)
	local toSize = tostring(size)
	hs.execute("VALUE="..toSize..[[
		SUBLIME_CONFIG="$HOME/Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings"
		sed -i '' "s/\"font_size\": .*,/\"font_size\": $VALUE,/" "$SUBLIME_CONFIG"
	]])
end

function alacrittyFontSize (size)
	local toSize = tostring(size)
	hs.execute("VALUE="..toSize..[[
		ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.yml"
		MAN_PAGE_CONFIG="$HOME/.config/alacritty/man-page.yml"
		sed -i '' "s/size: .*/size: $VALUE/" "$ALACRITTY_CONFIG"
		sed -i '' "s/size: .*/size: $VALUE/" "$MAN_PAGE_CONFIG"
	]])
end

function showAllSidebars()
	-- because of the use of URL schemes, leaves Drafts as the focused app
	if appIsRunning("Highlights") then hs.application("Highlights"):selectMenuItem({"View", "Show Sidebar"}) end
	hs.urlevent.openURL("obsidian://sidebar?showLeft=true&showRight=false")
	hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=show-sidebar")
end

--------------------------------------------------------------------------------
-- LAYOUTS
function movieModeLayout()
	holeCover() ---@diagnostic disable-line: undefined-global
	iMacDisplay:setBrightness(0)

	openIfNotRunning("YouTube")
	runDelayed(0.5, function () openIfNotRunning("YouTube") end) -- safety redundancy

	killIfRunning("Obsidian")
	killIfRunning("Marta")
	killIfRunning("Drafts")
	killIfRunning("Slack")
	killIfRunning("Discord")
	killIfRunning("Mimestream")
	killIfRunning("Alfred Preferences")
	killIfRunning("Sublime Text")
	killIfRunning("Alacritty")
	killIfRunning("alacritty")

	dockSwitcher("movie")
	setDarkmode(true)

	local twitterrificWin = hs.application("Twitterrific"):mainWindow()
	moveResize(twitterrificWin, toTheSide) ---@diagnostic disable-line: undefined-global
end

function homeModeLayout ()
	iMacDisplay:setBrightness(0.85)
	holeCover() ---@diagnostic disable-line: undefined-global
	hs.execute("brew services restart sketchybar") -- restart instead of reload to load colors

	openIfNotRunning("Discord")
	openIfNotRunning("Mimestream")
	openIfNotRunning("Slack")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Obsidian")
	openIfNotRunning("Twitterrific")
	openIfNotRunning("Drafts")

	killIfRunning("YouTube")
	killIfRunning("Netflix")
	killIfRunning("IINA")
	killIfRunning("Twitch")
	privateClosers() ---@diagnostic disable-line: undefined-global

	dockSwitcher("home")

	local homeLayout = {
		{"Twitterrific", nil, iMacDisplay, toTheSide, nil, nil}, ---@diagnostic disable-line: undefined-global
		{"Marta", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Brave Browser", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Sublime Text", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Slack", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Discord", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Obsidian", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Drafts", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Mimestream", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"alacritty", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Alacritty", nil, iMacDisplay, pseudoMaximized, nil, nil},
	}

	showAllSidebars()
	hs.layout.apply(homeLayout)
	twitterrificAction("scrollup") ---@diagnostic disable-line: undefined-global
	runDelayed(1.0, function () hs.application("Drafts"):activate() end)
	runDelayed(1.5, function () hs.application("Drafts"):activate() end)

	-- wait until sync is finished, to avoid merge conflict
	hs.timer.waitUntil (
		function ()
			return not(gitDotfileSyncTask and gitDotfileSyncTask:isRunning())  ---@diagnostic disable-line: undefined-global
		end,
		function()
			sublimeFontSize(15)
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
	openIfNotRunning("Tweeten")
	openIfNotRunning("Drafts")

	dockSwitcher("office") -- separate layout to include "Tweeten"

	local bottom = {x=0, y=0.5, w=1, h=0.5}
	local top = {x=0, y=0, w=1, h=0.5}
	local officeLayout = {
		-- screen 2
		{"Tweeten", nil, screen2, top, nil, nil},
		{"Discord", nil, screen2, bottom, nil, nil},
		{"Slack", nil, screen2, bottom, nil, nil},
		-- screen 1
		{"Brave Browser", nil, screen1, maximized, nil, nil},
		{"Marta", nil, screen1, maximized, nil, nil},
		{"Sublime Text", nil, screen1, maximized, nil, nil},
		{"Obsidian", nil, screen1, maximized, nil, nil},
		{"Drafts", nil, screen1, maximized, nil, nil},
		{"Mimestream", nil, screen1, maximized, nil, nil},
		{"alacritty", nil, screen1, maximized, nil, nil},
		{"Alacritty", nil, screen1, maximized, nil, nil},
	}

	hs.layout.apply(officeLayout)
	showAllSidebars()
	runDelayed(0.3, function ()
		hs.layout.apply(officeLayout)
	end)
	runDelayed(0.5, function ()
		hs.application("Drafts"):activate()
	end)

	-- wait until sync is finished, to avoid merge conflict
	hs.timer.waitUntil (
		function ()
			return not(gitDotfileSyncTask and gitDotfileSyncTask:isRunning())  ---@diagnostic disable-line: undefined-global
		end,
		function()
			sublimeFontSize(13)
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
	privateClosers() ---@diagnostic disable-line: undefined-global

	sublimeFontSize(14)
	alacrittyFontSize(25)
	dockSwitcher("home")

	local toTheSide = {x=0.7875, y=0, w=0.2125, h=1}
	local motherHomeLayout = {
		{"Twitterrific", nil, iMacDisplay, toTheSide, nil, nil},
		{"Marta", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Brave Browser", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Sublime Text", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Slack", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Discord", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Obsidian", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Drafts", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"Mimestream", nil, iMacDisplay, pseudoMaximized, nil, nil},
		{"alacritty", nil, iMacDisplay, pseudoMaximized, nil, nil},
	}

	hs.layout.apply(motherHomeLayout)
	runDelayed(0.3, function ()
		hs.layout.apply(motherHomeLayout)
		showAllSidebars()
	end)
	runDelayed(0.6, function () hs.layout.apply(motherHomeLayout) end)
	runDelayed(1, function () hs.layout.apply(motherHomeLayout) end)
end

function obsiDevModeLayout()
	hs.application("Obsidian"):activate()
	keystroke({"cmd", "alt"}, "i") -- open chrome dev tools
	keystroke({"cmd", "shift"}, "c") -- element picker

	hs.open(os.getenv("HOME").."/Main Vault/.obsidian/themes/Shimmering Focus/theme.css")
	local sublimeWin = hs.application("Sublime Text"):mainWindow()
	moveResize(sublimeWin, hs.layout.right50)
	runDelayed(0.5, function()
		hs.application("Sublime Text"):activate()
		keystroke({"cmd"}, "k") -- Table of Comments Plugin
	end)
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
hotkey(hyper, "home", setLayout)
hotkey(hyper, "f5", setLayout) -- for Apple Keyboard
hotkey(hyper, "f18", obsiDevModeLayout) -- esc key remapped via Karabiner

--------------------------------------------------------------------------------

-- Open at Mouse Screen
wf_appsOnMouseScreen = wf.new({
	"Drafts",
	"Brave Browser",
	"Mimestream",
	"Obsidian",
	"Sublime Text",
	"Alacritty",
	"alacritty",
	"Slack",
	"Discord",
	"Marta",
	"Espanso",
	"BusyCal",
	"Alfred Preferences",
	"System Preferences",
	"BetterTouchTool",
	"Finder"
})

wf_appsOnMouseScreen:subscribe(wf.windowCreated, function (newWindow)
	local mouseScreen = hs.mouse.getCurrentScreen()
	local screenOfWindow = newWindow:screen()
	if isProjector() and not(mouseScreen:name() == screenOfWindow:name()) then
		newWindow:moveToScreen(mouseScreen)
		runDelayed (0.3, function () newWindow:moveToScreen(mouseScreen) end)
		runDelayed (0.6, function () newWindow:moveToScreen(mouseScreen) end)
	end
end)
