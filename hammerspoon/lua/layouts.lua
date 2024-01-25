local M = {} -- persist from garbage collector

local darkmode = require("lua.dark-mode")
local env = require("lua.environment-vars")
local u = require("lua.utils")
local visuals = require("lua.visuals")
local wu = require("lua.window-utils")
local privatCloser = require("lua.private").closer

local wf = hs.window.filter
local hotkey = hs.hotkey.bind

--------------------------------------------------------------------------------
-- HELPERS

local function isWeekend()
	local weekday = tostring(os.date("%a"))
	return weekday == "Sat" or weekday == "Sun"
end

---@param targetMode string
local function dockSwitcher(targetMode)
	M.task_dockSwitching = hs.task
		.new("./helpers/dock-switching/dock-switcher.sh", nil, { "--load", targetMode })
		:start()
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

	-- close all the stuff
	for _, win in pairs(hs.window.allWindows()) do
		if win:isFullScreen() then win:setFullScreen(false) end
	end
	privatCloser()
	u.quitApps{"Finder", table.unpack(env.videoAndAudioApps)} -- unpack must be last

	-- open
	u.openApps(env.mastodonApp)
	local appsToOpen = { "Discord", env.browserApp, "Mimestream" }
	if not isWeekend() then table.insert(appsToOpen, "Slack") end
	u.openApps(appsToOpen)
	for _, appName in pairs(appsToOpen) do
		u.whenAppWinAvailable(appName, function()
			local win = u.app(appName):mainWindow()
			wu.moveResize(win, wu.pseudoMax)
		end)
	end

	-- restart AltTab
	if u.app("AltTab") then
		u.app("AltTab"):kill()
		M.altTabRestart = hs.timer.waitUntil(
			function() return u.app("AltTab") == nil end,
			function() hs.application.open("AltTab") end,
			0.1
		)
	end

	-- finish
	u.whenAppWinAvailable("Discord", function() u.app("Mimestream"):activate() end)
	print("🔲 Loaded WorkLayout")
end

local function movieLayout()
	dockSwitcher(env.isAtMother and "mother-movie" or "movie") -- different PWAs due to not being M1 device
	wu.iMacDisplay:setBrightness(0)
	darkmode.setDarkMode("dark")
	visuals.updateHoleCover()

	u.openApps { "YouTube", "BetterTouchTool" }
	u.quitApps {
		"neovide",
		"Slack",
		"Discord",
		"BusyCal",
		"Alfred Preferences",
		"Finder",
		"Highlights",
		"Obsidian",
		"lo-rain",
		"WezTerm",
		"Mimestream",
		env.mastodonApp,
		"GoodTask",
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

-- Open Apps always at Mouse Screen
M.wf_appsOnMouseScreen = wf.new({
	env.browserApp,
	"Mimestream",
	"GoodTask",
	"BetterTouchTool",
	"Obsidian",
	"Finder",
	"WezTerm",
	"Hammerspoon",
	"System Settings",
	"Discord",
	"neovide",
	"espanso",
	"BusyCal",
	"Alfred Preferences",
	table.unpack(env.videoAndAudioApps), -- must be last for all items to be unpacked
}):subscribe(wf.windowCreated, function(newWin)
	local mouseScreen = hs.mouse.getCurrentScreen()
	local app = newWin:application()
	local screenOfWindow = newWin:screen()
	if not (mouseScreen and env.isProjector() and app) then return end

	u.runWithDelays({ 0, 0.2 }, function()
		if mouseScreen:name() == screenOfWindow:name() then return end
		newWin:moveToScreen(mouseScreen)
		if app:name() ~= "GoodTask" then wu.moveResize(newWin, wu.maximized) end
	end)
end)

--------------------------------------------------------------------------------
-- WHEN TO SET LAYOUT

-- 1. Change of screen numbers
M.caff_displayCount = hs.screen.watcher
	.new(function()
		u.runWithDelays(0.5, selectLayout) -- delay for recognizing screens

		-- If at night switching back to one display, put iMac display to sleep
		-- (this triggers when the projector is turned off before going to sleep)
		if u.betweenTime(21, 7) and not env.isProjector() then hs.caffeinate.systemSleep() end
	end)
	:start()

-- 2. Hotkey
hotkey(u.hyper, "home", selectLayout)

-- 3. Systemstart
if u.isSystemStart() then selectLayout() end

-- 4. Waking
M.caff_unlock = hs.caffeinate.watcher
	.new(function(event)
		local hasWoken = event == hs.caffeinate.watcher.screensDidWake
			or event == hs.caffeinate.watcher.systemDidWake
			or event == hs.caffeinate.watcher.screensDidUnlock

		if hasWoken then u.runWithDelays(0.5, selectLayout) end -- delay for recognizing screens
	end)
	:start()

--------------------------------------------------------------------------------
return M
