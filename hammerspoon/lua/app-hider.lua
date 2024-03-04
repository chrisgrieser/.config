local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------

-- INFO - REASONS FOR ALL THIS APP HIDING
-- 1) My workflow where I only have one display and one Space, but
-- still want to enjoy wallpapers visible through transparent apps.
-- 2) Apps should not cover up the sketchybar that I only have in the top right
-- corner.

local config = {
	transBgApps = env.transBgApps,
	dontTriggerHidingOtherApps = { "Alfred", "CleanShot X", "IINA", "Shottr" },
	appsNotToHide = {
		"Espanso",
		"IINA",
		"zoom.us",
		"CleanShot X",
		env.mastodonApp,
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
	-- GUARD current app having no window
	if
		not appObj
		or not appObj:mainWindow()
		or not appObj:isFrontmost() -- check if win switched in meantime
	then
		return
	end
	local thisWin = appObj:mainWindow()
	local thisAppName = appObj:name()

	-- GUARD current window not being big enough
	if not (wu.checkSize(thisWin, wu.pseudoMax) or wu.checkSize(thisWin, wu.maximized)) then
		return
	end

	for _, w in pairs(thisWin:otherWindowsSameScreen()) do
		local app = w:application()
		-- GUARD exclude some apps, PiP windows, and other windows of the same app
		if
			app
			and not (app:findWindow("Picture in Picture"))
			and not (hs.fnutils.contains(config.appsNotToHide, app:name()))
			and not (app:name() == thisAppName)
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
		if appName == "Reminders" then return end -- Reminders opening in bg for scripts
		unHideAll()
	elseif event == aw.activated and hs.fnutils.contains(config.transBgApps, appName) then
		u.whenAppWinAvailable(appName, function() hideOthers(appObj) end)
	end
end):start()

-- FIX that Hammerspoon console does not trigger application-deactivated
M.wf_hsConsoleHider = wf.new("Hammerspoon"):subscribe(wf.windowUnfocused, function(win)
	if win:title() == "Hammerspoon Console" then hs.application("Hammerspoon"):hide() end
end)

-- also trigger on minimization and on window reszing
M.transBgAppWindowFilter = wf.new(config.transBgApps)
	:subscribe(wf.windowMoved, function(movedWin) hideOthers(movedWin:application()) end)
	:subscribe(wf.windowMinimized, unHideAll)

-- when currently auto-tiled, hide the app on deactivation so it does not cover sketchybar
M.autoTileAppWatcher = aw.new(function(appName, eventType, appObj)
	local autoTileApps = { "Finder", env.browserApp }
	if
		eventType == aw.deactivated
		and hs.fnutils.contains(autoTileApps, appName)
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
	if not win then return end
	local app = win:application()
	if
		not (env.isProjector())
		and wu.checkSize(win, wu.maximized)
		and not (u.isFront(config.dontTriggerHidingOtherApps))
		and app
	then
		app:hide()
	end
end)

--------------------------------------------------------------------------------
return M
