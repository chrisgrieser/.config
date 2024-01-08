local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter

--------------------------------------------------------------------------------

-- INFO - REASONS FOR ALL THIS APP HIDING
-- 1) my workflow where I only have one display and one space, but
-- still want to enjoy wallpapers visible through transparent apps
-- 2) apps should not cover up the sketchybar that I only have in the top right
-- corner

local config = {
	transBgApps = { "neovide", "Neovide", "Obsidian", "wezterm-gui", "WezTerm" },
	dontTriggerHidingOtherApps = { "Alfred", "CleanShot X", "IINA", "Shottr" },
	appsNotToHide = {
		"Espanso",
		"IINA",
		"zoom.us",
		"CleanShot X",
		"Ivory",
		"Alfred",
		"Shottr",
	},
}
--------------------------------------------------------------------------------

-- unhide all apps
local function unHideAll()
	local wins = hs.window.allWindows()
	for _, win in pairs(wins) do
		local app = win:application()
		if app and app:isHidden() then app:unhide() end
	end
end

-- hide other apps, except twitter, Zoom, or PiP apps
---@param appObj hs.application the app not to hide
local function hideOthers(appObj)
	if
		not appObj
		or not appObj:mainWindow()
		or not appObj:isFrontmost() -- check if win switched in meantime
	then
		return
	end
	local thisWin = appObj:mainWindow()
	local thisAppName = appObj:name()

	-- only hide when bigger window
	if not (wu.CheckSize(thisWin, wu.pseudoMax) or wu.CheckSize(thisWin, wu.maximized)) then
		return
	end

	for _, w in pairs(thisWin:otherWindowsSameScreen()) do
		local app = w:application()
		if
			app
			and not (app:findWindow("Picture in Picture"))
			and not (u.tbl_contains(config.appsNotToHide, app:name()))
			and not (app:name() == thisAppName)
			and not (app:isHidden())
		then
			app:hide()
		end
	end
end

--------------------------------------------------------------------------------

-- if an app with bg-transparency is activated, hide all other apps
-- if such an app is terminated, unhide them again
M.transBgAppWatcher = aw.new(function(appName, event, appObj)
	if env.isProjector() then return end
	if event == aw.terminated then
		if appName == "Reminders" then return end -- Reminders often opening in the background
		unHideAll()
	elseif event == aw.activated and u.tbl_contains(config.transBgApps, appName) then
		u.whenAppWinAvailable(appName, function() hideOthers(appObj) end)
	end
end):start()

-- also trigger on minimization and on window reszing
M.transBgAppWindowFilter = wf.new(config.transBgApps)
	:subscribe(wf.windowMoved, function(movedWin) hideOthers(movedWin:application()) end)
	:subscribe(wf.windowMinimized, unHideAll)

-- when currently auto-tiled, hide the app on deactivation so it does not cover sketchybar
M.autoTileAppWatcher = aw.new(function(appName, eventType, appObj)
	local autoTileApps = { "Finder", env.browserApp }
	if
		eventType == aw.deactivated
		and u.tbl_contains(autoTileApps, appName)
		and #(appObj:allWindows()) > 1
		and not (appObj:findWindow("Picture in Picture"))
		and not (appObj:findWindow("^$")) -- special windows?
		and not (env.isProjector())
		and not (u.isFront(config.dontTriggerHidingOtherApps))
	then
		appObj:hide()
	end
end):start()

-- prevent maximized window from covering sketchybar if they are unfocused
M.wf_maxWindows = wf.new(true):subscribe(wf.windowUnfocused, function(win)
	if
		not (env.isProjector())
		and wu.CheckSize(win, wu.maximized)
		and not (u.isFront(config.dontTriggerHidingOtherApps))
	then
		win:application():hide()
	end
end)

--------------------------------------------------------------------------------
return M
