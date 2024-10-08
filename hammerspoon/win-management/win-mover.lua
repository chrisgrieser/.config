local M = {}
local u = require("meta.utils")
local wu = require("win-management.window-utils")
local wf = hs.window.filter
local env = require("meta.environment-vars")
--------------------------------------------------------------------------------

-- one screen: always open new pseudo-maximized
-- projector: always open new windows maximized
M.wf_pseudoMax = wf.new({
	"Brave Browser",
	"Safari",
	"WezTerm",
	"Neovide",
	"Discord",
	"Slack",
	"Obsidian",
	"Preview",
	"Highlights",
	"Karabiner-Elements",
}):subscribe(wf.windowCreated, function(win)
	local size = env.isProjector() and hs.layout.maximized or wu.pseudoMax
	wu.moveResize(win, size)
end)

--------------------------------------------------------------------------------

-- If two screens, always move new windows to Mouse Screen
M.wf_appsOnMouseScreen = wf.new(true)
	:setOverrideFilter({ allowRoles = "AXStandardWindow", fullscreen = false })
	:subscribe(hs.window.filter.windowCreated, function(newWin)
		if #hs.screen.allScreens() < 2 then return end
		local mouseScreen = hs.mouse.getCurrentScreen()
		if not mouseScreen then return end
		if newWin:screen():name() ~= mouseScreen:name() then newWin:moveToScreen(mouseScreen) end
	end)

--------------------------------------------------------------------------------
-- ACTIONS

local function toggleSize()
	local currentWin = hs.window.focusedWindow()

	local smallerWins = { "Finder", "Script Editor", "Reminders", "TextEdit", "System Settings" }
	local baseSize = u.isFront(smallerWins) and wu.middleHalf or wu.pseudoMax
	local newSize = wu.winHasSize(currentWin, baseSize) and hs.layout.maximized or baseSize

	wu.moveResize(currentWin, newSize)
end

local function moveToNextDisplay()
	if #hs.screen.allScreens() < 2 then return end
	local win = hs.window.focusedWindow()
	if not win then return end
	win:moveToScreen(win:screen():next(), true)
end

local function tileRight() wu.moveResize(hs.window.focusedWindow(), hs.layout.right50) end
local function tileLeft() wu.moveResize(hs.window.focusedWindow(), hs.layout.left50) end

--------------------------------------------------------------------------------
-- HOTKEYS
hs.hotkey.bind({ "ctrl" }, "space", toggleSize)
hs.hotkey.bind(u.hyper, "M", moveToNextDisplay)
hs.hotkey.bind(u.hyper, "right", tileRight)
hs.hotkey.bind(u.hyper, "left", tileLeft)

--------------------------------------------------------------------------------
return M
