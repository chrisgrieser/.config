local M = {} -- persist from garbage collector

local darkmode = require("appearance.dark-mode")
local env = require("meta.environment")
local holeCover = require("appearance.hole-cover")
local u = require("meta.utils")
local wu = require("win-management.window-utils")

---HELPERS----------------------------------------------------------------------

---@param dockToUse string
local function dockSwitcher(dockToUse)
	local alfredUri = "alfred://runtrigger/de.chris-grieser.dock-switcher/load-dock-layout/?argument="
		.. dockToUse
	u.openUrlInBg(alfredUri)
end

local function isWorkWeek()
	local weekday = tostring(os.date("%a"))
	return weekday ~= "Sat" and weekday ~= "Sun"
end

local function darkenDisplay() wu.iMacDisplay:setBrightness(0) end

---LAYOUTS---------------------------------------------------------------------

---@param shouldDarkenDisplay boolean
local function workLayout(shouldDarkenDisplay)
	u.defer(0.2, darkmode.autoSwitch) -- defer so ambient sensor is ready
	if not shouldDarkenDisplay then u.defer(1, darkmode.autoSetBrightness) end -- defer to adjust to mode switch
	holeCover.update()
	dockSwitcher("work")

	-- close things
	u.closeAllFinderWins()
	u.quitFullscreenAndVideoApps()

	-- open things
	u.openApps { "Mona 6", "Gmail", "AlfredExtraPane", isWorkWeek() and "Slack" or nil }

	print("🔲 Layout: work")
end

local function movieLayout()
	darkmode.setDarkMode("dark")
	darkenDisplay()
	holeCover.update()
	dockSwitcher(env.isAtMother and "mother-movie" or "movie")

	-- turn off showing hidden files
	hs.execute("defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder")

	u.openApps { "YouTube", env.isAtHome and "BetterTouchTool" or nil }
	u.quitApps {
		"Signal",
		"Slack",
		"Calendar",
		"Alfred Preferences",
		"PDF Expert",
		"Highlights",
		"Obsidian",
		"WezTerm",
		"Gmail",
		"Neovide",
		"Mona 6",
		"Reminders",
	}
	print("🔲 Layout: movie")
end

---WHEN TO SET LAYOUT-----------------------------------------------------------
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

-- 5. menu bar button
-- set movie layout & move windows to projector screen
if not env.isAtOffice then
	M.menubarItem = hs
		.menubar
		.new(true, "moveAllWinsToProjectorScreen") ---@diagnostic disable-line: need-check-nil
		:setTitle("Ⱅ ") ---@diagnostic disable-line: undefined-field
		:setClickCallback(function()
			if #hs.screen.allScreens() < 2 then
				hs.alert("Only for multi-monitor setups.")
				return
			end

			movieLayout()
			local projectorScreen = hs.screen.primaryScreen()
			for _, win in pairs(hs.window:orderedWindows()) do
				win:moveToScreen(projectorScreen, true)
			end
		end)
end

--------------------------------------------------------------------------------
return M
