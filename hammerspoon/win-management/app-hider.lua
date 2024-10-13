local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------

-- INFO REASONS FOR ALL THIS APP HIDING
-- 1) My workflow where I only have one display and one Space, but
-- still want to enjoy wallpapers visible through transparent apps.
-- 2) Apps should not cover up the sketchybar which I only have in the top right
-- corner.

local config = {
	transBgApps = { "Neovide", "neovide", "Obsidian", "wezterm-gui", "WezTerm" },
	disableHidingWhileActive = { "Steam" },
	dontTriggerHidingOtherApps = { "Alfred", "CleanShot X", "IINA" },
	appsNotToHide = {
		"Espanso",
		"IINA",
		"zoom.us",
		"CleanShot X",
		"Mona",
		"Alfred",
		"Karabiner-EventViewer",
	},
}
--------------------------------------------------------------------------------

-- unhide all apps
local function unHideAll()
	if u.appRunning(config.disableHidingWhileActive) then return end
	local wins = hs.window.allWindows()
	for _, win in pairs(wins) do
		local app = win:application()
		if app and app:isHidden() then app:unhide() end
	end
end

---@param appObj hs.application the app not to hide
local function hideOthers(appObj)
	-- GUARD
	if u.appRunning(config.disableHidingWhileActive) then return end
	if hs.fnutils.contains(config.dontTriggerHidingOtherApps, appObj:name()) then return end
	local thisWin = appObj and appObj:mainWindow()
	if not thisWin or not appObj:isFrontmost() then return end
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
			and not (app:name() == appObj:name())
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

-- prevent maximized window from covering sketchybar if they are unfocused
M.wf_maxWindows = wf.new(true)
	:setOverrideFilter({ allowRoles = "AXStandardWindow" })
	:subscribe(wf.windowUnfocused, function(win)
		if not win then return end
		local app = win:application()
		if
			not (env.isProjector())
			and wu.winHasSize(win, hs.layout.maximized)
			and not (u.isFront(config.dontTriggerHidingOtherApps))
			and app
		then
			app:hide()
		end
	end)

--------------------------------------------------------------------------------
return M
