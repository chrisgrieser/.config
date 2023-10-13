local darkmode = require("lua.dark-mode")
local env = require("lua.environment-vars")
local u = require("lua.utils")
local visuals = require("lua.visuals")
local wu = require("lua.window-utils")
local wf = hs.window.filter

--------------------------------------------------------------------------------
-- HELPERS

local function isWeekend()
	local weekday = tostring(os.date("%a"))
	return weekday == "Sat" or weekday == "Sun"
end

---@param targetMode string
local function dockSwitcher(targetMode)
	DockSwitchingTask = hs.task
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

local function closeAllFinderWins()
	local finder = u.app("Finder")
	if not finder then return end
	for _, win in pairs(finder:allWindows()) do
		win:close()
	end
end

--------------------------------------------------------------------------------
-- LAYOUTS

local function workLayout()
	-- screen & visuals
	darkmode.autoSwitch()
	visuals.holeCover("auto")
	dockSwitcher("work")
	setHigherBrightnessDuringDay()

	-- close
	closeAllFinderWins()
	u.quitApps(env.videoAndAudioApps)
	require("lua.private").closer()

	-- open
	u.openApps("Tot")
	local appsToOpen = { "Discord", env.browserApp, env.mailApp, env.tickerApp }
	if not isWeekend() then table.insert(appsToOpen, "Slack") end
	u.openApps(appsToOpen)
	for _, appName in pairs(appsToOpen) do
		u.whenAppWinAvailable(appName, function()
			local win = u.app(appName):mainWindow()
			wu.moveResize(win, wu.pseudoMax)
		end)
	end
	u.restartApp("AltTab") -- FIX duplicate items

	-- finish
	u.whenAppWinAvailable("Discord", function() u.app(env.mailApp):activate() end)
	print("🔲 Loaded WorkLayout")
end

local function movieLayout()
	dockSwitcher(env.isAtMother and "mother-movie" or "movie") -- different PWAs due to not being M1 device
	wu.iMacDisplay:setBrightness(0)
	darkmode.setDarkMode("dark")
	visuals.holeCover("remove")

	u.openApps { "YouTube", "BetterTouchTool" }
	u.quitApps {
		"Tot",
		"neovide",
		"Slack",
		"Discord",
		"BusyCal",
		"Alfred Preferences",
		"Finder",
		"Highlights",
		"Obsidian",
		"lo-rain",
		env.mailApp,
		env.tickerApp,
	}
	print("🔲 Loaded MovieModeLayout")
end

---select layout depending on number of screens, and prevent concurrent runs
local isLayouting
local function selectLayout()
	if isLayouting then return end
	isLayouting = true
	local layout = env.isProjector() and movieLayout or workLayout
	layout()
	u.runWithDelays(1.5, function() isLayouting = false end)
end

--------------------------------------------------------------------------------

-- Open Apps always at Mouse Screen
Wf_appsOnMouseScreen = wf.new({
	env.browserApp,
	env.mailApp,
	"BetterTouchTool",
	"Obsidian",
	"Finder",
	"ReadKit",
	"Slack",
	"Tot",
	"IINA",
	"WezTerm",
	"Hammerspoon",
	"System Settings",
	"Discord",
	"Neovide",
	"neovide",
	"Espanso",
	"espanso",
	"BusyCal",
	"Alfred Preferences",
	"YouTube",
	"Netflix",
	"CrunchyRoll",
}):subscribe(wf.windowCreated, function(newWin)
	local mouseScreen = hs.mouse.getCurrentScreen()
	local app = newWin:application()
	local screenOfWindow = newWin:screen()
	if not (mouseScreen and env.isProjector() and app) then return end

	u.runWithDelays({ 0, 0.3 }, function()
		if mouseScreen:name() == screenOfWindow:name() then return end
		newWin:moveToScreen(mouseScreen)
		wu.moveResize(newWin, wu.maximized)
	end)
end)

--------------------------------------------------------------------------------
-- WHEN TO SET LAYOUT

-- 1. Change of screen numbers
DisplayCountWatcher = hs.screen.watcher
	.new(function()
		local delay = env.isAtMother and 1 or 0 -- TV at mother needs small delay
		u.runWithDelays(delay, selectLayout)

		-- If at night switching back to one display, put iMac display to sleep
		-- (this triggers when the projector is turned off before going to sleep)
		if u.betweenTime(21, 7) and not env.isProjector() then hs.caffeinate.systemSleep() end
	end)
	:start()

-- 2. Hotkey
u.hotkey(u.hyper, "home", selectLayout)

-- 3. Systemstart
if u.isSystemStart() then selectLayout() end

-- 4. Waking
local recentlyWoke
UnlockWatcher = hs.caffeinate.watcher
	.new(function(event)
		if recentlyWoke then return end
		recentlyWoke = true
		local hasWoken = event == hs.caffeinate.watcher.screensDidWake
			or event == hs.caffeinate.watcher.systemDidWake
			or event == hs.caffeinate.watcher.screensDidUnlock

		print("🔓 Wake")
		if hasWoken then u.runWithDelays(0.5, selectLayout) end -- delay for recognizing screens
		u.runWithDelays(3, function() recentlyWoke = false end)
	end)
	:start()
