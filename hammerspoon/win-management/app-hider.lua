-- INFO REASONS FOR ALL THIS APP HIDING
-- 1) My workflow where I only have one display and one Space, but
-- still want to enjoy wallpapers visible through transparent apps.
-- 2) Apps should not cover up the sketchybar which I only have in the top right
-- corner.
--------------------------------------------------------------------------------
local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------

local config = {
	transBgApps = {
		"Neovide",
		"neovide",
		"Obsidian",
		"wezterm-gui",
		"WezTerm",
	},
	dontTriggerHidingOtherApps = {
		"Alfred",
		"CleanShot X",
		"IINA",
		"pinentry-mac",
		"Catch",
	},
	appsNotToHide = {
		"Espanso",
		"IINA",
		"zoom.us",
		"CleanShot X",
		"Ivory",
		"Alfred",
		"Karabiner-EventViewer",
		"pinentry-mac",
	},
	disableHidingWhileActive = {
		"Steam",
	},
}

--------------------------------------------------------------------------------

local function unHideAll()
	if u.appRunning(config.disableHidingWhileActive) then return end
	local wins = hs.window.allWindows()
	for _, win in pairs(wins) do
		local app = win:application()
		if app and app:isHidden() then app:unhide() end
	end
end

---@param notToHideApp hs.application
local function hideOthers(notToHideApp)
	-- GUARD
	if u.appRunning(config.disableHidingWhileActive) then return end
	if hs.fnutils.contains(config.dontTriggerHidingOtherApps, notToHideApp:name()) then return end
	local thisWin = notToHideApp and notToHideApp:mainWindow()
	if not thisWin or not notToHideApp:isFrontmost() then return end
	if not (wu.winHasSize(thisWin, wu.pseudoMax) or wu.winHasSize(thisWin, hs.layout.maximized)) then
		return
	end

	for _, w in pairs(thisWin:otherWindowsSameScreen()) do
		local app = w:application()
		-- GUARD exclude some apps, PiP windows, and other windows of the same app
		if
			app
			and not (app:findWindow("Picture in Picture"))
			and not (hs.fnutils.contains(config.appsNotToHide, app:name()))
			and not (app:name() == notToHideApp:name())
			and not app:isHidden()
		then
			app:hide()
		end
	end
end

--------------------------------------------------------------------------------

-- if an app with bg-transparency is activated, hide all other apps
-- if an app is terminated, unhide them again
M.transBgAppWatcher = aw.new(function(appName, event, appObj)
	if env.isProjector() then return end
	if event == aw.terminated then
		if appName == "Reminders" then return end -- Reminders opening in bg for scripts
		unHideAll()
	elseif event == aw.activated and hs.fnutils.contains(config.transBgApps, appName) then
		-- defer to prevent race condition with termination above
		u.whenAppWinAvailable(appObj:name(), function() hideOthers(appObj) end)
	end
end):start()

-- also trigger on minimization and on window resizing
M.transBgAppWindowFilter = wf.new(config.transBgApps)
	:setOverrideFilter({ allowRoles = "AXStandardWindow" })
	:subscribe(wf.windowMoved, function(movedWin) hideOthers(movedWin:application()) end)
	:subscribe(wf.windowMinimized, unHideAll)

--------------------------------------------------------------------------------

-- prevent maximized window from covering sketchybar if they are unfocused
M.aw_maxWindows = aw.new(function(_appName, event, app)
	if
		event == aw.deactivated
		and not (env.isProjector())
		and not (u.isFront(config.dontTriggerHidingOtherApps))
	then
		local allWins = app:allWindows()
		local hasCoveringWin = hs.fnutils.some(app:allWindows(), function(win)
			local maximized = wu.winHasSize(win, hs.layout.maximized)
			local leftHalf = wu.winHasSize(win, hs.layout.left50)
			return maximized or leftHalf
		end)
		local hasLikelyCoveringWin = #allWins > 2

		if hasCoveringWin or hasLikelyCoveringWin then app:hide() end
	end
end):start()

--------------------------------------------------------------------------------
return M
