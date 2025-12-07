local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter

---FINDER-----------------------------------------------------------------------
M.aw_finder = aw.new(function(appName, event, finder)
	if event == aw.activated and appName == "Finder" then
		finder:selectMenuItem { "View", "Hide Sidebar" }
		if not env.isProjector() then finder:selectMenuItem { "View", "As List" } end
	end
end):start()

---ZOOM-------------------------------------------------------------------------
M.wf_zoom = wf.new("zoom.us"):subscribe(wf.windowCreated, function(newWin)
	u.closeBrowserTabsWith("zoom.us") -- remove leftover tabs

	local newMeetingWindow = newWin:title() == "Zoom Meeting" or newWin:title() == ""
	if newMeetingWindow then
		u.defer(2, function()
			local zoom = newWin:application()
			if not zoom or zoom:findWindow("Update") then return end
			local mainWin = zoom:findWindow("Zoom Workplace") or zoom:findWindow("Login")
			if mainWin then mainWin:close() end
		end)
	end
end)

---PDF READER-------------------------------------------------------------------
-- 1. Sync Dark & Light Mode
-- 2. Start with Highlight tool enabled
-- 3. Delete useless iCloud PDF folder that's always created
M.aw_pdfreader = aw.new(function(appName, event, app)
	if event == aw.launched and appName == "PDF Expert" then
		app:selectMenuItem { "View", "Theme", u.isDarkMode() and "Night" or "Day" }
		app:selectMenuItem { "Annotate", "Highlight" }

		local shellCmd =
			'rm -rf "$HOME/Library/Mobile Documents/3L68KQB4HG~com~readdle~CommonDocuments/Documents/"'
		hs.execute(shellCmd)
	end
end):start()

---SCRIPT EDITOR----------------------------------------------------------------
M.wf_scripteditor = wf
	.new("Script Editor")
	:subscribe(wf.windowCreated, function(newWin)
		-- paste, and format
		if newWin:title() == "Untitled" then
			hs.eventtap.keyStroke({ "cmd" }, "v")
			hs.osascript.javascript('Application("Script Editor").documents()[0].checkSyntax()')
		end
	end)
	-- fix copypasting line breaks into other apps
	:subscribe(wf.windowUnfocused, function()
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end
		clipb = clipb:gsub("\r", " \n")
		hs.pasteboard.setContents(clipb)
	end)

---MASTODON---------------------------------------------------------------------
-- auto-close any media windows
-- auto-scroll up
M.aw_masto = aw.new(function(appName, event, masto)
	if appName ~= "Mona 6" then return end
	local win = masto:mainWindow()
	if not win then return end

	if event == aw.activated or event == aw.launched then
		win:setFrame(wu.toTheSide)
	elseif event == aw.deactivated then
		local isMediaWin = win:title():find("^Image")
		local frontNotAlfred = hs.application.frontmostApplication():name() ~= "Alfred"
		if #masto:allWindows() > 1 and isMediaWin and frontNotAlfred then win:close() end

		u.defer(1, function()
			hs.eventtap.keyStroke({}, "left", 1, masto) -- go back
			hs.eventtap.keyStroke({ "cmd" }, "1", 1, masto) -- go to home tab
			hs.eventtap.keyStroke({ "cmd" }, "up", 1, masto) -- scroll up
		end)
	end
end):start()

---ALFRED-----------------------------------------------------------------------
-- bookmarks synced to chrome bookmarks (so Alfred can pick up them up w/o keyword)
do
	local chromeBookmarks = os.getenv("HOME")
		.. "/Library/Application Support/Google/Chrome/Default/Bookmarks"

	-- The pathwatcher is triggered by changes of the *target*, while this function
	-- touches the *symlink itself* due to `-h`. Thus, there is no need to affect
	-- the symlink target here.
	local function touchSymlink() hs.execute(("touch -h %q"):format(chromeBookmarks)) end

	-- sync on system start & when bookmarks are changed
	if u.isSystemStart() then touchSymlink() end
	M.pathw_bookmarks = hs.pathwatcher.new(chromeBookmarks, touchSymlink):start()
end

-- Reminders Today workflow
-- clear cache on deactivation of Calendar, since the events have potentially changed
M.aw_calendar = aw.new(function(appName, event, _app)
	if (event == aw.deactivated or event == aw.terminated) and appName == "Calendar" then
		local cachePath = os.getenv("HOME")
			.. "/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data/de.chris-grieser.reminders-companion/events-from-swift.json"
		os.remove(cachePath)
	end
end):start()

--------------------------------------------------------------------------------
return M
