local darkmode = require("lua.dark-mode")
local env = require("lua.environment-vars")
local sidenotes = require("lua.sidenotes")
local u = require("lua.utils")
local visuals = require("lua.visuals")
local wu = require("lua.window-utils")
--------------------------------------------------------------------------------

-- HELPERS

---@param targetMode string
local function dockSwitcher(targetMode)
	hs.execute("zsh ./helpers/dock-switching/dock-switcher.sh --load " .. targetMode)
end

local function setHigherBrightnessDuringDay()
	local ambient = hs.brightness.ambient()
	local noBrightnessSensor = ambient == -1
	if noBrightnessSensor then return end

	local target
	if u.betweenTime(0, 7) or env.isProjector() then -- when turning off projector at night
		target = 0
	elseif ambient > 120 then
		target = 1
	elseif ambient > 90 then
		target = 0.9
	elseif ambient > 30 then
		target = 0.8
	elseif ambient > 15 then
		target = 0.7
	else
		target = 0.6
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
	u.quitApp { "YouTube", "Netflix", "CrunchyRoll", "IINA", "Twitch", "lo-rain", "BetterTouchTool" }
	require("lua.private").closer()
	closeAllFinderWins()

	-- open
	local appsToOpen = { "Discord", env.browserApp, env.mailApp, "Twitter", "Slack" }
	u.openApps(appsToOpen)
	for _, appName in pairs(appsToOpen) do
		u.asSoonAsAppRuns(appName, function()
			local win = u.app(appName):mainWindow()
			wu.moveResize(win, wu.pseudoMax)
		end)
	end

	-- finish
	sidenotes.reminderToSidenotes()
	u.asSoonAsAppRuns("Discord", function() u.app(env.mailApp):activate() end)
	print("🔲 WorkLayout: done")
end

local function movieLayout()
	print("🔲 MovieLayout: loading")
	local targetMode = env.isAtMother and "mother-movie" or "movie" -- different PWAs due to not being M1 device
	dockSwitcher(targetMode)
	wu.iMacDisplay:setBrightness(0)
	darkmode.set(true)
	visuals.holeCover("remove")

	u.openApps { "YouTube", "BetterTouchTool" }
	u.quitApp {
		"Neovide",
		"lo-rain",
		"neovide",
		"Slack",
		"Discord",
		"BusyCal",
		env.mailApp,
		"Alfred Preferences",
		"Finder",
		"Highlights",
		"Twitter",
		"Obsidian",
	}
	print("🔲 MovieModeLayout: done")
end

---select layout depending on number of screens, and prevent concurrent runs
local function selectLayout()
	if LayoutingInProgress then return end
	LayoutingInProgress = true
	if env.isProjector() then
		movieLayout()
	else
		workLayout()
	end
	u.runWithDelays(5, function() LayoutingInProgress = false end)
end

--------------------------------------------------------------------------------
-- WHEN TO SET LAYOUT

-- 1. Change of screen numbers
DisplayCountWatcher = hs.screen.watcher
	.new(function()
		local delay = env.isAtMother and 1.5 or 0 -- TV at mother needs small delay
		u.runWithDelays(delay, selectLayout)
	end)
	:start()

-- 2. Hotkey
u.hotkey(u.hyper, "home", selectLayout)

-- 3. Systemstart
if not u.isReloading() then selectLayout() end

-- 4. Waking
local c = hs.caffeinate.watcher
UnlockWatcher = c.new(function(event)
	local hasWoken = event == c.screensDidWake or event == c.systemDidWake or event == c.screensDidUnlock

	print("🔓 Wake")
	if hasWoken then u.runWithDelays(0.5, selectLayout) end -- delay for recognizing screens
end):start()
