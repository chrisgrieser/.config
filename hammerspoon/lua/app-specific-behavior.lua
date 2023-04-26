local u = require("lua.utils")
local wu = require("lua.window-utils")
local env = require("lua.environment-vars")
--------------------------------------------------------------------------------

---play/pause spotify with Spotify
---@param toStatus string pause|play
local function spotifyDo(toStatus)
	-- stylua: ignore start
	local currentStatus = hs.execute( "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --status --format=%s"):gsub("\n$", "")
	if
		(currentStatus == "▶️" and toStatus == "pause")
		or (currentStatus == "⏸" and toStatus == "play")
	then
		local stdout = hs.execute( "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; spt playback --toggle")
		if toStatus == "play" then u.notify(stdout) end ---@diagnostic disable-line: param-type-mismatch
	end
	-- stylua: ignore end
end

-- auto-pause/resume Spotify on launch/quit of apps with sound
SpotifyAppWatcher = u.aw
	.new(function(appName, eventType)
		local appsWithSound = { "YouTube", "zoom.us", "FaceTime", "Twitch", "Netflix", "CrunchyRoll" }
		if
			not u.screenIsUnlocked()
			or env.isAtOffice
			or env.isProjector()
			or not (u.tbl_contains(appsWithSound, appName))
		then
			return
		end

		if eventType == u.aw.launched then
			spotifyDo("pause")
		elseif eventType == u.aw.terminated then
			spotifyDo("play")
		end
	end)
	:start()

--------------------------------------------------------------------------------

-- PIXELMATOR: open maximized
PixelmatorWatcher = u.aw
	.new(function(appName, eventType, appObj)
		if appName == "Pixelmator" and eventType == u.aw.launched then
			u.asSoonAsAppRuns(appName, function() wu.moveResize(appObj, wu.maximized) end)
		end
	end)
	:start()

--------------------------------------------------------------------------------

