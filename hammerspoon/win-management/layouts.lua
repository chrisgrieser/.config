local M = {} -- persist from garbage collector

local darkmode = require("appearance.dark-mode")
local env = require("meta.environment")
local holeCover = require("appearance.hole-cover")
local music = require("apps.music")
local u = require("meta.utils")
local wu = require("win-management.window-utils")

---HELPERS----------------------------------------------------------------------

---@param dockToUse string
local function dockSwitcher(dockToUse)
	if env.isAtMother then dockToUse = "mother-" .. dockToUse end
	local alfredUri = "alfred://runtrigger/de.chris-grieser.dock-switcher/load-dock-layout/?argument="
		.. dockToUse
	u.openUrlInBg(alfredUri)
end

local function isWorkWeek()
	local weekday = tostring(os.date("%a"))
	return weekday ~= "Sat" and weekday ~= "Sun"
end

---@param status boolean
local function connectProjector(status)
	if not env.isAtHome then return end
	if env.hasProjector() == status then return end

	local setTo = status and "on" or "off"
	local delay = 0
	if not (u.appRunning("BetterDisplay")) then
		local app = hs.application.open("BetterDisplay")
		if not app then
			hs.alert("Could not find BetterDisplay.")
			return
		end
		delay = 2
	end
	u.defer(delay, function()
		local name = env.projectorName
		local shellScript = ('betterdisplaycli set --name="%s" --connected="%s"'):format(name, setTo)
		hs.execute(u.exportPath .. shellScript)
	end)
end

---LAYOUTS---------------------------------------------------------------------

local function workLayout()
	if M.isLayouting then return end
	M.isLayouting = true
	u.defer(2.5, function() M.isLayouting = false end)

	connectProjector(false)
	u.defer(0.2, darkmode.autoSwitch) -- defer so ambient sensor is ready
	u.defer(0.5, darkmode.autoSetBrightness) -- defer to adjust to mode switch
	u.defer(1, holeCover.update) -- defer so external display is detected
	dockSwitcher("work")

	-- close things
	u.closeAllFinderWins()
	u.quitFullscreenAndVideoApps()

	-- open things
	u.openApps { "Ivory", isWorkWeek() and "Slack" or nil, "Gmail", "AlfredExtraPane", "Stats" }
	u.defer(1, function()
		wu.moveResize(u.app("Ivory"):mainWindow(), wu.toTheSide)
		local gmail = u.app("Gmail")
		if gmail then gmail:activate() end -- activate Gmail last
	end)

	print("🔲 Layout: work")
end

local function movieLayout()
	if M.isLayouting then return end
	M.isLayouting = true
	u.defer(2.5, function() M.isLayouting = false end)

	connectProjector(true)
	darkmode.setDarkMode("dark")
	darkmode.darkenImacDisplay()
	u.defer(1, holeCover.update) -- defer so external display is detected
	dockSwitcher("movie")
	music.music_trigger("pause")

	-- turn off showing hidden files
	hs.execute("defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder")

	u.openApps { "YouTube", env.isAtHome and "BetterTouchTool" or nil }
	u.defer(1, function() -- defer so external display is detected
		local youtubeWin = u.app("YouTube"):mainWindow()
		local projectorScreen = hs.screen.find(env.projectorName)
		if youtubeWin:screen():id() ~= projectorScreen:id() then
			youtubeWin:moveToScreen(projectorScreen)
		end
	end)

	u.quitApps {
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
	print("🔲 Layout: movie")
end

---WHEN TO SET LAYOUT-----------------------------------------------------------

local function fixProjectorLayout()
	movieLayout()

	-- move all windows to projector
	local projectorScreen = hs.screen.find(env.projectorName)
	for _, win in pairs(hs.window:orderedWindows()) do
		win:moveToScreen(projectorScreen, true)
	end

	-- move mouse to center of projector
	local projector = hs.screen.find(env.projectorName)
	local frame = projector:fullFrame()
	local centerPos = { x = frame.w / 2, y = frame.h / 2 }
	hs.mouse.setRelativePosition(centerPos, projector)
end

--------------------------------------------------------------------------------

-- 1. Hotkeys
hs.hotkey.bind({}, "home", workLayout)
hs.hotkey.bind({}, "end", movieLayout)

-- 2. URI (for Touchpad via BetterTouchTool)
hs.urlevent.bind("fix-projector-layout", fixProjectorLayout)

-- 3. Systemstart
if u.isSystemStart() then workLayout() end

-- 4. Unlocking/SLeep
local c = hs.caffeinate.watcher
M.caff = c.new(function(event)
	if env.isAtOffice then return end
	if event == c.screensDidUnlock then
		workLayout()
		print("🔒 Screen did unlock, using work layout")
	elseif event == c.screensDidLock then
		u.quitFullscreenAndVideoApps()
		u.closeBrowserTabsWith("all")
		connectProjector(false) -- so unlocking happens on right screen
		print("🔒 Screen did lock, disconnecting projector")
	end
end):start()

--------------------------------------------------------------------------------
return M
