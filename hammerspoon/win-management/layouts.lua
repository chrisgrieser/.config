local M = {} -- persist from garbage collector

local darkmode = require("appearance.dark-mode")
local env = require("meta.environment")
local holeCover = require("appearance.hole-cover")
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
	if env.isProjector() == status then return end

	local name = "P62_Pro"
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
	u.defer(1, darkmode.autoSetBrightness) -- defer to adjust to mode switch
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
	darkmode.darkenDisplay()
	holeCover.update()
	dockSwitcher("movie")

	-- turn off showing hidden files
	hs.execute("defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder")

	u.openApps { "YouTube", env.isAtHome and "BetterTouchTool" or nil }
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
	if not env.isProjector() then return end

	-- move all windows to projector
	local projectorScreen = hs.screen.primaryScreen()
	for _, win in pairs(hs.window:orderedWindows()) do
		win:moveToScreen(projectorScreen, true)
	end

	-- darken display
	darkmode.darkenDisplay()

	-- fix layout
	movieLayout()
end

--------------------------------------------------------------------------------

-- 1. Hotkeys
hs.hotkey.bind({}, "home", workLayout)
hs.hotkey.bind({}, "end", movieLayout)

-- 2. URI (for Touchpad via BetterTouchTool)
hs.urlevent.bind("fix-projector-layout", fixProjectorLayout)

-- 3. Systemstart
if u.isSystemStart() then workLayout() end

-- 4. Waking
M.caff_unlock = hs.caffeinate.watcher
	.new(function(event)
		local wokeUp = event == hs.caffeinate.watcher.screensDidUnlock
			or event == hs.caffeinate.watcher.systemDidWake
		if wokeUp and not env.isAtOffice and not env.isProjector() then
			u.defer(0.5, function()
				local layout = env.isProjector() and movieLayout or workLayout
				layout()
			end)
		end
	end)
	:start()

--------------------------------------------------------------------------------
return M
