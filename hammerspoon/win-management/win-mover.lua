local M = {}

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
local wf = hs.window.filter
--------------------------------------------------------------------------------

-- CONFIG
local smallWinApps = {
	"Script Editor",
	"Reminders",
	"TextEdit",
	"System Settings",
	"Preview",
	"Finder",
}
local pseudoMaxApps = {
	"Microsoft Word",
	"Brave Browser",
	"Safari",
	"Neovide",
	"Slack",
	"Granola",
	"Obsidian",
	"zoom.us",
	"PDF Expert",
	"Highlights",
	"Signal",
	"Gmail",
	"Monodraw",
}

---AUTO-MOVEMENT AND AUTO-SIZING------------------------------------------------

-- one screen: always open windows pseudo-maximized
-- projector: always open windows maximized
M.wf_pseudoMax = wf.new(pseudoMaxApps)
	:setOverrideFilter({ fullscreen = false, rejectTitles = { "^Save$", "^Open$" } })
	:subscribe(wf.windowCreated, function(win)
		if require("win-management.auto-tile").winIsOfAutotileApp(win) then return end
		local size = env.isProjector() and hs.layout.maximized or wu.pseudoMax
		wu.moveResize(win, size)
	end)

M.wf_middle_half = wf.new(smallWinApps)
	:setOverrideFilter({ fullscreen = false, rejectTitles = { "^Save$", "^Open$" } })
	:subscribe(wf.windowCreated, function(win)
		if require("win-management.auto-tile").winIsOfAutotileApp(win) then return end
		wu.moveResize(win, wu.middleHalf)
	end)

-- If two screens, always move new windows to Mouse Screen
M.wf_appsOnMouseScreen = wf.new(true)
	:setOverrideFilter({ allowRoles = "AXStandardWindow", fullscreen = false })
	:subscribe(wf.windowCreated, function(newWin)
		if #hs.screen.allScreens() < 2 then return end
		local mouseScreen = hs.mouse.getCurrentScreen()
		if not mouseScreen then return end
		if newWin:screen():id() ~= mouseScreen:id() then newWin:moveToScreen(mouseScreen) end
	end)

---HOTKEYS----------------------------------------------------------------------
local function toggleMaximized()
	local frontWin = hs.window.focusedWindow()
	local frontApp = frontWin:application():name() ---@diagnostic disable-line: undefined-field

	if env.isProjector() then return wu.moveResize(frontWin, hs.layout.maximized) end
	if frontApp == "Mona" then return wu.moveResize(frontWin, wu.toTheSide) end

	local baseSize = hs.fnutils.contains(smallWinApps, frontApp) and wu.middleHalf or wu.pseudoMax
	local screen = frontWin:screen():frame()
	local isMaximized = frontWin:frame().w == screen.w and frontWin:frame().h == screen.h
	local newSize = isMaximized and baseSize or hs.layout.maximized
	wu.moveResize(frontWin, newSize)
end

local function moveToNextDisplay()
	if #hs.screen.allScreens() < 2 then
		hs.alert("Cannot move to next display since there is only one.", 3)
		return
	end
	local win = hs.window.focusedWindow()
	if not win then return end
	win:moveToScreen(win:screen():next(), true)
end

local function tileRight() wu.moveResize(hs.window.focusedWindow(), hs.layout.right50) end
local function tileLeft() wu.moveResize(hs.window.focusedWindow(), hs.layout.left50) end

hs.hotkey.bind({ "ctrl" }, "space", toggleMaximized)
hs.hotkey.bind(u.hyper, "M", moveToNextDisplay)
hs.hotkey.bind(u.hyper, "right", tileRight)
hs.hotkey.bind(u.hyper, "left", tileLeft)

--------------------------------------------------------------------------------
return M
