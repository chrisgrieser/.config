require("lua.utils")

--------------------------------------------------------------------------------
IMacDisplay = hs.screen("Built%-in")
Maximized = hs.layout.maximized
RightHalf = hs.layout.right50
LeftHalf = hs.layout.left50
PseudoMaximized = { x = 0.184, y = 0, w = 0.817, h = 1 }
Centered = { x = 0.186, y = 0, w = 0.6, h = 1 }
ToTheSide = hs.geometry.rect(-70.0, 54.0, 425.0, 1026.0) -- negative x to hide useless sidebar

---@param win hs.window
---@param size hs.geometry
---@return boolean|nil
function CheckSize(win, size)
	if not win then return nil end
	local invalidWinsByTitle = { -- windows which cannot be resized
		"Copy",
		"Move",
		"Delete",
		"System Settings",
		"Transmission",
		"Twitter",
	}
	if tableContains(invalidWinsByTitle, win:title()) then return nil end
	local maxf = win:screen():frame()
	local winf = win:frame()

	local diffw = winf.w - size.w * maxf.w
	local diffh = winf.h - size.h * maxf.h
	local diffx = size.x * maxf.w + maxf.x - winf.x -- calculated this way for two screens
	local diffy = size.y * maxf.h + maxf.y - winf.y
	local widthOkay = (diffw > -5 and diffw < 5) -- leeway for rounding
	local heightOkay = (diffh > -5 and diffh < 5)
	local posyOkay = (diffy > -5 and diffy < 5)
	local posxOkay = (diffx > -5 and diffx < 5)

	return widthOkay and heightOkay and posxOkay and posyOkay
end

--------------------------------------------------------------------------------
-- SIDEBARS

-- requires these two helper actions for Drafts installed:
-- https://directory.getdrafts.com/a/2BS & https://directory.getdrafts.com/a/2BR
---@param draftsWin hs.window
local function toggleDraftsSidebar(draftsWin)
	runWithDelays({ 0.05, 0.2 }, function()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		local mode = drafts_w / screen_w > 0.6 and "show" or "hide"
		openLinkInBackground("drafts://x-callback-url/runAction?text=&action=" .. mode .. "-sidebar")
	end)
end

---@param highlightsWin hs.window
local function toggleHighlightsSidebar(highlightsWin)
	runWithDelays(0.3, function()
		local highlights_w = highlightsWin:frame().w
		local screen_w = highlightsWin:screen():frame().w
		local highlightsApp = hs.application("Highlights")
		highlightsApp:activate()
		local mode = highlights_w / screen_w > 0.6 and "Show" or "Hide"
		highlightsApp:selectMenuItem { "View", mode .. " Sidebar" }
	end)
end

-- requires Obsidian Sidebar Toggler Plugin https://github.com/chrisgrieser/obsidian-sidebar-toggler
---@param obsiWin hs.window
local function toggleObsidianSidebar(obsiWin)
	runWithDelays({ 0.05, 0.2 }, function()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if numberOfObsiWindows > 1 then return end -- prevent popout window resizing to affect sidebars

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w

		-- if pseudo-maximized, hide sidebar, if half or full show sidebar
		-- (full = used as split pane)
		local mode = (obsi_width / screen_width > 0.6 and obsi_width / screen_width < 0.99) and "true"
			or "false"
		openLinkInBackground("obsidian://sidebar?showRight=" .. mode .. "&showLeft=false")
	end)
end

---@param win hs.window
function ToggleWinSidebar(win)
	if not win or not win:application() then return end
	local appOfWin = win:application():name()
	if appOfWin == "Drafts" then
		toggleDraftsSidebar(win)
	elseif appOfWin == "Obsidian" then
		toggleObsidianSidebar(win)
	elseif appOfWin == "Highlights" then
		toggleHighlightsSidebar(win)
	end
end

function ShowAllSidebars()
	if appIsRunning("Highlights") then app("Highlights"):selectMenuItem { "View", "Show Sidebar" } end
	openLinkInBackground("obsidian://sidebar?showLeft=false&showRight=true")
	openLinkInBackground("drafts://x-callback-url/runAction?text=&action=show-sidebar")
end

--------------------------------------------------------------------------------

---ensures Obsidian windows are always shown when developing css
---@param win hs.window
---@param pos hs.geometry
local function obsidianThemeDevHelper(win, pos)
	if not win or not win:application() then return end
	if
		not (pos == PseudoMaximized or pos == Maximized)
		and win:application():name():lower() == "neovide"
		and appIsRunning("Obsidian")
	then
		runWithDelays(0.15, function()
			app("Obsidian"):unhide()
			app("Obsidian"):mainWindow():raise()
		end)
	end
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

