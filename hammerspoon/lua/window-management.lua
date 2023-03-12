require("lua.utils")
require("lua.twitter")

--------------------------------------------------------------------------------
IMacDisplay = hs.screen("Built%-in")
Maximized = hs.layout.maximized
RightHalf = hs.layout.right50
LeftHalf = hs.layout.left50
TopHalf = { x = 0, y = 0, w = 1, h = 0.5 }
BottomHalf = { x = 0, y = 0.5, w = 1, h = 0.5 }
PseudoMaximized = { x = 0.184, y = 0, w = 0.817, h = 1 }
Centered = { x = 0.184, y = 0, w = 0.6, h = 1 }
ToTheSide = hs.geometry.rect(-70.0, 54.0, 425.0, 1026.0) -- negative x to hide useless sidebar

---@param win hs.window
---@param size hs.geometry
---@return boolean|nil whether win has the given size. returns nil for invalid win
function CheckSize(win, size)
	local invalidWinsByTitle = { -- windows which can/should not be resized
		"Copy", -- Finder
		"Move", -- Finder
		"Delete", -- Finder
		"Enki",
		"System Settings",
		"Transmission",
		"Twitter",
		"Alfred",
	}
	if not win or TableContains(invalidWinsByTitle, win:title()) then return nil end

	local maxf = win:screen():frame()
	local winf = win:frame()
	local diffw = winf.w - size.w * maxf.w
	local diffh = winf.h - size.h * maxf.h
	local diffx = size.x * maxf.w + maxf.x - winf.x -- calculated this way for two screens
	local diffy = size.y * maxf.h + maxf.y - winf.y

	local leeway = 5 -- for inprecisely resized windows
	local widthOkay = (diffw > -leeway and diffw < leeway)
	local heightOkay = (diffh > -leeway and diffh < leeway)
	local posyOkay = (diffy > -leeway and diffy < leeway)
	local posxOkay = (diffx > -leeway and diffx < leeway)

	return widthOkay and heightOkay and posxOkay and posyOkay
end

--------------------------------------------------------------------------------
-- SIDEBARS

-- requires these two helper actions for Drafts installed:
-- https://directory.getdrafts.com/a/2BS & https://directory.getdrafts.com/a/2BR
---@param draftsWin hs.window
local function toggleDraftsSidebar(draftsWin)
	RunWithDelays({ 0.05, 0.2 }, function()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		local mode = drafts_w / screen_w > 0.6 and "show" or "hide"
		OpenLinkInBackground("drafts://x-callback-url/runAction?text=&action=" .. mode .. "-sidebar")
	end)
end

