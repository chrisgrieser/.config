local M = {} -- persist from garbage collector

local display = require("appearance.screen-brightness-darkmode")
local env = require("meta.environment")
local music = require("apps.music")
local wu = require("win-management.window-utils")

---HELPERS----------------------------------------------------------------------

---@param dockToUse string
local function dockSwitcher(dockToUse)
	if env.isAtMother then dockToUse = "mother-" .. dockToUse end
	local alfredUri = "alfred://runtrigger/de.chris-grieser.dock-switcher/load-dock-layout/?argument="
		.. dockToUse
	U.openUrlInBg(alfredUri)
end

local function isWorkWeek()
	local weekday = tostring(os.date("%a"))
	return weekday ~= "Sat" and weekday ~= "Sun"
end

---LAYOUTS---------------------------------------------------------------------

---@param brightness "dark"|"auto"
local function workLayout(brightness)
	if M.isLayouting then return end
	M.isLayouting = true
	U.defer(2.5, function() M.isLayouting = false end)
	print("🔲 Layout: work")

	-- dock
	dockSwitcher("work")

	-- screen
	display.connectProjector(false, U.quitFullscreenSpaces)
	display.autoSwitch()
	if brightness == "auto" then
		U.defer(1, function() display.autoSetBrightness() end) -- await auto-switch
	end
	if brightness == "dark" then display.darkenImacDisplay() end

	-- close & open things
	U.closeAllFinderWins()
	U.closeBrowserTabsWith("all")
	U.closeVideoApps()

	U.openApps { "Ivory", isWorkWeek() and "Slack" or nil, "Gmail", "AlfredExtraPane", "Stats" }
	U.defer(2, function()
		local gmail, ivory, slack = U.app("Gmail"), U.app("Ivory"), U.app("Slack")
		if ivory then wu.moveResize(ivory:mainWindow(), wu.toTheSide) end
		if slack then wu.moveResize(slack:mainWindow(), wu.pseudoMax) end
		if gmail then
			wu.moveResize(gmail:mainWindow(), wu.pseudoMax)
			gmail:activate() -- activate Gmail last to make it frontmost
		end
	end)
end

local function movieLayout()
	if env.isAtOffice then return end
	if M.isLayouting then return end
	M.isLayouting = true
	U.defer(2.5, function() M.isLayouting = false end)
	print("🔲 Layout: movie")

	-- basic
	dockSwitcher("movie")
	music.music_trigger("pause")
	-- turn off showing hidden files
	hs.execute("defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder")

	-- screen
	display.connectProjector(true)
	display.setDarkMode("dark")
	display.darkenImacDisplay()

	-- move mouse to center of projector
	local projector = hs.screen.find(env.projectorName)
	if projector then
		local frame = projector:fullFrame()
		local centerPos = { x = frame.w / 2, y = frame.h / 2 }
		hs.mouse.setRelativePosition(centerPos, projector)
	end

	do -- for when resetting movie layout
		U.closeBrowserTabsWith("all", "youtube")
		U.quitApps("IINA")
		U.closeAllFinderWins()
	end

	-- open / quit apps
	U.openApps { "YouTube", env.isAtHome and "BetterTouchTool" or nil }
	U.defer(1, function() -- defer so external display is detected
		local youtube = U.app("YouTube")
		if not youtube then return end
		youtube:activate()

		local youtubeWin = youtube:mainWindow()
		if not youtubeWin or not projector then return end
		if youtubeWin:screen():id() ~= projector:id() then youtubeWin:moveToScreen(projector) end
	end)

	U.quitApps {
		"Stats",
		"Signal",
		"Granola",
		"Slack",
		"Alfred Preferences",
		"Highlights",
		"Obsidian",
		"Gmail",
		"Ivory",
		"Reminders",
		"Calendar",
	}
end

---WHEN TO SET LAYOUT-----------------------------------------------------------

-- 1. Hotkeys
hs.hotkey.bind({}, "home", workLayout)
hs.hotkey.bind({}, "end", movieLayout)

-- 2. URI (for Touchpad via BetterTouchTool)
hs.urlevent.bind("movie-layout", function()
	U.sound("Hero", 0.7) -- indicate that Touchpad was triggered
	movieLayout()
end)

-- 3. Systemstart
if U.isSystemStart() then workLayout("auto") end

-- 4. Mornings (reset to worklayout for logins)
M.timer_morningWorkLayout = hs.timer
	.doAt("06:00", "01d", function() workLayout("auto") end, true)
	:start()

--------------------------------------------------------------------------------
return M
