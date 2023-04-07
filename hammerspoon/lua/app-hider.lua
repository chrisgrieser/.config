-- INFO reasons for all this app hiding
-- 1) my workflow where I only have one display and one space, but
-- still want to enjoy wallpapers visible through transparent apps
-- 2) apps should not cover up the sketchybar that I only have in the top right
-- corner

require("lua.utils")
require("lua.window-utils")
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
		or not IsFront(appObj:name()) -- win not switched in meantime
	then
		return
	end
	local thisWin = appObj:mainWindow()

	-- only hide when bigger window
	if not (CheckSize(thisWin, PseudoMaximized) or CheckSize(thisWin, Maximized)) then return end

	local appsNotToHide =
		{ "IINA", "zoom.us", "CleanShot X", "SideNotes", "Twitter", "Alfred", appObj:name() }
	for _, w in pairs(thisWin:otherWindowsSameScreen()) do
		local app = w:application()
		if
			app
			and not (app:findWindow("Picture in Picture"))
			and not (TableContains(appsNotToHide, app:name()))
			and not (app:isHidden())
		then
			app:hide()
		end
	end
end

--------------------------------------------------------------------------------

-- if an app with bg-transparency is activated, hide all other apps
-- if such an app is terminated, unhide them again
TransBgAppWatcher = Aw.new(function(appName, event, appObj)
	local transBgApp = { "neovide", "Neovide", "Obsidian", "wezterm-gui", "WezTerm" }
	if IsProjector() or not (TableContains(transBgApp, appName)) then return end

	if event == Aw.terminated then
		unHideAll()
	elseif event == Aw.activated then
		hideOthers(appObj)
		AsSoonAsAppRuns(appObj, function() hideOthers(appObj) end)
	end
end):start()

-- extra run for neovide startup necessary, since they do not send a
-- launch signal and also the `AsSoonAsAppRuns` condition does not work well.
-- in addition, `RunDelayed` also does not work well due to varying startup
-- times. Therefore, this UriScheme is called on neovim startup in
-- config/gui-settings.lua
UriScheme("hide-other-than-neovide", function()
	RunWithDelays({ 0, 0.1, 0.2 }, function() hideOthers(App("neovide")) end)
end)

-- when currently auto-tiled, hide the app on deactivation so it does not cover sketchybar
AutoTileAppWatcher = Aw.new(function(appName, eventType, appObj)
	local autoTileApps = { "Finder", "Vivaldi" }
	if
		eventType == Aw.deactivated
		and TableContains(autoTileApps, appName)
		and #appObj:allWindows() > 1
		and not (appObj:findWindow("Picture in Picture"))
		and not (IsProjector())
		and not (IsFront { "Alfred", "SideNotes", "CleanShot X" })
	then
		appObj:hide()
	end
end):start()

-- prevent maximized window from covering sketchybar if they are unfocused
-- pseudomaximized windows always get twitter to the side
Wf_maxWindows = Wf.new(true):subscribe(Wf.windowUnfocused, function(win)
	if
		not (IsProjector())
		and CheckSize(win, Maximized)
		and not (IsFront { "Alfred", "SideNotes", "CleanShot X" })
	then
		win:application():hide()
	end
end)
