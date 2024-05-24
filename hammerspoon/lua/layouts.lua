local M = {} -- persist from garbage collector

local darkmode = require("lua.dark-mode")
local env = require("lua.environment-vars")
local u = require("lua.utils")
local visuals = require("lua.visuals")
local wu = require("lua.window-utils")
local app = require("lua.utils").app
local c = hs.caffeinate.watcher
--------------------------------------------------------------------------------
-- HELPERS

---@param dockToUse string
local function dockSwitcher(dockToUse)
	hs.osascript.applescript(([[
		tell application id "com.runningwithcrayons.Alfred"
			run trigger "load-dock-layout" in workflow "de.chris-grieser.dock-switcher" with argument "%s"
		end tell
	]]):format(dockToUse))
end

local function setHigherBrightnessDuringDay()
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

local function isWorkweek()
	local weekday = tostring(os.date("%a"))
	return weekday ~= "Sat" and weekday ~= "Sun"
end

--------------------------------------------------------------------------------
-- LAYOUTS

local function workLayout()
	darkmode.autoSwitch()
	visuals.updateHoleCover()
	setHigherBrightnessDuringDay()
	dockSwitcher("work")
	u.closeAllTheThings()

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

	print("🔲 Loaded WorkLayout")
end

local function movieLayout()
	wu.iMacDisplay:setBrightness(0)
	darkmode.setDarkMode("dark")
	visuals.updateHoleCover()
	dockSwitcher("movie")
	u.closeFinderWins()
	-- hide all files
	hs.execute("defaults write com.apple.Finder AppleShowAllFiles false && killall Finder")

	u.openApps { "YouTube", "BetterTouchTool" }
	u.quitApps {
		"Slack",
		"Discord",
		"BusyCal",
		"Alfred Preferences",
		"Highlights",
		"Obsidian",
		"WezTerm",
		"Mimestream",
		"Neovide",
		"Mona",
		"Reminders",
	}
	print("🔲 Loaded MovieModeLayout")
end

---select layout depending on number of screens, and prevent concurrent runs
local function selectLayout()
	local maxSecsBetweenLayoutingAttempts = 5 -- CONFIG
	if M.isLayouting then return end
	M.isLayouting = true
	local layout = env.isProjector() and movieLayout or workLayout
	layout()
	u.runWithDelays(maxSecsBetweenLayoutingAttempts, function() M.isLayouting = false end)
end

--------------------------------------------------------------------------------
-- WHEN TO SET LAYOUT

-- 1. Change of screen numbers
M.caff_displayCount = hs.screen.watcher
	.new(function()
		u.runWithDelays(0.5, selectLayout) -- delay for recognizing screens

		-- If at night switching back to one display, put iMac display to sleep
		-- (this triggers when the projector is turned off before going to sleep)
		if u.betweenTime(22, 7) and not env.isProjector() and not env.isAtOffice then
			u.runWithDelays({ 0, 2, 4 }, function() wu.iMacDisplay:setBrightness(0) end)
			u.runWithDelays(4, u.closeAllTheThings)
		end
	end)
	:start()

-- 2. Hotkey
hs.hotkey.bind(u.hyper, "home", selectLayout)

-- 3. Systemstart
if u.isSystemStart() then selectLayout() end

-- 4. Waking when not in the office
M.caff_unlock = c.new(function(event)
	if event == c.systemDidWake or (event == c.screensDidUnlock and not env.isAtOffice) then
		u.runWithDelays(0.5, selectLayout)
	end
end):start()

--------------------------------------------------------------------------------
return M
