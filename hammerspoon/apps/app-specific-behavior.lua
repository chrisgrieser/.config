local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------
-- FINDER

M.aw_finder = aw.new(function(appName, event, finder)
	if event == aw.activated and appName == "Finder" then
		finder:selectMenuItem { "View", "Hide Sidebar" }
		if not env.isProjector() then finder:selectMenuItem { "View", "As List" } end
	end
end):start()

--------------------------------------------------------------------------------
-- ZOOM

M.wf_zoom = wf.new("zoom.us"):subscribe(wf.windowCreated, function(newWin)
	u.closeBrowserTabsWith("zoom.us") -- remove leftover tabs

	-- close 2nd zoom window when joining a meeting
	if newWin:title() == "Zoom Meeting" then
		u.defer(1, function()
			local zoom = newWin:application()
			if not zoom or zoom:findWindow("Update") then return end
			local mainWin = zoom:findWindow("Zoom Workplace") or zoom:findWindow("Login")
			if mainWin then mainWin:close() end
		end)
	end
end)

--------------------------------------------------------------------------------
-- HIGHLIGHTS / PDF READER

-- - Sync Dark & Light Mode
-- - Start with Highlight Tool enabled
M.aw_highlights = aw.new(function(appName, event, app)
	if event == aw.launched and appName == "Highlights" then
		app:selectMenuItem { "View", "PDF Appearance", u.isDarkMode() and "Night" or "Default" }
		app:selectMenuItem { "Tools", "Highlight" }
		app:selectMenuItem { "Tools", "Color", "Yellow" }
		app:selectMenuItem { "View", "Hide Toolbar" }
	end
end):start()

--------------------------------------------------------------------------------
-- SCRIPT EDITOR

M.wf_scripteditor = wf
	.new("Script Editor")
	:subscribe(wf.windowCreated, function(newWin)
		-- skip new file creation dialog
		if newWin:title() == "Open" then
			hs.osascript.applescript('tell application "Script Editor" to make new document')

		-- resize window, paste, and format
		elseif newWin:title() == "Untitled" then
			wu.moveResize(newWin, wu.middleHalf)
			hs.eventtap.keyStroke({ "cmd" }, "v")
			hs.osascript.javascript('Application("Script Editor").documents()[0].checkSyntax()')

		--if it's an AppleScript Dictionary, just resize window
		elseif newWin:title():find("%.sdef$") then
			wu.moveResize(newWin, wu.middleHalf)
		end
	end)
	-- fix copypasting line breaks into other apps
	:subscribe(wf.windowUnfocused, function()
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end
		clipb = clipb:gsub("\r", " \n")
		hs.pasteboard.setContents(clipb)
	end)

--------------------------------------------------------------------------------
-- TEXTEDIT
M.wf_textedit = wf.new("TextEdit"):subscribe(wf.windowCreated, function(newWin)
	-- skip new file creation dialog
	if newWin:title() == "Open" then
		hs.osascript.applescript('tell application "TextEdit" to make new document')

	-- resize window
	else
		wu.moveResize(newWin, wu.middleHalf)
	end
end)

--------------------------------------------------------------------------------
-- MIMESTREAM

-- 1st window = mail-list window => pseudo-maximized for more space
-- 2nd window = message-composing window => centered for narrower line length
M.wf_mimestream = wf.new("Mimestream")
	:setOverrideFilter({ rejectTitles = { "^Software Update$" } })
	:subscribe(wf.windowCreated, function(newWin)
		local mimestream = u.app("Mimestream")
		if not mimestream then return end
		local winCount = #mimestream:allWindows()
		local narrow = { x = 0.184, y = 0, w = 0.45, h = 1 } -- for shorter line width
		local basesize = env.isProjector() and hs.layout.maximized or wu.pseudoMax
		local newSize = winCount > 1 and narrow or basesize
		wu.moveResize(newWin, newSize)
	end)

--------------------------------------------------------------------------------
-- MASTODON (IVORY)

M.aw_masto = aw.new(function(appName, event, masto)
	if appName ~= "Ivory" then return end

	if event == aw.deactivated then
		-- close any media windows
		local mediaWinName = "Ivory"
		local isMediaWin = masto:mainWindow():title() == mediaWinName
		local frontNotAlfred = hs.application.frontmostApplication():name() ~= "Alfred"
		if #masto:allWindows() > 1 and isMediaWin and frontNotAlfred then
			hs.eventtap.keyStroke({ "cmd" }, "w", 1, masto) -- hotkey, since `:close()` doesn't work
		end

		-- back to home & scroll up
		u.defer(2, function() -- deferred to wait for potential media win to be closed
			if #masto:allWindows() ~= 1 then return end
			hs.eventtap.keyStroke({}, "left", 1, masto) -- go back
			hs.eventtap.keyStroke({ "cmd" }, "1", 1, masto) -- go to home tab
			hs.eventtap.keyStroke({ "cmd" }, "up", 1, masto) -- scroll up
		end)
	end
end):start()

local c = hs.caffeinate.watcher
M.systemw_mastodon = c.new(function(event)
	if event == c.screensaverDidStop or event == c.screensDidWake or event == c.systemDidWake then
		local masto = u.app("Ivory")
		local mastoWin = masto and u.app("Ivory"):mainWindow()
		if not mastoWin then return end
		mastoWin:setFrame(wu.toTheSide) -- needs setFrame to hide part to the side
	end
end):start()

--------------------------------------------------------------------------------
-- BRAVE BROWSER

-- BOOKMARKS SYNCED TO CHROME BOOKMARKS
-- so Alfred can pick up the Bookmarks without extra keyword

local chromeBookmarks = os.getenv("HOME")
	.. "/Library/Application Support/Google/Chrome/Default/Bookmarks"

-- The pathwatcher is triggered by changes of the *target*, while this function
-- touches the *symlink itself* due to `-h`. Thus, there is no need to affect
-- the symlink target here.
local function touchSymlink() hs.execute(("touch -h %q"):format(chromeBookmarks)) end

-- sync on system start & when bookmarks are changed
if u.isSystemStart() then touchSymlink() end
M.pathw_bookmarks = hs.pathwatcher.new(chromeBookmarks, touchSymlink):start()

--------------------------------------------------------------------------------

-- ALFRED Reminders Today workflow

-- clear cache on deactivation of Calendar, since the events have potentially changed
M.aw_calendar = aw.new(function(appName, event, _app)
	if (event == aw.deactivated or event == aw.terminated) and appName == "Calendar" then
		local cachePath = os.getenv("HOME")
			.. "/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data/de.chris-grieser.reminders-companion/events.json"
		os.remove(cachePath)
	end
end):start()

--------------------------------------------------------------------------------

return M
