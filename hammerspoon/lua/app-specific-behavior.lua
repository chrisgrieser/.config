local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local wf = require("lua.utils").wf
local aw = require("lua.utils").aw
--------------------------------------------------------------------------------

---play/pause spotify with Spotify
---@param toStatus string pause|play
local function spotifyDo(toStatus)
	-- stylua: ignore start
	local currentStatus = hs.execute(u.exportPath .. "spt playback --status --format=%s"):gsub("\n$", "")
	if
		(currentStatus == "▶️" and toStatus == "pause")
		or (currentStatus == "⏸" and toStatus == "play")
	then
		local stdout = hs.execute(u.exportPath .. "spt playback --toggle")
		if toStatus == "play" then u.notify(stdout) end ---@diagnostic disable-line: param-type-mismatch
	end
	-- stylua: ignore end
end

-- auto-pause/resume Spotify on launch/quit of apps with sound
SpotifyAppWatcher = aw.new(function(appName, eventType)
	local appsWithSound = { "YouTube", "zoom.us", "FaceTime", "Twitch", "Netflix", "CrunchyRoll" }
	if
		not u.screenIsUnlocked()
		or env.isAtOffice
		or env.isProjector()
		or not (u.tbl_contains(appsWithSound, appName))
	then
		return
	end

	if eventType == aw.launched then
		spotifyDo("pause")
	elseif eventType == aw.terminated then
		spotifyDo("play")
	end
end):start()

--------------------------------------------------------------------------------

-- PIXELMATOR: open maximized
PixelmatorWatcher = aw.new(function(appName, eventType, pixelmator)
	if appName == "Pixelmator" and eventType == aw.launched then
		u.asSoonAsAppRuns(appName, function() wu.moveResize(pixelmator, wu.maximized) end)
	end
end):start()

--------------------------------------------------------------------------------

