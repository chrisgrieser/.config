require("utils")
require("twitterrific-controls")
require("private")

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT UTILS
maximized = hs.layout.maximized
iMacDisplay = hs.screen("Built%-in") -- % to escape hyphen (is a quantifier in lua patterns)

-- device-specific parameters
if (isIMacAtHome()) then
	pseudoMaximized = {x=0, y=0, w=0.815, h=1}
	baseLayout = pseudoMaximized
elseif isAtMother then
	pseudoMaximized = {x=0, y=0, w=0.7875, h=1}
	baseLayout = pseudoMaximized
elseif isAtOffice() then
	baseLayout = maximized
end

-- window size checks
function isPseudoMaximized (win)
	if not(win) then return false end
	local max = hs.screen.mainScreen():frame()
	local dif = win:frame().w - pseudoMaximized.w*max.w
	local widthOkay = (dif > -15 and dif < 15) -- leeway for some apps
	return widthOkay
end

function isHalf (win)
	if not(win) then return false end
	local max = hs.screen.mainScreen():frame()
	local dif = win:frame().w - 0.5*max.w
	return (dif > -15 and dif < 15) -- leeway for some apps
end

--------------------------------------------------------------------------------
-- SIDEBARS

-- requires these two actions beeing installed:
-- https://directory.getdrafts.com/a/2BS & https://directory.getdrafts.com/a/2BR
function toggleDraftsSidebar (draftsWin)
	runDelayed(0.05, function ()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		if (drafts_w / screen_w > 0.6) then
			-- using URI scheme since they are more reliable than the menu item
			hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=show-sidebar")
		else
			hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=hide-sidebar")
		end
	end)
	-- repetitation for some rare cases with lag needed
	runDelayed(0.2, function ()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		if (drafts_w / screen_w > 0.6) then
			hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=show-sidebar")
		else
			hs.urlevent.openURL("drafts://x-callback-url/runAction?text=&action=hide-sidebar")
		end
	end)
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
	runDelayed(0.05, function ()
		-- prevent popout window resizing to affect sidebars
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if (numberOfObsiWindows > 1) then return end

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w
		if (obsi_width / screen_width > 0.6) then
			hs.urlevent.openURL("obsidian://sidebar?showLeft=true&showRight=false")
		else
			hs.urlevent.openURL("obsidian://sidebar?showLeft=false&showRight=false")
		end
	end)
	runDelayed(0.2, function ()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if (numberOfObsiWindows > 1) then return end

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w
		if (obsi_width / screen_width > 0.6) then
			hs.urlevent.openURL("obsidian://sidebar?showLeft=true&showRight=false")
		else
			hs.urlevent.openURL("obsidian://sidebar?showLeft=false&showRight=false")
		end
	end)
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

function moveResizeCurWin(direction)
	local win = hs.window.focusedWindow()
	local position

	if (direction == "left") then
		position = hs.layout.left50
	elseif (direction == "right") then
		position = hs.layout.right50
	elseif (direction == "up") then
		position = {x=0, y=0, w=1, h=0.5}
	elseif (direction == "down") then
		position = {x=0, y=0.5, w=1, h=0.5}
	elseif (direction == "pseudo-maximized") then
		position = pseudoMaximized
	elseif (direction == "maximized") then
		position = maximized
	elseif (direction == "centered") then
		position = {x=0.2, y=0.1, w=0.6, h=0.8}
	end

	-- workaround for https://github.com/Hammerspoon/hammerspoon/issues/2316
	moveResize(win, position)

	if win:application():name() == "Drafts" then toggleDraftsSidebar(win)
	elseif win:application():name() == "Obsidian" then toggleObsidianSidebar(win)
	elseif win:application():name() == "Highlights" then toggleHighlightsSidebar(win)
	end
end

-- replaces `win:moveToUnit(pos)`
function moveResize(win, pos)
	win:moveToUnit(pos)
	-- has to repeat due to bug for some apps... >:(
	hs.timer.delayed.new(0.3, function () win:moveToUnit(pos) end):start()
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
hotkey(hyper, "pagedown", moveToOtherDisplay)
hotkey(hyper, "pageup", moveToOtherDisplay)
hotkey({"ctrl"}, "space", controlSpace)