-- BROWSER (Vivaldi)
Wf_browser = u.wf
	.new("Vivaldi")
	:setOverrideFilter({
		rejectTitles = {
			" %(Private%)$",
			"^Picture in Picture$",
			"^Task Manager$",
			"^Developer Tools", -- when inspecting websites
			"^DevTools",
			"^$", -- when inspecting Vivaldi UI, are titled "^$" on creation
		},
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(u.wf.windowCreated, function()
		wu.autoTile(Wf_browser)
		u.runWithDelays({ 0.2, 0.5 }, function() u.closeTabsContaining("chrome://vivaldi-webui") end)
	end)
	:subscribe(u.wf.windowDestroyed, function() wu.autoTile(Wf_browser) end)
	:subscribe(u.wf.windowFocused, wu.bringAllWinsToFront)

-- Automatically hide Browser has when no window
-- requires wider window-filter to not hide PiP windows etc
Wf_browser_all = u.wf
	.new({ "Vivaldi" })
	:setOverrideFilter({ allowRoles = "AXStandardWindow" })
	:subscribe(u.wf.windowDestroyed, function()
		local app = u.app("Vivaldi")
		if app and #(app:allWindows()) == 0 then app:hide() end
	end)

--------------------------------------------------------------------------------
-- NEOVIM / NEOVIDE

-- Add dots when copypasting to from dev tools
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

NeovideWatcher = u.aw
	.new(function(appName, eventType)
		if not appName or appName:lower() ~= "neovide" then return end

		if eventType == u.aw.activated then
			addCssSelectorLeadingDot()

		-- HACK bugfix for: https://github.com/neovide/neovide/issues/1595
		elseif eventType == u.aw.terminated then
			u.runWithDelays({ 5, 10 }, function()
				print("🗡️ Killing leftover nvim processes")
				hs.execute("pgrep neovide || killall -KILL nvim")
			end)
		end
	end)
	:start()

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

Wf_finder = u.wf
	.new("Finder")
	:setOverrideFilter({
		rejectTitles = wu.rejectedFinderWins,
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(u.wf.windowCreated, function() wu.autoTile(Wf_finder) end)
	:subscribe(u.wf.windowDestroyed, function() wu.autoTile(Wf_finder) end)

FinderAppWatcher = u.aw
	.new(function(appName, eventType, finderAppObj)
		if eventType == u.aw.activated and appName == "Finder" then
			wu.autoTile("Finder") -- also triggered via app-watcher, since windows created in the bg do not always trigger window filters
			finderAppObj:selectMenuItem { "View", "Hide Sidebar" }
		end
	end)
	:start()

--------------------------------------------------------------------------------

-- QuickLook: bigger window
Wf_quicklook = u
	.wf
	.new(true) -- BUG for some reason, restricting this to "Finder" does not work
	:setOverrideFilter({ allowTitles = { "^Quick Look$", "^qlmanage$" } })
	:subscribe(u.wf.windowCreated, function(newWin)
		local _, sel =
			u.applescript([[tell application "Finder" to return POSIX path of (selection as alias)]])
		-- do not enlage window for images (which are enlarged already with
		-- landscape proportions)
		if
			sel and (sel:find("%.png$") or sel:find("%.jpe?g$") or sel:find("%.gif") or sel:find("%.mp4"))
		then
			return
		end
		u.runWithDelays(0.4, function() wu.moveResize(newWin, wu.centered) end)
	end)

--------------------------------------------------------------------------------

-- ZOOM
-- close first window, when second is open
-- don't leave browser tab behind when opening zoom
Wf_zoom = u.wf.new("zoom.us"):subscribe(u.wf.windowCreated, function()
	u.quitApp("BusyCal") -- mostly only used to open a Zoom link
	u.closeTabsContaining("zoom.us")
	u.runWithDelays(0.5, function()
		local zoom = u.app("zoom.us")
		if not (zoom and zoom:findWindow("^Zoom$")) then return end
		zoom:findWindow("^Zoom$"):close()
	end)
end)

--------------------------------------------------------------------------------

-- HIGHLIGHTS
-- - Sync Dark & Light Mode
-- - Start with Highlight Tool enabled
HighlightsAppWatcher = u.aw
	.new(function(appName, eventType, appObject)
		if not (eventType == u.aw.launched and appName == "Highlights") then return end

		local targetView = "Default"
		if u.isDarkMode() then targetView = "Night" end
		appObject:selectMenuItem { "View", "PDF Appearance", targetView }

		-- pre-select yellow highlight tool & hide toolbar
		appObject:selectMenuItem { "Tools", "Highlight" }
		appObject:selectMenuItem { "Tools", "Color", "Yellow" }
		appObject:selectMenuItem { "View", "Hide Toolbar" }

		wu.moveResize(appObject:mainWindow(), wu.pseudoMax)
	end)
	:start()

--------------------------------------------------------------------------------
-- SCRIPT EDITOR
Wf_script_editor = u
	.wf
	.new("Script Editor")
	:subscribe(u.wf.windowCreated, function(newWin)
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
	:subscribe(u.wf.windowUnfocused, function()
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end
		clipb = clipb:gsub("\r", "\n")
		hs.pasteboard.setContents(clipb)
	end)

--------------------------------------------------------------------------------

-- DISCORD
DiscordAppWatcher = u.aw
	.new(function(appName, eventType)
		if not (appName == "Discord") then return end

		-- on launch, open OMG Server instead of friends (who needs friends if you have Obsidian?)
		if eventType == u.aw.launched then
			u.asSoonAsAppRuns(
				appName,
				function()
					u.openLinkInBg("discord://discord.com/channels/686053708261228577/700466324840775831")
				end
			)
		end

		-- when focused, enclose URL in clipboard with <>
		-- when unfocused, removes <> from URL in clipboard
		local clipb = hs.pasteboard.getContents()
		if not clipb then return end

		if eventType == u.aw.activated then
			local hasURL = clipb:match("^https?:%S+$")
			local hasObsidianURL = clipb:match("^obsidian:%S+$")
			local isTweet = clipb:match("^https?://twitter%.com") -- for tweets, the previews are actually useful since they show the full content
			if (hasURL or hasObsidianURL) and not isTweet then
				hs.pasteboard.setContents("<" .. clipb .. ">")
			end
		elseif eventType == u.aw.deactivated then
			local hasEnclosedURL = clipb:match("^<https?:%S+>$")
			local hasEnclosedObsidianURL = clipb:match("^<obsidian:%S+>$")
			if hasEnclosedURL or hasEnclosedObsidianURL then
				clipb = clipb:sub(2, -2) -- remove first & last character
				hs.pasteboard.setContents(clipb)
			end
		end
	end)
	:start()