-- BROWSER
Wf_browser = wf.new(env.browserApp)
	:setOverrideFilter({
		rejectTitles = {
			" %(Private%)$", -- incognito windows
			"^Picture in Picture$",
			"^Task Manager$",
			"^Developer Tools", -- when inspecting websites
			"^DevTools",
			"^$", -- when inspecting Vivaldi UI, devtools are titled "^$" on creation
		},
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(wf.windowCreated, function() wu.autoTile(Wf_browser) end)
	:subscribe(wf.windowDestroyed, function() wu.autoTile(Wf_browser) end)
	:subscribe(wf.windowFocused, wu.bringAllWinsToFront)

-- Automatically hide Browser has when no window
-- requires wider window-filter to not hide PiP windows etc
Wf_browser_all = wf.new({ env.browserApp })
	:setOverrideFilter({ allowRoles = "AXStandardWindow" })
	:subscribe(wf.windowDestroyed, function()
		local app = u.app(env.browserApp)
		if app and #(app:allWindows()) == 0 then app:hide() end
	end)

--------------------------------------------------------------------------------
-- OBSIDIAN

---half -> hide right sidebar
---pseudo-maximized -> show right sidebar
---max -> hide right sidebars (assuming split)
Wf_ObsidanMoved = u.wf.new("Obsidian"):subscribe(u.wf.windowMoved, function(obsiWin)
	if #u.app("Obsidian"):allWindows() > 1 then return end -- prevent popout window resizing to affect sidebars

	local relObsiWinWidth = obsiWin:size().w / obsiWin:screen():frame().w
	local modeRight = (relObsiWinWidth > 0.6 and relObsiWinWidth < 0.99) and "expand" or "collapse"
	u.openLinkInBg("obsidian://advanced-uri?eval=this.app.workspace.rightSplit." .. modeRight .. "%28%29")
end)

--------------------------------------------------------------------------------
-- NEOVIM / NEOVIDE

---ensures Obsidian windows are always shown when developing, mostly for developing CSS
---@param win hs.window
local function obsidianThemeDevHelper(win)
	local obsi = u.app("Obsidian")
	if
		not win
		or not win:application()
		or not (win:application():name():lower() == "neovide")
		or not obsi
	then
		return
	end

	-- delay to avoid conflict with app-hider.lua and that resizing took place
	u.runWithDelays(0.1, function()
		if wu.CheckSize(win, wu.pseudoMax) or wu.CheckSize(win, wu.maximized) then
			obsi:hide()
		else
			obsi:unhide()
			obsi:mainWindow():raise()
		end
	end)
end

-- Add dots when copypasting from dev tools
local function addCssSelectorLeadingDot()
	if
		not u.appRunning("neovide")
		or not u.app("neovide"):mainWindow()
		or not u.app("neovide"):mainWindow():title():find("%.css$")
	then
		return
	end

	local clipb = hs.pasteboard.getContents()
	if not clipb then return end

	local hasSelectorAndClass = clipb:find(".%-.")
		and not (clipb:find("[\n.=]"))
		and not (clipb:find("^%-%-"))
	if not hasSelectorAndClass then return end

	clipb = clipb:gsub("^", "."):gsub(" ", ".")
	hs.pasteboard.setContents(clipb)
end

NeovideWatcher = aw.new(function(appName, eventType, neovide)
	if not appName or appName:lower() ~= "neovide" then return end

	if eventType == aw.activated then
		addCssSelectorLeadingDot()
		obsidianThemeDevHelper(neovide:mainWindow())

		-- HACK bugfix for: https://github.com/neovide/neovide/issues/1595
	elseif eventType == aw.terminated then
		u.runWithDelays({ 5, 10 }, function() hs.execute("pgrep -xq 'neovide' || killall -KILL nvim") end)
	end
end):start()

Wf_neovideMoved = u.wf
	.new({ "Neovide", "neovide" })
	:subscribe(u.wf.windowMoved, function(movedWin) obsidianThemeDevHelper(movedWin) end)

-- HACK since neovide does not send a launch signal, triggering window resizing
-- via its URI scheme called on VimEnter
u.urischeme("enlarge-neovide-window", function()
	u.asSoonAsAppRuns("neovide", function()
		local neovideWin = u.app("neovide"):mainWindow()
		local size = env.isProjector() and wu.maximized or wu.pseudoMax
		wu.moveResize(neovideWin, size)
	end)
end)

--------------------------------------------------------------------------------
-- FINDER

Wf_finder = wf.new("Finder")
	:setOverrideFilter({
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(wf.windowCreated, function(win)
		if not (win:isMaximizable() and win:isStandard()) then return end
		wu.autoTile(Wf_finder)
	end)
	:subscribe(wf.windowDestroyed, function(win)
		-- not using maximizable as condition, since closed windows never
		-- fulfill that condition
		if win:isStandard() then return end
		wu.autoTile(Wf_finder)
	end)

-- also triggered via app-watcher, since windows created in the bg do not always
-- trigger window filters
FinderAppWatcher = aw.new(function(appName, eventType, finder)
	if eventType == aw.activated and appName == "Finder" then
		wu.autoTile("Finder")
		finder:selectMenuItem { "View", "Hide Sidebar" }
	end
end):start()

--------------------------------------------------------------------------------

-- ZOOM
-- close first window, when second is open
-- don't leave browser tab behind when opening zoom
Wf_zoom = wf.new("zoom.us"):subscribe(wf.windowCreated, function()
	u.quitApp("BusyCal") -- only used to open a Zoom link
	u.closeTabsContaining("zoom.us")
	u.runWithDelays(0.5, function()
		local zoom = u.app("zoom.us")
		if not zoom then return end
		local secondWin = zoom:findWindow("^Zoom$") or zoom:findWindow("^Login$")
		if not secondWin or #Wf_zoom:getWindows() < 2 then return end
		secondWin:close()
	end)
end)

--------------------------------------------------------------------------------

-- HIGHLIGHTS
-- - Sync Dark & Light Mode
-- - Start with Highlight Tool enabled
HighlightsAppWatcher = aw.new(function(appName, eventType, highlights)
	if not (eventType == aw.launched and appName == "Highlights") then return end

	local targetView = "Default"
	if u.isDarkMode() then targetView = "Night" end
	highlights:selectMenuItem { "View", "PDF Appearance", targetView }

	-- pre-select yellow highlight tool & hide toolbar
	highlights:selectMenuItem { "Tools", "Highlight" }
	highlights:selectMenuItem { "Tools", "Color", "Yellow" }
	highlights:selectMenuItem { "View", "Hide Toolbar" }

	wu.moveResize(highlights:mainWindow(), wu.pseudoMax)
end):start()

-- PREVIEW: pseudomaximize
PreviewAppWatcher = aw.new(function(appName, eventType, preview)
	if not (eventType == aw.launched and appName == "Preview") then return end
	wu.moveResize(preview:mainWindow(), wu.pseudoMax)
end):start()

--------------------------------------------------------------------------------
-- SCRIPT EDITOR
Wf_script_editor = wf
	.new("Script Editor")
	:subscribe(wf.windowCreated, function(newWin)
		-- skip new file creation dialogue
		if newWin:title() == "Open" then
			u.keystroke({ "cmd" }, "n")
		-- auto-paste and lint content; resize window
		elseif newWin:title() == "Untitled" then
			u.keystroke({ "cmd" }, "v")
			wu.moveResize(newWin, wu.centered)
			u.runWithDelays(0.2, function() u.keystroke({ "cmd" }, "k") end)
		-- resize window
		elseif newWin:title():find("%.sdef$") then
			wu.moveResize(newWin, wu.centered)
		end
	end)
	-- fix line breaks for copypasting into other apps
	:subscribe(wf.windowUnfocused, function()
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end
		clipb = clipb:gsub("\r", "\n")
		hs.pasteboard.setContents(clipb)
	end)

--------------------------------------------------------------------------------

-- DISCORD
-- when focused, enclose URL in clipboard with <>
-- when unfocused, removes <> from URL in clipboard
DiscordAppWatcher = aw.new(function(appName, eventType)
	if not (appName == "Discord") then return end

	local clipb = hs.pasteboard.getContents()
	if not clipb then return end

	if eventType == aw.activated then
		local hasURL = clipb:match("^https?:%S+$")
		local hasObsidianURL = clipb:match("^obsidian:%S+$")
		local isTweet = clipb:match("^https?://twitter%.com") -- for tweets, the previews are actually useful since they show the full content
		if (hasURL or hasObsidianURL) and not isTweet then
			hs.pasteboard.setContents("<" .. clipb .. ">")
		end
	elseif eventType == aw.deactivated then
		local hasEnclosedURL = clipb:match("^<https?:%S+>$")
		local hasEnclosedObsidianURL = clipb:match("^<obsidian:%S+>$")
		if hasEnclosedURL or hasEnclosedObsidianURL then
			clipb = clipb:sub(2, -2) -- remove first & last character
			hs.pasteboard.setContents(clipb)
		end
	end
end):start()
