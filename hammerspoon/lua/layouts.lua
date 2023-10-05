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
	hs.execute("zsh ./helpers/dock-switching/dock-switcher.sh --load " .. targetMode)
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
	darkmode.AutoSwitch()
	visuals.holeCover()
	dockSwitcher("work")
	setHigherBrightnessDuringDay()

	-- close
	closeAllFinderWins()
	u.quitApp(env.videoAndAudioApps)
	require("lua.private").closer()

	-- open
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
	local targetMode = env.isAtMother and "mother-movie" or "movie" -- different PWAs due to not being M1 device
	dockSwitcher(targetMode)
	wu.iMacDisplay:setBrightness(0)
	darkmode.set(true)
	visuals.holeCover("remove")

	u.openApps { "YouTube", "BetterTouchTool" }
	u.quitApp {
		"neovide",
		"Slack",
		"Discord",
		"BusyCal",
		env.mailApp,
		"Alfred Preferences",
		"Finder",
		"Highlights",
		env.tickerApp,
		"Obsidian",
		"lo-rain",
	}
	print("🔲 Loaded MovieModeLayout")
end

---select layout depending on number of screens, and prevent concurrent runs
local function selectLayout()
	if IsLayouting then return end
	IsLayouting = true
	if env.isProjector() then
		movieLayout()
	else
		workLayout()
	end
	u.runWithDelays(1, function() IsLayouting = false end)
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
		if u.betweenTime(22, 7) and not env.isProjector() then hs.caffeinate.systemSleep() end
	end)
	:start()

-- 2. Hotkey
u.hotkey(u.hyper, "home", selectLayout)

-- 3. Systemstart
if u.isSystemStart() then selectLayout() end

-- 4. Waking
local recentlyWoke
local c = hs.caffeinate.watcher
UnlockWatcher = c.new(function(event)
	if recentlyWoke then return end
	recentlyWoke = true
	local hasWoken = event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock

	print("🔓 Wake")
	if hasWoken then u.runWithDelays(0.5, selectLayout) end -- delay for recognizing screens
	u.runWithDelays(3, function() recentlyWoke = false end)
end):start()