-- requires Obsidian Sidebar Toggler Plugin https://github.com/chrisgrieser/obsidian-sidebar-toggler
---@param obsiWin hs.window
local function toggleObsidianSidebar(obsiWin)
	RunWithDelays({ 0.05, 0.2 }, function()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if numberOfObsiWindows > 1 then return end -- prevent popout window resizing to affect sidebars

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w

		-- half -> hide sidebar
		-- pseudo-maximized -> show sidebar
		-- max -> hide sidebar (since assuming Obsidian split)
		local mode = (obsi_width / screen_width > 0.6 and obsi_width / screen_width < 0.99) and "expand" or "collapse"
		OpenLinkInBackground("obsidian://advanced-uri?eval=this.app.workspace.rightSplit." .. mode .. "%28%29")
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
	end
end

---show the sidebars of Obsidian and Drafts
function ShowAllSidebars()
	OpenLinkInBackground("obsidian://advanced-uri?eval=this.app.workspace.rightSplit.expand%28%29")
	OpenLinkInBackground("drafts://x-callback-url/runAction?text=&action=show-sidebar")
end

--------------------------------------------------------------------------------

---ensures Obsidian windows are always shown when developing, mostly for developing CSS
---@param win hs.window
---@param pos hs.geometry
local function obsidianThemeDevHelper(win, pos)
	if not win or not win:application() then return end
	if
		not (pos == PseudoMaximized or pos == Maximized)
		and win:application():name():lower() == "neovide"
		and AppIsRunning("Obsidian")
	then
		RunWithDelays(0.15, function()
			App("Obsidian"):unhide()
			App("Obsidian"):mainWindow():raise()
		end)
	end
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

---@param win hs.window
---@param pos hs.geometry
function MoveResize(win, pos)
	-- guard clauses
	if
		not win
		or not win:application()
		or CheckSize(win, pos) -- already correctly sized
		or win:title() == "Quick Look"
	then
		return
	end
	local appsToIgnore = { "System Settings", "Twitter", "Transmission", "Alfred" }
	local appName = win:application():name()
	if TableContains(appsToIgnore, appName) then
		Notify(appName .. " cannot be resized properly.")
		return
	end

	-- extras
	ToggleWinSidebar(win)
	obsidianThemeDevHelper(win, pos)
	if (pos == PseudoMaximized or pos == Centered) and AppIsRunning("Twitter") then
		TwitterToTheSide()
	elseif pos == Maximized and AppIsRunning("Twitter") then
		App("Twitter"):hide()
	end

	-- resize
	local i = 0
	while i < 20 and CheckSize(win, pos) == false do
		if not win then return end
		win:moveToUnit(pos)
		Wait(0.1)
		i = i + 1
	end
end

--------------------------------------------------------------------------------
-- WINDOW TILING (OF SAME APP)

---bring all windows of front app to the front
function BringAllToFront()
	local app = hs.application.frontmostApplication()
	if #app:allWindows() < 2 then return end -- the occasional faulty creation of task manager windows in Browser
	app:selectMenuItem { "Window", "Bring All to Front" }
end

---automatically apply per-app auto-tiling of the windows of the app
---@param winSrc hs.window.filter|string source for the windows; windowfilter or
---appname. If this function is not triggered by a windowfilter event, the window
---filter does not contain any windows, therefore we need to get the windows from
---the appObj instead in those cases
function AutoTile(winSrc)
	if type(winSrc) == "string" and not AppIsRunning(winSrc) then return end

	local wins = (type(winSrc) ~= "string") and winSrc:getWindows() or App(winSrc):allWindows()
	if #wins > 1 then BringAllToFront() end

	if #wins == 0 and FrontAppName() == "Finder" then
		-- prevent quitting when window is created imminently
		RunWithDelays(0.4, function()
			-- delay needs to be high enough to since e.g. during quitting fullscreen
			-- mode, Hammerspoon temporarily cannot detect Finder windows (SIC!)
			QuitFinderIfNoWindow()
		end)
	elseif #wins == 1 then
		if IsProjector() then
			MoveResize(wins[1], Maximized)
		elseif FrontAppName() == "Finder" then
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
	if FrontAppName() == "Finder" or FrontAppName() == "Script Editor" then
		pos = Centered
	elseif not CheckSize(currentWin, PseudoMaximized) then
		pos = PseudoMaximized
	else
		pos = Maximized
	end
	MoveResize(currentWin, pos)
end

local function moveCurWinToOtherDisplay()
	local win = hs.window.focusedWindow()
	if not win then return end
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	RunWithDelays({ 0.1, 0.4 }, function()
		-- workaround for ensuring proper resizing
		win = hs.window.focusedWindow()
		if not win then return end
		win:setFrameInScreenBounds(win:frame())
	end)
end

local function homeAction()
	if #(hs.screen.allScreens()) > 1 then
		moveCurWinToOtherDisplay()
	elseif AppIsRunning("zoom.us") then
		Alert("🔈/🔇") -- toggle mute
		Keystroke({ "shift", "command" }, "A", 1, App("zoom.us"))
	else
		TwitterScrollUp()
	end
end

local function endAction()
	if #(hs.screen.allScreens()) > 1 then
		moveCurWinToOtherDisplay()
	elseif AppIsRunning("zoom.us") then
		Alert("📹") -- toggle video
		Keystroke({ "shift", "command" }, "V", 1, App("zoom.us"))
	else
		Alert("<Nop>")
	end
end

--------------------------------------------------------------------------------

-- Hotkeys
Hotkey({}, "f6", moveCurWinToOtherDisplay) -- for apple keyboard
Hotkey({}, "home", homeAction)
Hotkey({}, "end", endAction)
Hotkey(Hyper, "right", function() MoveResize(hs.window.focusedWindow(), RightHalf) end)
Hotkey(Hyper, "left", function() MoveResize(hs.window.focusedWindow(), LeftHalf) end)
Hotkey(Hyper, "down", function() MoveResize(hs.window.focusedWindow(), BottomHalf) end)
Hotkey(Hyper, "up", function() MoveResize(hs.window.focusedWindow(), TopHalf) end)
Hotkey({ "ctrl" }, "space", controlSpaceAction) -- fn+space also bound to ctrl+space via Karabiner
