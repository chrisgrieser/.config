local M = {} -- persist from garbage collector

local u = require("meta.utils")
local wu = require("win-management.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter

---ZOOM-------------------------------------------------------------------------
-- 1. remove leftover tabs
-- 2. close unneeded windows when entering meeting
M.wf_zoom = wf.new("zoom.us"):subscribe(wf.windowCreated, function(newWin)
	u.closeBrowserTabsWith("zoom.us")

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

---PDF READERS------------------------------------------------------------------
-- 1. Sync Dark & Light Mode
-- 2. Start with Highlight Tool enabled
-- 3. Delete useless iCloud PDF folder that's always created
M.aw_pdfreaders = aw.new(function(appName, event, app)
	if event == aw.launched and appName == "Highlights" then
		app:selectMenuItem { "View", "PDF Appearance", u.isDarkMode() and "Night" or "Default" }
		app:selectMenuItem { "Tools", "Highlight" }
		app:selectMenuItem { "Tools", "Color", "Yellow" }
	elseif event == aw.launched and appName == "PDF Expert" then
		app:selectMenuItem { "View", "Theme", u.isDarkMode() and "Night" or "Day" }
		app:selectMenuItem { "Annotate", "Highlight" }

		local shellCmd =
			'rm -rf "$HOME/Library/Mobile Documents/3L68KQB4HG~com~readdle~CommonDocuments/Documents/"'
		hs.execute(shellCmd)
	end
end):start()

---SCRIPT EDITOR----------------------------------------------------------------
-- 1. on open, paste, and format
-- 2. fix copypasting line breaks into other apps
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
-- 1. auto-close media windows
-- 2. auto-scroll up
M.aw_masto = aw.new(function(appName, event, masto)
	if appName ~= "Mona" then return end
	local win = masto:mainWindow()
	if not win then return end

	if event == aw.activated or event == aw.launched then
		wu.moveResize(win, wu.toTheSide)
	elseif event == aw.deactivated then
		local isMediaWin = win:title():find("^Image")
		local frontNotAlfred = hs.application.frontmostApplication():name() ~= "Alfred"
		if #masto:allWindows() > 1 and isMediaWin and frontNotAlfred then win:close() end
	end

	u.defer(1, function()
		if M.mastoHasScrolled then return end
		M.mastoHasScrolled = true
		hs.eventtap.keyStroke({}, "left", 1, masto) -- go back
		hs.eventtap.keyStroke({ "cmd" }, "1", 1, masto) -- go to home tab
		hs.eventtap.keyStroke({ "cmd" }, "up", 1, masto) -- scroll up
	end)
	u.defer(2, function() M.mastoHasScrolled = false end)
end):start()

---BROWSER----------------------------------------------------------------------
-- remove `?tab=readme-ov-file` from github URLs
M.aw_browser = aw.new(function(appName, event, _app)
	if appName == "Brave Browser" and event == aw.deactivated then
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end
		clipb = clipb:gsub("(https://github%.com/.*)%?tab=readme%-ov%-file(#.*)", "%1%2")
		hs.pasteboard.setContents(clipb)
	end
end):start()

---ALFRED-----------------------------------------------------------------------
-- 1. Brave bookmarks synced to chrome bookmarks (so Alfred can pick up them up w/o keyword)
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

-- 2. Reminders Today workflow
-- -> clear cache when leaving Calendar, since events might have changed
M.aw_calendar = aw.new(function(appName, event, _app)
	if (event == aw.deactivated or event == aw.terminated) and appName == "Calendar" then
		local cachePath = os.getenv("HOME")
			.. "/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data/de.chris-grieser.reminders-companion/events-from-swift.json"
		os.remove(cachePath)
	end
end):start()

--------------------------------------------------------------------------------
return M
