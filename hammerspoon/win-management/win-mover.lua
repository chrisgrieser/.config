local M = {}

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")

local wf = hs.window.filter
--------------------------------------------------------------------------------

-- one screen: always open new pseudo-maximized
-- projector: always open new windows maximized
M.wf_pseudoMax = wf.new({
	"Microsoft Word",
	"Safari",
	"WezTerm",
	"Neovide",
	"Slack",
	"Obsidian",
	"zoom.us",
	"Preview",
	"Highlights",
	"Signal",
	"Karabiner-Elements",
})
	:setOverrideFilter({ fullscreen = false, rejectTitles = { "^Save$", "^Open$" } })
	:subscribe(wf.windowCreated, function(win)
		local size = env.isProjector() and hs.layout.maximized or wu.pseudoMax
		wu.moveResize(win, size)
	end)

--------------------------------------------------------------------------------

-- If two screens, always move new windows to Mouse Screen
M.wf_appsOnMouseScreen = wf.new(true)
	:setOverrideFilter({ allowRoles = "AXStandardWindow", fullscreen = false })
	:subscribe(wf.windowCreated, function(newWin)
		if #hs.screen.allScreens() < 2 then return end
		local mouseScreen = hs.mouse.getCurrentScreen()
		if not mouseScreen then return end
		if newWin:screen():id() ~= mouseScreen:id() then newWin:moveToScreen(mouseScreen) end
	end)

--------------------------------------------------------------------------------
-- ACTIONS

local function toggleMaximized()
	local currentWin = hs.window.focusedWindow()

	local smallerWins = { "Finder", "Script Editor", "Reminders", "TextEdit", "System Settings" }
	local baseSize = wu.pseudoMax
	if u.isFront(smallerWins) then baseSize = wu.middleHalf end
	if env.isProjector() then baseSize = hs.layout.maximized end

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
hs.hotkey.bind({ "ctrl" }, "space", function()
	if u.isFront("Ivory") then
		hs.window.focusedWindow():setFrame(wu.toTheSide) -- needs setFrame to hide part to the side
	else
		toggleMaximized()
	end
end)
hs.hotkey.bind(u.hyper, "M", moveToNextDisplay)
hs.hotkey.bind(u.hyper, "right", tileRight)
hs.hotkey.bind(u.hyper, "left", tileLeft)

--------------------------------------------------------------------------------
return M
