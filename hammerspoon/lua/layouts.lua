local darkmode = require("lua.dark-mode")
local env = require("lua.environment-vars")
local u = require("lua.utils")
local visuals = require("lua.visuals")
local wu = require("lua.window-utils")

--------------------------------------------------------------------------------
-- HELPERS

local function isWeekend()
	local weekday = tostring(os.date()):sub(1, 3)
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
	print("🔲 WorkLayout: loading")

	-- screen & visuals
	darkmode.AutoSwitch()
	visuals.holeCover()
	dockSwitcher("work")
	setHigherBrightnessDuringDay()
	hs.execute(u.exportPath .. "sketchybar --set clock popup.drawing=true")

	-- close
	u.quitApp { "YouTube", "Netflix", "CrunchyRoll", "IINA", "Twitch", "lo-rain", "Tagesschau", "Steam" }
	require("lua.private").closer()
	closeAllFinderWins()

	-- open
	local appsToOpen = { "Obsidian", "Discord", env.browserApp, env.mailApp, env.tickerApp }
	if not isWeekend() then table.insert(appsToOpen, "Slack") end
	u.openApps(appsToOpen)
	for _, appName in pairs(appsToOpen) do
		u.whenAppWinAvailable(appName, function()
			local win = u.app(appName):mainWindow()
			wu.moveResize(win, wu.pseudoMax)
		end)
	end

	hs.application("Obsidian")
	-- minimize Obsidian
	u.whenAppRuns("Obsidian", function() u.app("Obsidian"):mainWindow():minimize() end)
	u.restartApp("AltTab")

	-- finish
	require("lua.sidenotes").reminderToSidenotes()
	u.whenAppWinAvailable("Discord", function() u.app(env.mailApp):activate() end)
	print("🔲 WorkLayout: done")
end

local function movieLayout()
	print("🔲 MovieLayout: loading")
	local targetMode = env.isAtMother and "mother-movie" or "movie" -- different PWAs due to not being M1 device
	dockSwitcher(targetMode)
	wu.iMacDisplay:setBrightness(0)
	darkmode.set(true)
	visuals.holeCover("remove")

	u.openApps("YouTube")
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
	}
	print("🔲 MovieModeLayout: done")
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
Wf_appsOnMouseScreen = u.wf
	.new({
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
	})
	:subscribe(u.wf.windowCreated, function(newWin)
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
		local delay = env.isAtMother and 1.5 or 0 -- TV at mother needs small delay
		u.runWithDelays(delay, selectLayout)

		-- if at night switching back to one display, put iMac display to sleep at
		-- night, i.e., this triggers when the projector is turned off before
		-- going to sleep
		if u.betweenTime(22, 7) and not env.isProjector() then hs.execute("pmset displaysleepnow") end
	end)
	:start()

-- 2. Hotkey
u.hotkey(u.hyper, "home", selectLayout)

-- 3. Systemstart
if not u.isReloading() then selectLayout() end

-- 4. Waking
local c = hs.caffeinate.watcher
UnlockWatcher = c.new(function(event)
	if RecentlyWoke then return end
	RecentlyWoke = true
	local hasWoken = event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock

	print("🔓 Wake")
	if hasWoken then u.runWithDelays(0.5, selectLayout) end -- delay for recognizing screens
	u.runWithDelays(3, function() RecentlyWoke = false end)
end):start()
