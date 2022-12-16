require("lua.utils")

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT UTILS
iMacDisplay = hs.screen("Built%-in")
maximized = hs.layout.maximized
rightHalf = hs.layout.right50
leftHalf = hs.layout.left50

-- device-specific parameters
if isIMacAtHome() then
	pseudoMaximized = {x = 0, y = 0, w = 0.816, h = 1}
	baseLayout = pseudoMaximized
	toTheSide = {x = 0.815, y = 0.025, w = 0.185, h = 0.975}
	centered = {x = 0.2, y = 0, w = 0.616, h = 1}
elseif isAtMother() then
	pseudoMaximized = {x = 0, y = 0, w = 0.7875, h = 1}
	baseLayout = pseudoMaximized
	toTheSide = {x = 0.7875, y = 0.03, w = 0.2125, h = 0.97}
	centered = {x = 0.2, y = 0, w = 0.616, h = 1}
elseif isAtOffice() then
	baseLayout = maximized
	pseudoMaximized = maximized
	centered = {x = 0.2, y = 0, w = 0.616, h = 1}
end

---Whether Window is maximimized
---@param win hs.window
---@return boolean
function isMaximized(win)
	if not (win) then return false end
	local max = win:screen():frame()
	return win:frame().w == max.w
end

---Whether Window is pseudoMaximized
---@param win hs.window
---@return boolean
function isPseudoMaximized(win)
	if not (win) then return false end
	local max = win:screen():frame()
	local dif = win:frame().w - pseudoMaximized.w * max.w
	local posOkay = win:frame().x == 0 and win:frame().y == 0
	local widthOkay = (dif > -15 and dif < 15) -- leeway for some apps
	return widthOkay and posOkay
end

--------------------------------------------------------------------------------
-- SIDEBARS

-- requires these two helper actions for Drafts installed:
-- https://directory.getdrafts.com/a/2BS & https://directory.getdrafts.com/a/2BR
---@param draftsWin hs.window
function toggleDraftsSidebar(draftsWin)
	runWithDelays({0.05, 0.2}, function()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		if drafts_w / screen_w > 0.6 then
			openLinkInBackground("drafts://x-callback-url/runAction?text=&action=show-sidebar")
		else
			openLinkInBackground("drafts://x-callback-url/runAction?text=&action=hide-sidebar")
		end
	end)
end

---@param highlightsWin hs.window
function toggleHighlightsSidebar(highlightsWin)
	runWithDelays(0.3, function()
		local highlights_w = highlightsWin:frame().w
		local screen_w = highlightsWin:screen():frame().w
		local highlightsApp = hs.application("Highlights")
		highlightsApp:activate()
		if highlights_w / screen_w > 0.6 then
			highlightsApp:selectMenuItem {"View", "Show Sidebar"}
		else
			highlightsApp:selectMenuItem {"View", "Hide Sidebar"}
		end
	end)
end

-- requires Obsidian Sidebar Toggler Plugin https://github.com/chrisgrieser/obsidian-sidebar-toggler
---@param obsiWin hs.window
function toggleObsidianSidebar(obsiWin)
	runWithDelays({0.05, 0.2}, function()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if numberOfObsiWindows > 1 then return end -- prevent popout window resizing to affect sidebars

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w

		-- if pseudo-maximized, hide sidebar, if half or full show sidebar
		-- (full = used as split pane)
		if (obsi_width / screen_width > 0.6) and (obsi_width / screen_width < 0.99) then
			openLinkInBackground("obsidian://sidebar?showLeft=true&showRight=false")
		else
			openLinkInBackground("obsidian://sidebar?showLeft=false&showRight=false")
		end
	end)
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

