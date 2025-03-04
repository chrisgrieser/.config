local M = {} -- persist from garbage collector

local darkmode = require("appearance.dark-mode")
local env = require("meta.environment")
local holeCover = require("appearance.hole-cover")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
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

-------------------------------------------------------------------------------
-- LAYOUTS

local function workLayout()
	local displayFunc = u.betweenTime(22, 5) and darkenDisplay or autoSetBrightness
	displayFunc()
	holeCover.update()
	darkmode.autoSwitch()
	dockSwitcher("work")

	-- prevent the automatic quitting of audio-apps from triggering starting spotify
	videoAppWatcherForSpotify:stop()
	u.closeAllTheThings()
	videoAppWatcherForSpotify:start()

	u.openApps { "Slack", "Ivory", "Mimestream" }
	hs.layout.apply {
		-- Ivory layout already managed by `mastodon.lua`
		{ "Slack", nil, wu.iMacDisplay, wu.pseudoMax },
		{ "Mimestream", nil, wu.iMacDisplay, wu.pseudoMax },
	}

	print("🔲 Loaded work layout")
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
	print("🔲 Loaded movie layout")
end

--------------------------------------------------------------------------------
-- WHEN TO SET LAYOUT

-- Select layout depending on number of screens, and prevent concurrent runs
local isLayouting = false
local function autoSetLayout()
	if isLayouting then return end
	isLayouting = true
	local layoutFunc = env.isProjector() and movieLayout or workLayout
	layoutFunc()
	u.defer(4, function() isLayouting = false end)
end

-- 1. Change of screen numbers
local prevScreenCount = #hs.screen.allScreens()
M.displayCountWatcher = hs.screen.watcher
	.new(function()
		local currentScreenCount = #hs.screen.allScreens()
		if prevScreenCount ~= currentScreenCount then -- Dock changes also trigger the screenwatcher
			autoSetLayout()
			prevScreenCount = currentScreenCount
		end
	end)
	:start()

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
