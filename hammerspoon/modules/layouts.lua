local M = {} -- persist from garbage collector

local darkmode = require("modules.dark-mode")
local env = require("modules.environment-vars")
local u = require("modules.utils")
local visuals = require("modules.visuals")
local wu = require("modules.window-utils")
local app = require("modules.utils").app
local c = hs.caffeinate.watcher
local videoAppWatcherForSpotify = require("modules.spotify").aw_spotify
--------------------------------------------------------------------------------
-- HELPERS

---@param dockToUse string
local function dockSwitcher(dockToUse)
	local alfredUri = "alfred://runtrigger/de.chris-grieser.dock-switcher/load-dock-layout/?argument="
		.. dockToUse
	u.openInBackground(alfredUri)
end

local function autoSetBrightness()
	local ambient = hs.brightness.ambient()
	local noBrightnessSensor = ambient == -1
	if noBrightnessSensor then return end

	local target
	if ambient > 120 then
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

if not env.isAtOffice then
	M.menubarItem = hs
		.menubar
		.new(true, "moveAllWinsToProjectorScreen")
		:setTitle("Ⱅ ") ---@diagnostic disable-line: undefined-field
		:setClickCallback(wu.moveAllWinsProjectorAndDarkenBuiltinDisplay)
end

--------------------------------------------------------------------------------
-- LAYOUTS

local function workLayout()
	(u.betweenTime(22, 5) and darkenDisplay or autoSetBrightness)()
	u.runWithDelays(0.5, darkmode.autoSwitch) -- wait for brightness adjustment
	visuals.updateHoleCover()
	dockSwitcher("work")

	-- prevent the automatic quitting of audio-apps to trigger starting spotify
	videoAppWatcherForSpotify:stop()
	u.closeAllTheThings()
	videoAppWatcherForSpotify:start()

	local toOpen = { "Discord", "Mimestream", isWorkweek() and "Slack" or nil }
	u.openApps(toOpen)
	u.openApps { "Mona", "AlfredExtraPane" }
	for _, appName in pairs(toOpen) do
		u.whenAppWinAvailable(appName, function()
			local win = app(appName):mainWindow()
			wu.moveResize(win, wu.pseudoMax)
		end)
	end
	u.whenAppWinAvailable("Discord", function() app("Mimestream"):activate() end)
	hs.execute(u.exportPath .. "sketchybar --trigger update_reminder_count")

	print("🔲 Loaded WorkLayout")
end

local function movieLayout()
	darkenDisplay()
	darkmode.setDarkMode("dark")
	visuals.updateHoleCover()
	dockSwitcher(env.isAtMother and "mother-movie" or "movie")
	u.closeFinderWins()

	-- turn off showing hidden files
	hs.execute("defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder")

	u.openApps { "YouTube", env.isAtHome and "BetterTouchTool" or nil }
	u.quitApps {
		"Slack",
		"Discord",
		"BusyCal",
		"Alfred Preferences",
		"Highlights",
		"MacWhisper",
		"Obsidian",
		"WezTerm",
		"Mimestream",
		"Neovide",
		"Mona",
		"Reminders",
	}
	print("🔲 Loaded MovieModeLayout")
end

--------------------------------------------------------------------------------
-- WHEN TO SET LAYOUT

-- Select layout depending on number of screens, and prevent concurrent runs
local function autoSetLayout()
	if M.isLayouting then return end
	M.isLayouting = true;

	(env.isProjector() and movieLayout or workLayout)()

	u.runWithDelays(4, function() M.isLayouting = false end)
end

-- 1. Change of screen numbers
M.displayCountWatcher = hs.screen.watcher.new(autoSetLayout):start()

-- 2. Hotkey
hs.hotkey.bind(u.hyper, "home", autoSetLayout)

-- 3. Systemstart
if u.isSystemStart() then autoSetLayout() end

-- 4. Waking when not in the office
M.caff_unlock = c.new(function(event)
	if
		event == c.systemDidWake
		or (event == c.screensDidUnlock and not env.isAtOffice and not env.isProjector())
	then
		u.runWithDelays(0.5, autoSetLayout)
	end
end):start()

--------------------------------------------------------------------------------
return M
