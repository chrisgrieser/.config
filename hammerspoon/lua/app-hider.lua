-- INFO - REASONS FOR ALL THIS APP HIDING
-- 1) my workflow where I only have one display and one space, but
-- still want to enjoy wallpapers visible through transparent apps
-- 2) apps should not cover up the sketchybar that I only have in the top right
-- corner

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wf = require("lua.utils").wf
local aw = require("lua.utils").aw
local wu = require("lua.window-utils")

local transBgApps = { "neovide", "Neovide", "Obsidian", "wezterm-gui", "WezTerm" }
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

	-- only hide when bigger window
	if not (wu.CheckSize(thisWin, wu.pseudoMax) or wu.CheckSize(thisWin, wu.maximized)) then return end

	local appsNotToHide =
		{ "IINA", "zoom.us", "CleanShot X", "SideNotes", env.tickerApp, "Alfred", appObj:name() }
	for _, w in pairs(thisWin:otherWindowsSameScreen()) do
		local app = w:application()
		if
			app
			and not (app:findWindow("Picture in Picture"))
			and not (u.tbl_contains(appsNotToHide, app:name()))
			and not (app:isHidden())
		then
			app:hide()
		end
	end
end

--------------------------------------------------------------------------------

-- if an app with bg-transparency is activated, hide all other apps
-- if such an app is terminated, unhide them again
TransBgAppWatcher = aw.new(function(appName, event, appObj)
	if env.isProjector() then return end
	if event == aw.terminated then
		unHideAll()
	elseif event == aw.activated and u.tbl_contains(transBgApps, appName) then
		u.asSoonAsAppRuns(appName, function() hideOthers(appObj) end)
	end
end):start()

-- also trigger on window resizing events
Wf_transBgAppWindowFilter = wf.new(transBgApps):subscribe(
	wf.windowMoved,
	function(movedWin) hideOthers(movedWin:application()) end
)

-- extra run for neovide startup necessary, since they do not send a
-- launch signal and also the `AsSoonAsAppRuns` condition does not work well.
-- in addition, `RunDelayed` also does not work well due to varying startup
-- times. Therefore, this UriScheme is called on neovim startup in
-- config/gui-settings.lua
u.urischeme("hide-other-than-neovide", function()
	u.runWithDelays({ 0, 0.1, 0.2 }, function() hideOthers(u.app("neovide")) end)
end)

-- when currently auto-tiled, hide the app on deactivation so it does not cover sketchybar
AutoTileAppWatcher = aw.new(function(appName, eventType, appObj)
	local autoTileApps = { "Finder", env.browserApp }
	if
		eventType == aw.deactivated
		and u.tbl_contains(autoTileApps, appName)
		and #appObj:allWindows() > 1
		and not (appObj:findWindow("Picture in Picture"))
		and not (env.isProjector())
		and not (u.isFront { "Alfred", "SideNotes", "CleanShot X", "IINA" })
	then
		appObj:hide()
	end
end):start()

-- prevent maximized window from covering sketchybar if they are unfocused
Wf_maxWindows = wf.new(true):subscribe(wf.windowUnfocused, function(win)
	if
		not (env.isProjector())
		and wu.CheckSize(win, wu.maximized)
		and not (u.isFront { "Alfred", "SideNotes", "CleanShot X", "IINA" })
	then
		win:application():hide()
	end
end)