---@param win hs.window
---@param pos hs.geometry
function MoveResize(win, pos)
	if not win or not win:application() then return end
	local appName = win:application():name()
	if appName == "System Settings" or appName == "Twitter" or appName == "Transmission" then
		notify(appName .. " cannot be resized properly.")
		return
	end

	ToggleWinSidebar(win)
	obsidianThemeDevHelper(win, pos)

	if
		(pos == PseudoMaximized or pos == Centered)
		and appIsRunning("Twitter")
		and win:title() ~= "Quick Look"
	then
		app("Twitter"):mainWindow():raise()
	end

	-- pseudo-timeout
	local i = 0
	while i < 20 and CheckSize(win, pos) == false do
		if not win then return end
		win:moveToUnit(pos)
		os.execute("sleep 0.1") -- since lua itself does not have a blocking wait function
		i = i + 1
	end
end

--------------------------------------------------------------------------------
-- WINDOW TILING (OF SAME APP)

---automatically apply per-app auto-tiling of the windows of the app
---@param windowSource hs.window.filter|string windowfilter or appname
function AutoTile(windowSource)
	---necessary b/c windowfilter is null when not triggered via
	---windowfilter-subscription-event. This check allows for using app names,
	---which enables using the autotile-function within app watchers
	---@param _windowSource hs.window.filter|string windowFilter OR string representing app name
	---@return hs.window[]
	local function getWins(_windowSource)
		if type(_windowSource) == "string" then
			return app(_windowSource):allWindows()
		else
			return _windowSource:getWindows()
		end
	end
	local wins = getWins(windowSource)

	if #wins == 0 and frontAppName() == "Finder" then
		-- prevent quitting when window is created imminently
		runWithDelays(1, function()
			-- 1) quitting Finder requires `defaults write com.apple.finder QuitMenuItem -bool true`
			-- 2) getWins() again to check if window count has changed in the meantime
			-- 3) delay needs to be high enough to since e.g. during quitting fullscreen
			-- mode, Hammerspoon temporarily cannot detect Finder windows (sic!)
			if #getWins(windowSource) == 0 then app("Finder"):kill() end
		end)
	elseif #wins == 1 then
		if isProjector() then
			MoveResize(wins[1], Maximized)
		elseif frontAppName() == "Finder" then
			MoveResize(wins[1], Centered)
		else
			MoveResize(wins[1], PseudoMaximized)
		end
	elseif #wins == 2 then
		MoveResize(wins[1], LeftHalf)
		MoveResize(wins[2], RightHalf)
	elseif #wins == 3 then
		MoveResize(wins[1], { h = 1, w = 0.33, x = 0, y = 0 })
		MoveResize(wins[2], { h = 1, w = 0.34, x = 0.33, y = 0 })
		MoveResize(wins[3], { h = 1, w = 0.33, x = 0.67, y = 0 })
	elseif #wins == 4 then
		MoveResize(wins[1], { h = 0.5, w = 0.5, x = 0, y = 0 })
		MoveResize(wins[2], { h = 0.5, w = 0.5, x = 0, y = 0.5 })
		MoveResize(wins[3], { h = 0.5, w = 0.5, x = 0.5, y = 0 })
		MoveResize(wins[4], { h = 0.5, w = 0.5, x = 0.5, y = 0.5 })
	end
end

--------------------------------------------------------------------------------
-- HOTKEY ACTIONS

local function controlSpaceAction()
	local currentWin = hs.window.focusedWindow()
	local pos
	if frontAppName() == "Finder" or frontAppName() == "Script Editor" then
		pos = Centered
	elseif not CheckSize(currentWin, PseudoMaximized) then
		pos = PseudoMaximized
	else
		pos = Maximized
	end
	MoveResize(currentWin, pos)
end

--------------------------------------------------------------------------------

local function moveCurWinToOtherDisplay()
	local win = hs.window.focusedWindow()
	if not win then return end
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	runWithDelays({ 0.1, 0.2 }, function()
		-- workaround for ensuring proper resizing
		win = hs.window.focusedWindow()
		if not win then return end
		win:setFrameInScreenBounds(win:frame())
	end)
end

local function homeAction()
	if appIsRunning("zoom.us") then
		alert("🔈/🔇") -- toggle mute
		keystroke({ "shift", "command" }, "A", 1, app("zoom.us"))
		return
	end
	TwitterScrollUp()
end

local function endAction()
	if appIsRunning("zoom.us") then
		alert("📹") -- toggle video
		keystroke({ "shift", "command" }, "V", 1, app("zoom.us"))
		return
	end
end

--------------------------------------------------------------------------------

-- Hotkeys
hotkey({}, "f6", moveCurWinToOtherDisplay) -- for apple keyboard
hotkey(hyper, "pagedown", moveCurWinToOtherDisplay)
hotkey(hyper, "pageup", moveCurWinToOtherDisplay)
hotkey({}, "home", homeAction)
hotkey({}, "end", endAction)
hotkey(hyper, "right", function() MoveResize(hs.window.focusedWindow(), RightHalf) end)
hotkey(hyper, "left", function() MoveResize(hs.window.focusedWindow(), LeftHalf) end)
hotkey({ "ctrl" }, "space", controlSpaceAction) -- fn+space also bound to ctrl+space via Karabiner