---replaces `win:moveToUnit(pos)`
---@param win hs.window
---@param pos hs.geometry
function moveResize(win, pos)
	local appOfWin = win:application():name()
	if appOfWin == "Drafts" then toggleDraftsSidebar(win)
	elseif appOfWin == "Obsidian" then toggleObsidianSidebar(win)
	elseif appOfWin == "Highlights" then toggleHighlightsSidebar(win)
	end

	-- for Obsidian theme development
	if not (pos == pseudoMaximized) and not (pos == maximized) then
		if appOfWin:find("[Nn]eovide") then
			runWithDelays(0.15, function()
				app("Obsidian"):unhide()
				app("Obsidian"):mainWindow():raise()
			end)
		end
	end

	if pos == pseudoMaximized or pos == centered then
		app("Twitterrific"):mainWindow():raise()
	end

	-- has to repeat due window creation delay for some apps
	runWithDelays({0, 0.1, 0.3, 0.5}, function() win:moveToUnit(pos) end)
end

local function moveCurWinToOtherDisplay()
	local win = hs.window.focusedWindow()
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	-- workaround for ensuring proper resizing
	runWithDelays(0.25, function()
		win_ = hs.window.focusedWindow()
		win_:setFrameInScreenBounds(win_:frame())
	end)
end

--------------------------------------------------------------------------------

function twitterrificAction(type)
	local previousApp = frontApp()
	openIfNotRunning("Twitterrific")
	local twitterrific = app("Twitterrific")
	twitterrific:activate() -- needs activation, cause sending to app in background doesn't work w/ cmd

	if type == "link" then
		keystroke({}, "right")
	elseif type == "scrollup" then
		local prevMousePos = hs.mouse.absolutePosition()

		local f = twitterrific:mainWindow():frame()
		keystroke({"cmd"}, "1") -- properly up (to avoid clicking on tweet content)
		hs.eventtap.leftClick {x = f.x + f.w * 0.04, y = f.y + 150}
		keystroke({"cmd"}, "k") -- mark all as red
		keystroke({"cmd"}, "j") -- scroll up
		keystroke({}, "down") -- enable j/k movement

		hs.mouse.absolutePosition(prevMousePos)
		app(previousApp):activate()
	end
end

--------------------------------------------------------------------------------
-- HOTKEY ACTIONS
local function controlSpaceAction()
	local currentWin = hs.window.focusedWindow()
	local pos
	if frontApp() == "Finder" or frontApp() == "Script Editor" then
		pos = centered
	elseif (isIMacAtHome() or isAtMother()) and not (isPseudoMaximized(currentWin)) then
		pos = pseudoMaximized
	else
		pos = maximized
	end
	moveResize(currentWin, pos)
end

local function pagedownAction()
	if #hs.screen.allScreens() > 1 then
		moveCurWinToOtherDisplay()
	elseif appIsRunning("Twitterrific") then
		keystroke({}, "down", 1, app("Twitterrific"))
	end
end

local function pageupAction()
	if #hs.screen.allScreens() > 1 then
		moveCurWinToOtherDisplay()
	elseif appIsRunning("Twitterrific") then
		keystroke({}, "up", 1, app("Twitterrific"))
	end
end

local function homeAction()
	if appIsRunning("zoom.us") then
		alert("🔈/🔇") -- toggle mute
		keystroke({"shift", "command"}, "A", 1, app("zoom.us"))
	elseif appIsRunning("Twitterrific") then
		twitterrificAction("scrollup")
	end
end

local function endAction()
	if appIsRunning("Twitterrific") then
		twitterrificAction("link")
	end
end

--------------------------------------------------------------------------------
-- HOTKEYS
-- Window resizing
hotkey(hyper, "right", function() moveResize(hs.window:focusedWindow(), rightHalf) end)
hotkey(hyper, "left", function() moveResize(hs.window:focusedWindow(), leftHalf) end)
hotkey({"ctrl"}, "space", controlSpaceAction) -- fn+space also bound to ctrl+space via Karabiner

-- move to other display or scroll Twitterrific
hotkey({}, "f6", moveCurWinToOtherDisplay) -- for apple keyboard
hotkey({}, "pagedown", pagedownAction, nil, pagedownAction)
hotkey({}, "pageup", pageupAction, nil, pageupAction)

-- Twitterrific or Zoom
hotkey({}, "home", homeAction)
hotkey({}, "end", endAction)
