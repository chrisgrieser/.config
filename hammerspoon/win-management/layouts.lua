local M = {} -- persist from garbage collector

local darkmode = require("appearance.dark-mode")
local env = require("meta.environment")
local holeCover = require("appearance.hole-cover")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
local app = require("meta.utils").app
local c = hs.caffeinate.watcher
local videoAppWatcherForSpotify = require("apps.spotify").aw_spotify
--------------------------------------------------------------------------------
-- HELPERS

---@param dockToUse string
local function dockSwitcher(dockToUse)
	local alfredUri = "alfred://runtrigger/de.chris-grieser.dock-switcher/load-dock-layout/?argument="
		.. dockToUse
	u.openUrlInBg(alfredUri)
end

local function autoSetBrightness()
	local ambient = hs.brightness.ambient()
	local noBrightnessSensor = ambient == -1
	if noBrightnessSensor then return end
	local target
	if ambient > 100 then
		target = 1
	elseif ambient > 90 then
		target = 0.9
	elseif ambient > 30 then
		target = 0.8
	elseif ambient > 15 then
		target = 0.7
	elseif ambient > 5 then
		target = 0.6
	else
		target = 0.5
	end
	wu.iMacDisplay:setBrightness(target)
end

local function darkenDisplay() wu.iMacDisplay:setBrightness(0) end

local function isWorkweek()
	local weekday = tostring(os.date("%a"))
	return weekday ~= "Sat" and weekday ~= "Sun"
end

--------------------------------------------------------------------------------
-- menu item: move windows to projector screen
if not env.isAtOffice then
	M.menubarItem = hs
		.menubar
		.new(true, "moveAllWinsToProjectorScreen")
		:setTitle("Ⱅ ") ---@diagnostic disable-line: undefined-field
		:setClickCallback(function()
			if #hs.screen.allScreens() < 2 then return end
			wu.iMacDisplay:setBrightness(0)
			local projectorScreen = hs.screen.primaryScreen()
			for _, win in pairs(hs.window:orderedWindows()) do
				win:moveToScreen(projectorScreen, true)
			end
		end)
end

--------------------------------------------------------------------------------
-- LAYOUTS

local function workLayout()
	local displayFunc = u.betweenTime(22, 5) and darkenDisplay or autoSetBrightness
	displayFunc()
	dockSwitcher("work")
	holeCover.update()
	darkmode.autoSwitch()

	-- prevent the automatic quitting of audio-apps from triggering starting spotify
	videoAppWatcherForSpotify:stop()
	u.closeAllTheThings()
	videoAppWatcherForSpotify:start()
	require("win-management.auto-tile").resetWinCount("Brave Browser")

	u.openApps {
		"Discord",
		"Mimestream",
		isWorkweek() and "Slack" or nil,
		"Ivory",
		"AlfredExtraPane",
	}
	u.whenAppWinAvailable("Discord", function() app("Mimestream"):activate() end)

	print("🔲 Loaded WorkLayout")
end

local function movieLayout()
	darkmode.setDarkMode("dark")
	darkenDisplay()
	holeCover.update()
	dockSwitcher(env.isAtMother and "mother-movie" or "movie")
	u.closeAllWindows("Finder")

	-- turn off showing hidden files
	hs.execute("defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder")

	u.openApps { "YouTube", env.isAtHome and "BetterTouchTool" or nil }
	u.quitApps {
		"Slack",
		"Discord",
		"Calendar",
		"Alfred Preferences",
		"Highlights",
		"Obsidian",
		"WezTerm",
		"Mimestream",
		"Neovide",
		"Ivory",
		"Reminders",
	}
	print("🔲 Loaded MovieModeLayout")
end

--------------------------------------------------------------------------------
-- WHEN TO SET LAYOUT

-- Select layout depending on number of screens, and prevent concurrent runs
local function autoSetLayout()
	if M.isLayouting then return end
	M.isLayouting = true

	local layoutFunc = env.isProjector() and movieLayout or workLayout
	layoutFunc()

	u.defer(4, function() M.isLayouting = false end)
end

-- 1. Change of screen numbers
M.displayCountWatcher = hs.screen.watcher.new(autoSetLayout):start()

-- 2. Hotkey
hs.hotkey.bind(u.hyper, "home", autoSetLayout)

-- 3. Systemstart
if u.isSystemStart() then autoSetLayout() end

-- 4. Waking
M.caff_unlock = c.new(function(event)
	if
		(event == c.screensDidUnlock or event == c.systemDidWake)
		and not env.isAtOffice
		and not env.isProjector()
	then
		u.defer(0.5, autoSetLayout)
	end
end):start()

--------------------------------------------------------------------------------
return M
