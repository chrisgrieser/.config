require("utils")
require("window-management")

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

--------------------------------------------------------------------------------
-- LAYOUTS
function movieModeLayout()
	if not(isProjector()) then return end
	iMacDisplay:setBrightness(0)

	openIfNotRunning("YouTube")
	runDelayed(1, function () openIfNotRunning("YouTube") end) -- safety redundancy
	openIfNotRunning("Übersicht") -- this works in spite of diacritic ¯\_(ツ)_/¯

	killIfRunning("Finder")
	killIfRunning("Obsidian")
	killIfRunning("Marta")
	killIfRunning("Drafts")
	killIfRunning("Slack")
	killIfRunning("Discord")
	killIfRunning("Mimestream")
	killIfRunning("Alfred Preferences")
	killIfRunning("Sublime Text")
	killIfRunning("alacritty")

	dockSwitcher("movie")
end

function motherMovieModeLayout()
	if not(isProjector()) then return end
	iMacDisplay:setBrightness(0)

	openIfNotRunning("YouTube")
	runDelayed(1, function () openIfNotRunning("YouTube") end) -- safety redundancy

	killIfRunning("Finder")
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
	openIfNotRunning("Discord")
	openIfNotRunning("Mimestream")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Twitterrific")
	openIfNotRunning("Drafts")
	killIfRunning("YouTube")
	killIfRunning("Netflix")
	killIfRunning("IINA")
	killIfRunning("Twitch")
	killIfRunning("Finder")

	sublimeFontSize(14)
	dockSwitcher("home")
end

function homeModeLayout ()
	openIfNotRunning("Discord")
	openIfNotRunning("Mimestream")
	openIfNotRunning("Slack")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Obsidian")
	openIfNotRunning("Twitterrific")
	openIfNotRunning("Drafts")

	killIfRunning("YouTube")
	hs.osascript.applescript('tell application "Übersicht" to quit') -- can't use shell or hammerspoon due to diacritic in app name m(
	killIfRunning("Netflix")
	killIfRunning("IINA")
	killIfRunning("Twitch")
	killIfRunning("Finder")
	privateClosers()

	dockSwitcher("home")
	sublimeFontSize(15)

	local toTheSide = {x=0.815, y=0, w=0.185, h=1}
	local homeLayout = {
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

	hs.layout.apply(homeLayout)
	runDelayed(0.3, function ()
		hs.layout.apply(homeLayout)
		if appIsRunning("Highlights") then hs.application("Highlights"):selectMenuItem({"View", "Show Sidebar"}) end
		hs.urlevent.openURL("obsidian://sidebar?showLeft=true&showRight=false")
		hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=show-sidebar")
	end)
end

function officeModeLayout ()
	if not(isAtOffice()) then return end
	local screen1 = hs.screen.allScreens()[1]
	local screen2 = hs.screen.allScreens()[2]

	openIfNotRunning("Discord")
	openIfNotRunning("Mimestream")
	openIfNotRunning("Slack")
	openIfNotRunning("Brave Browser")
	openIfNotRunning("Obsidian")
	openIfNotRunning("Tweeten")
	openIfNotRunning("Drafts")
	killIfRunning("Finder")
	sublimeFontSize(13)

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
	}

	hs.layout.apply(officeLayout)
	runDelayed(0.3, function ()
		hs.layout.apply(officeLayout)
		if appIsRunning("Highlights") then hs.application("Highlights"):selectMenuItem({"View", "Show Sidebar"}) end
		hs.urlevent.openURL("obsidian://sidebar?showLeft=true&showRight=false")
		hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=show-sidebar")
	end)
end

--------------------------------------------------------------------------------
-- SET LAYOUT AUTOMATICALLY + VIA HOTKEY
function setLayout()
	if isAtOffice() then officeModeLayout()
	elseif isProjector() and isIMacAtHome() then movieModeLayout()
	elseif isIMacAtHome() and not(isProjector()) then homeModeLayout()
	elseif isAtMother()() and isProjector() then motherHomeModeLayout()
	elseif isAtMother()() and not(isProjector()) then motherMovieModeLayout()
	end
end

-- watcher + hotkey
displayCountWatcher = hs.screen.watcher.new(setLayout)
displayCountWatcher:start()
hotkey(hyper, "home", setLayout)
hotkey({}, "f5", setLayout) -- for apple keyboard

--------------------------------------------------------------------------------

-- OPEN WINDOWS ALWAYS ON THE SCREEN WHERE THE MOUSE IS
function alwaysOpenOnMouseDisplay(appName, eventType, appObject)
	if not (isProjector()) then return end

	local function moveWindowToMouseScreen(win)
		local mouseScreen = hs.mouse.getCurrentScreen()
		local screenOfWindow = win:screen()
		if (mouseScreen:name() == screenOfWindow:name()) then return end
		win:moveToScreen(mouseScreen)
	end

	if (eventType == aw.launched) then
		-- delayed, to ensure window has launched properly
		runDelayed(0.5, function ()
			local appWindow = appObject:focusedWindow()
			moveWindowToMouseScreen(appWindow)
		end)
	elseif (appName == "Brave Browser" or appName == "Finder") and aw.activated and isProjector() then
		runDelayed(0.5, function ()
			local appWindow = appObject:focusedWindow()
			moveWindowToMouseScreen(appWindow)
		end)
	end
end
launchWhileMultiScreenWatcher = aw.new(alwaysOpenOnMouseDisplay)
if isIMacAtHome() then launchWhileMultiScreenWatcher:start() end
