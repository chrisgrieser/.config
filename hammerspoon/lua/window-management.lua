require("lua.utils")
require("lua.twitterrific-controls")

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT UTILS
iMacDisplay = hs.screen("Built%-in")
maximized = hs.layout.maximized

-- device-specific parameters
if isIMacAtHome() then
	pseudoMaximized = {x = 0, y = 0, w = 0.8175, h = 1}
	baseLayout = pseudoMaximized
	toTheSide = {x = 0.815, y = 0.025, w = 0.185, h = 0.975}
elseif isAtMother() then
	pseudoMaximized = {x = 0, y = 0, w = 0.7875, h = 1}
	baseLayout = pseudoMaximized
	toTheSide = {x = 0.7875, y = 0.03, w = 0.2125, h = 0.97}
elseif isAtOffice() then
	baseLayout = maximized
	pseudoMaximized = maximized
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

---Whether Window is half-sized
---@param win hs.window
---@return boolean
function isHalf(win)
	if not (win) then return false end
	local max = win:screen():frame()
	local dif = win:frame().w - 0.5 * max.w
	return (dif > -15 and dif < 15) -- leeway for some apps
end

--------------------------------------------------------------------------------
-- SIDEBARS

-- requires these two helper actions for Drafts installed:
-- https://directory.getdrafts.com/a/2BS & https://directory.getdrafts.com/a/2BR
---@param draftsWin hs.window
function toggleDraftsSidebar(draftsWin)
	repeatFunc({0.05, 0.2}, function()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		if (drafts_w / screen_w > 0.6) then
			openLinkInBackground("drafts://x-callback-url/runAction?text=&action=show-sidebar")
		else
			openLinkInBackground("drafts://x-callback-url/runAction?text=&action=hide-sidebar")
		end
	end)
end

---@param highlightsWin hs.window
function toggleHighlightsSidebar(highlightsWin)
	runDelayed(0.3, function()
		local highlights_w = highlightsWin:frame().w
		local screen_w = highlightsWin:screen():frame().w
		local highlightsApp = hs.application("Highlights")
		highlightsApp:activate()
		if (highlights_w / screen_w > 0.6) then
			highlightsApp:selectMenuItem {"View", "Show Sidebar"}
		else
			highlightsApp:selectMenuItem {"View", "Hide Sidebar"}
		end
	end)
end

-- requires Obsidian Sidebar Toggler Plugin https://github.com/chrisgrieser/obsidian-sidebar-toggler
---@param obsiWin hs.window
function toggleObsidianSidebar(obsiWin)
	repeatFunc({0.05, 0.2}, function()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if (numberOfObsiWindows > 1) then return end -- prevent popout window resizing to affect sidebars

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

---Moved Window
---@param mode string
function moveResizeCurWin(mode)
	local win = hs.window.focusedWindow()
	local appName = win:application():name()

	local position
	if (mode == "left") then
		position = hs.layout.left50
	elseif (mode == "right") then
		position = hs.layout.right50
	elseif (mode == "up") then
		position = {x = 0, y = 0, w = 1, h = 0.5}
	elseif (mode == "down") then
		position = {x = 0, y = 0.5, w = 1, h = 0.5}
	elseif (mode == "pseudo-maximized") then
		position = pseudoMaximized
	elseif (mode == "maximized") then
		position = maximized
	elseif (mode == "centered") then
		position = {x = 0.2, y = 0.1, w = 0.6, h = 0.8}
	end

	if not (mode == "pseudo-maximized" or mode == "maximized") then
		unHideAll()
		if appName == "neovide" or appName == "Neovide" then -- useful for theme development
			runDelayed(0.2, function()
				app("Obsidian"):mainWindow():raise()
			end)
		end
	end

	moveResize(win, position) -- workaround for https://github.com/Hammerspoon/hammerspoon/issues/2316

	if appName == "Drafts" then toggleDraftsSidebar(win)
	elseif appName == "Obsidian" then toggleObsidianSidebar(win)
	elseif appName == "Highlights" then toggleHighlightsSidebar(win)
	end

	if mode == "pseudo-maximized" then
		app("Twitterrific"):mainWindow():raise()
	end

end

---replaces `win:moveToUnit(pos)`
---@param win hs.window
---@param pos hs.geometry
function moveResize(win, pos)
	-- has to repeat due window creation delay for some apps
	repeatFunc({0, 0.1, 0.3, 0.5}, function() win:moveToUnit(pos) end)
end

local function moveCurWinToOtherDisplay()
	local win = hs.window.focusedWindow()
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	-- workaround for ensuring proper resizing
	runDelayed(0.25, function()
		win_ = hs.window.focusedWindow()
		win_:setFrameInScreenBounds(win_:frame())
	end)
end

--------------------------------------------------------------------------------
-- HOTKEYS
local function controlSpace()
	if frontApp() == "Finder" or frontApp() == "Script Editor" then
		size = "centered"
	elseif isIMacAtHome() or isAtMother() then
		local currentWin = hs.window.focusedWindow()
		if isPseudoMaximized(currentWin) then
			size = "maximized"
		else
			size = "pseudo-maximized"
		end
	else
		size = "maximized"
	end

	moveResizeCurWin(size)
end

hotkey(hyper, "up", function() moveResizeCurWin("up") end)
hotkey(hyper, "down", function() moveResizeCurWin("down") end)
hotkey(hyper, "right", function() moveResizeCurWin("right") end)
hotkey(hyper, "left", function() moveResizeCurWin("left") end)
hotkey({}, "f6", moveCurWinToOtherDisplay) -- for apple keyboard
hotkey(hyper, "pagedown", moveCurWinToOtherDisplay)
hotkey(hyper, "pageup", moveCurWinToOtherDisplay)
hotkey({"ctrl"}, "space", controlSpace) -- fn+space also bound to ctrl+space via Karabiner
