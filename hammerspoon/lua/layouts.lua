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

local function isWeekend()
	local weekday = tostring(os.date("%a"))
	return weekday == "Sat" or weekday == "Sun"
end

---@param targetMode string
local function dockSwitcher(targetMode)
	local script = "../../Alfred.alfredpreferences/workflows/dock-switcher/scripts/dock_switcher.sh"
	local layoutDir = "../../+ dock-layouts"
	M.task_dockSwitching = hs.task.new(script, nil, { "--load", targetMode, layoutDir }):start()
end

local function setHigherBrightnessDuringDay()
	local ambient = hs.brightness.ambient()
	local noBrightnessSensor = ambient == -1
	if noBrightnessSensor then return end

	local target
	if env.isProjector() then
		target = 0
	elseif ambient > 120 then
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

--------------------------------------------------------------------------------
-- LAYOUTS

local function workLayout()
	-- screen & visuals
	darkmode.autoSwitch()
	visuals.updateHoleCover()
	dockSwitcher("work")
	setHigherBrightnessDuringDay()
	u.closeAllTheThings()
	app("AltTab"):kill() -- FIX missing windows

	-- open
	u.openApps(env.mastodonApp)
	local appsToOpen = { "Discord", env.browserApp, "Mimestream" }
	if not isWeekend() then table.insert(appsToOpen, "Slack") end
	u.openApps(appsToOpen)
	for _, appName in pairs(appsToOpen) do
		u.whenAppWinAvailable(appName, function()
			local win = app(appName):mainWindow()
			wu.moveResize(win, wu.pseudoMax)
		end)
	end

	-- finish
	u.whenAppWinAvailable("Discord", function()
		-- FIX missing windows by restarting AltTab
		u.runWithDelays({ 3, 6 }, function()
			if not app("AltTab") then hs.application.open("AltTab") end
		end)
		app("Mimestream"):activate()
		print("🔲 Loaded WorkLayout")
	end)
end

local function movieLayout()
	dockSwitcher(env.isAtMother and "mother-movie" or "movie") -- different PWAs due to not being M1 device
	wu.iMacDisplay:setBrightness(0)
	darkmode.setDarkMode("dark")
	visuals.updateHoleCover()

	u.openApps { "YouTube", "BetterTouchTool" }
	u.closeFinderWins()
	u.quitApps {
		"neovide",
		"Slack",
		"Discord",
		"BusyCal",
		"Alfred Preferences",
		"Highlights",
		"Obsidian",
		"lo-rain",
		"WezTerm",
		"Mimestream",
		env.mastodonApp,
		"Reminders",
	}
	print("🔲 Loaded MovieModeLayout")
end

---select layout depending on number of screens, and prevent concurrent runs
local function selectLayout()
	if M.isLayouting then return end
	M.isLayouting = true
	local layout = env.isProjector() and movieLayout or workLayout
	layout()
	u.runWithDelays(4, function() M.isLayouting = false end)
end

--------------------------------------------------------------------------------
-- WHEN TO SET LAYOUT

-- 1. Change of screen numbers
M.caff_displayCount = hs.screen.watcher
	.new(function()
		u.runWithDelays(0.5, selectLayout) -- delay for recognizing screens

		u.runWithDelays(4, u.closeAllTheThing)
		-- If at night switching back to one display, put iMac display to sleep
		-- (this triggers when the projector is turned off before going to sleep)
		u.runWithDelays(8, function()
			if u.betweenTime(21, 7) and not env.isProjector() then hs.caffeinate.systemSleep() end
		end)
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
