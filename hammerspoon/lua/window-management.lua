require("lua.utils")
require("lua.twitterrific-controls")

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT UTILS
iMacDisplay = hs.screen("Built%-in") -- % to escape hyphen (is a quantifier in lua patterns)
maximized = hs.layout.maximized

-- device-specific parameters
if isIMacAtHome() then
	pseudoMaximized = {x=0, y=0, w=0.815, h=1}
	baseLayout = pseudoMaximized
	toTheSide = {x=0.815, y=0.025, w=0.185, h=0.975}
elseif isAtMother() then
	pseudoMaximized = {x=0, y=0, w=0.7875, h=1}
	baseLayout = pseudoMaximized
	toTheSide = {x=0.7875, y=0.03, w=0.2125, h=0.97}
elseif isAtOffice() then
	baseLayout = maximized
	pseudoMaximized = maximized
end

-- window size checks
function isMaximized (win)
	if not(win) then return false end
	local max = win:screen():frame()
	return win:frame().w == max.w
end

-- window size checks
function isPseudoMaximized (win)
	if not(win) then return false end
	local max = win:screen():frame()
	local dif = win:frame().w - pseudoMaximized.w*max.w
	local widthOkay = (dif > -15 and dif < 15) -- leeway for some apps
	return widthOkay
end

function isHalf (win)
	if not(win) then return false end
	local max = win:screen():frame()
	local dif = win:frame().w - 0.5*max.w
	return (dif > -15 and dif < 15) -- leeway for some apps
end

--------------------------------------------------------------------------------
-- SIDEBARS

-- requires these two helper actions for Drafts installed:
-- https://directory.getdrafts.com/a/2BS & https://directory.getdrafts.com/a/2BR
function toggleDraftsSidebar (draftsWin)
	local function toggle ()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		if (drafts_w / screen_w > 0.6) then
			openLinkInBackground("drafts://x-callback-url/runAction?text=&action=show-sidebar")
		else
			openLinkInBackground("drafts://x-callback-url/runAction?text=&action=hide-sidebar")
		end
	end
	runDelayed(0.05, toggle)
	runDelayed(0.2, toggle) -- repetition for some rare cases with lag needed
end

function toggleHighlightsSidebar (highlightsWin)
	runDelayed(0.3, function ()
		local highlights_w = highlightsWin:frame().w
		local screen_w = highlightsWin:screen():frame().w
		local highlightsApp = hs.application("Highlights")
		highlightsApp:activate()
		if (highlights_w / screen_w > 0.6) then
			highlightsApp:selectMenuItem({"View", "Show Sidebar"})
		else
			highlightsApp:selectMenuItem({"View", "Hide Sidebar"})
		end
	end)
end

-- requires Obsidian Sidebar Toggler Plugin
-- https://github.com/chrisgrieser/obsidian-sidebar-toggler
function toggleObsidianSidebar (obsiWin)
	local function toggle ()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if (numberOfObsiWindows > 1) then return end -- prevent popout window resizing to affect sidebars
		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w
		if (obsi_width / screen_width > 0.6) then
			openLinkInBackground("obsidian://sidebar?showLeft=true&showRight=false")
		else
			openLinkInBackground("obsidian://sidebar?showLeft=false&showRight=false")
		end
	end
	runDelayed(0.05, toggle)
	runDelayed(0.2, toggle)
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

function moveResizeCurWin(mode)
	local win = hs.window.focusedWindow()
	local position

	if (mode == "left") then
		position = hs.layout.left50
	elseif (mode == "right") then
		position = hs.layout.right50
	elseif (mode == "up") then
		position = {x=0, y=0, w=1, h=0.5}
	elseif (mode == "down") then
		position = {x=0, y=0.5, w=1, h=0.5}
	elseif (mode == "pseudo-maximized") then
		position = pseudoMaximized
	elseif (mode == "maximized") then
		position = maximized
	elseif (mode == "centered") then
		position = {x=0.2, y=0.1, w=0.6, h=0.8}
	end

	moveResize(win, position) -- workaround for https://github.com/Hammerspoon/hammerspoon/issues/2316

	if win:application():name() == "Drafts" then toggleDraftsSidebar(win)
	elseif win:application():name() == "Obsidian" then toggleObsidianSidebar(win)
	elseif win:application():name() == "Highlights" then toggleHighlightsSidebar(win)
	end

	if mode == "pseudo-maximized" then
		hs.application("Twitterrific"):mainWindow():raise()
	end

end

-- replaces `win:moveToUnit(pos)`
function moveResize(win, pos)
	win:moveToUnit(pos)
	-- has to repeat due window creation delay for some apps
	runDelayed(0.25, function () win:moveToUnit(pos) end):start()
	runDelayed(0.5, function () win:moveToUnit(pos) end):start()
end

function moveToOtherDisplay ()
	local win = hs.window.focusedWindow()
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	-- workaround for ensuring proper resizing
	runDelayed(0.25, function ()
		win_ = hs.window.focusedWindow()
		win_:setFrameInScreenBounds(win_:frame())
	end)
end

--------------------------------------------------------------------------------
-- HOTKEYS
function controlSpace ()
	if frontapp() == "Finder" or frontapp() == "Script Editor" then
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
hotkey({}, "f6", moveToOtherDisplay) -- for apple keyboard
hotkey(hyper, "pagedown", moveToOtherDisplay)
hotkey(hyper, "pageup", moveToOtherDisplay)
hotkey({"ctrl"}, "space", controlSpace) -- fn+space also bound to ctrl+space via Karabiner


