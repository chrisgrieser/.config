local M = {}
local u = require("meta.utils")
local env = require("meta.environment-vars")
local wu = require("win-management.window-utils")
--------------------------------------------------------------------------------

-- If two screens, always move new windows to Mouse Screen
M.wf_appsOnMouseScreen = hs.window.filter
	.new({
		"Mimestream",
		"Obsidian",
		"Finder",
		"WezTerm",
		"Hammerspoon",
		"System Settings",
		"Discord",
		"MacWhisper",
		"Neovide",
		"Calendar",
		"Alfred Preferences",
		"ClipBook",
		"BetterTouchTool",
		"Brave Browser",
		table.unpack(env.videoAndAudioApps), -- must be last for all items to be unpacked
	})
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

	local isSmallerApp = u.isFront { "Finder", "Script Editor", "Reminders", "ClipBook", "TextEdit" }
	local baseSize = isSmallerApp and wu.middleHalf or wu.pseudoMax
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
