local M = {} -- persist from garbage collector

local darkmode = require("appearance.dark-mode")
local env = require("meta.environment")
local holeCover = require("appearance.hole-cover")
local u = require("meta.utils")
local wu = require("win-management.window-utils")

--------------------------------------------------------------------------------
-- HELPERS

---@param dockToUse string
local function dockSwitcher(dockToUse)
	local alfredUri = "alfred://runtrigger/de.chris-grieser.dock-switcher/load-dock-layout/?argument="
		.. dockToUse
	u.openUrlInBg(alfredUri)
end

local function isWeekend()
	local weekday = tostring(os.date("%a"))
	return weekday == "Sat" or weekday == "Sun"
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
	elseif ambient > 1.5 then
		target = 0.5
	else
		target = 0.4
	end
	wu.iMacDisplay:setBrightness(target)
end

local function darkenDisplay() wu.iMacDisplay:setBrightness(0) end

--------------------------------------------------------------------------------

-- MENU BAR BUTTON
-- 1. move windows to projector screen
-- 2. set dark mode
-- 3. darken display
if not env.isAtOffice then
	M.menubarItem = hs
		.menubar
		.new(true, "moveAllWinsToProjectorScreen")
		:setTitle("Ⱅ ") ---@diagnostic disable-line: undefined-field
		:setClickCallback(function()
			if #hs.screen.allScreens() < 2 then
				hs.alert.show("This button is only for multi-monitor setups.")
				return
			end

			darkenDisplay()
			darkmode.setDarkMode("dark")
			local projectorScreen = hs.screen.primaryScreen()
			for _, win in pairs(hs.window:orderedWindows()) do
				win:moveToScreen(projectorScreen, true)
			end
		end)
end

-------------------------------------------------------------------------------
-- LAYOUTS

---@param displayAlreadyDarkened boolean
local function workLayout(displayAlreadyDarkened)
	if not displayAlreadyDarkened then autoSetBrightness() end
	holeCover.update()
	dockSwitcher("work")
	darkmode.autoSwitch()

	u.closeAllTheThings()

	u.openApps { "Ivory", "Mimestream", "AlfredExtraPane" }
	if not isWeekend() then u.openApps("Slack") end
	u.whenAppWinAvailable(
		"Mimestream",
		function()
			hs.layout.apply {
				{ "Slack", nil, wu.iMacDisplay, wu.pseudoMax },
				{ "Mimestream", nil, wu.iMacDisplay, wu.pseudoMax },
				{ "Brave Browser", nil, wu.iMacDisplay, wu.pseudoMax },
			}
		end
	)
	u.whenAppWinAvailable("Ivory", function()
		u.defer(1, function()
			local mastoWin = u.app("Ivory"):mainWindow()
			mastoWin:setFrame(wu.toTheSide)
		end)
	end)

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

	u.openApps("YouTube")
	if env.isAtHome then u.openApps("BetterTouchTool") end
	u.quitApps {
		"Signal",
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

local isLayouting = false
---Select layout depending on number of screens, and prevent concurrent runs
---@param reason string?
local function autoSetLayout(reason)
	if isLayouting then return end
	isLayouting = true
	if env.isProjector() then
		movieLayout()
	else
		-- when turning projector off at night, then the display should be dark so
		-- not to get up to just turn down brightness
		local shouldDarkenDisplay = u.betweenTime(22, 6) and reason == "display-count-change"
		if shouldDarkenDisplay then darkenDisplay() end

		workLayout(shouldDarkenDisplay)
	end
	u.defer(4, function() isLayouting = false end)
end

-- 1. Change of screen numbers
local prevScreenCount = #hs.screen.allScreens()
M.displayCountWatcher = hs.screen.watcher
	.new(function()
		local currentScreenCount = #hs.screen.allScreens()
		if prevScreenCount ~= currentScreenCount then -- Dock changes also trigger the screenwatcher
			autoSetLayout("display-count-change")
			prevScreenCount = currentScreenCount
		end
	end)
	:start()

-- 2. Hotkey
hs.hotkey.bind(u.hyper, "home", autoSetLayout)

-- 3. Systemstart
if u.isSystemStart() then autoSetLayout() end

-- 4. Waking
M.caff_unlock = hs.caffeinate.watcher
	.new(function(event)
		local wokeUp = event == hs.caffeinate.watcher.screensDidUnlock
			or event == hs.caffeinate.watcher.systemDidWake
		if wokeUp and not env.isAtOffice and not env.isProjector() then
			u.defer(0.5, autoSetLayout)
		end
	end)
	:start()

--------------------------------------------------------------------------------
return M
