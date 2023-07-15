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
-- FINDER

Wf_finder = wf.new("Finder")
	:setOverrideFilter({
		rejectTitles = {
			"^Move$",
			"^Copy$",
			"^Delete$",
			"^Finder Settings$",
			" Info$", -- Info window *end* with "Info"
			"^Alfred$", -- Alfred Compatibility Mode
		},
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(wf.windowCreated, function(win)
		if not (win:isMaximizable() and win:isStandard() and u.app("Finder"):isFrontmost()) then return end
		u.runWithDelays(0.05, function() wu.autoTile(Wf_finder) end)
	end)
	:subscribe(wf.windowDestroyed, function()
		-- no conditions, since destroyed windows do not have those properties
		wu.autoTile(Wf_finder)
	end)

-- also triggered via app-watcher, since windows created in the background do
-- not always trigger window filters
FinderAppWatcher = aw.new(function(appName, eventType, finder)
	if eventType == aw.activated and appName == "Finder" then
		finder:selectMenuItem { "View", "Hide Sidebar" }
		wu.bringAllWinsToFront() -- redundancy
		wu.autoTile("Finder")
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
		if not zoom or zoom:findWindow("Update") then return end
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

	local targetView = u.isDarkMode() and "Night" or "Default"
	highlights:selectMenuItem { "View", "PDF Appearance", targetView }

	-- pre-select yellow highlight tool & hide toolbar
	highlights:selectMenuItem { "Tools", "Highlight" }
	highlights:selectMenuItem { "Tools", "Color", "Yellow" }
	highlights:selectMenuItem { "View", "Hide Toolbar" }
end):start()

-- window filter, so any new window created and not only on app on launch
-- becomes pseudo-maximized
Wf_pdfReader = wf.new({ "Preview", "Highlights", "PDF Expert" })
	:subscribe(wf.windowCreated, function(newWin) wu.moveResize(newWin, wu.pseudoMax) end)

--------------------------------------------------------------------------------

-- TRANSMISSION
-- Fallthrough (prevent unintended focussing after qutting another app)
TransmissionWatcher = u.aw.new(function(appName, event)
	if event == u.aw.terminated and appName ~= "Transmission" then
		u.runWithDelays({ 0.1, 0.3 }, function()
			if not u.isFront("Transmission") then return end
			local visibleWins = hs.window:orderedWindows()
			local nextWin
			for _, win in pairs(visibleWins) do
				if win:application():name() ~= "Transmission" then
					nextWin = win
					break
				end
			end
			if not nextWin or nextWin:id() == hs.window.frontmostWindow():id() then return end
			nextWin:focus()
		end)
	end
end)



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
	-- fix copypasting line breaks into other apps
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

	if eventType == aw.launched or eventType == aw.launching then
		u.openLinkInBg("discord://discord.com/channels/686053708261228577/700466324840775831")
	elseif eventType == aw.activated then
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
