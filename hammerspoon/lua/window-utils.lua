local M = {}

local env = require("lua.environment-vars")
local u = require("lua.utils")
--------------------------------------------------------------------------------

M.iMacDisplay = hs.screen("Built%-in")
M.maximized = hs.layout.maximized
M.pseudoMax = { x = 0.184, y = 0, w = 0.817, h = 1 }
M.centered = { x = 0.184, y = 0, w = 0.6, h = 1 }
M.sideNotesWide = { x = 0, y = 0, w = 0.4, h = 1 }
local sideNotesNarrow = { x = 0, y = 0, w = 0.2, h = 1 }

-- negative x to hide useless sidebar
if env.isAtMother then
	M.toTheSide = hs.geometry.rect(-70, 54, 380, 890)
elseif env.isAtOffice then
	M.toTheSide = hs.geometry.rect(-75, 54, 450, 1100)
else
	M.toTheSide = hs.geometry.rect(-70, 54, 425, 1026)
end

M.rejectedFinderWins = {
	"^Quick Look$",
	"^qlmanage$",
	"^Move$",
	"^Copy$",
	"^Bin$",
	"^Delete$",
	"^Finder Settings$",
	" Info$", -- Info window *end* with "Info"
	"^$", -- Desktop, which has no window title
	"^Alfred$", -- Alfred Compatibility Mode
}

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

---@param win hs.window
---@param relSize hs.geometry
---@nodiscard
---@return boolean|nil result whether win has the given size. returns nil for invalid win
function M.CheckSize(win, relSize)
	local invalidWinsByTitle = { -- windows which can/should not be resized
		"Copy", -- Finder
		"Move", -- Finder
		"Delete", -- Finder
		"Bin", -- Finder
		"System Settings",
		"Espanso",
		"Transmission",
		"CleanShot X",
		"Twitter",
		"Alfred",
		"Hammerspoon",
	}
	if not win or u.tbl_contains(invalidWinsByTitle, win:title()) then return nil end

	local maxf = win:screen():frame()
	local winf = win:frame()
	local diffw = winf.w - relSize.w * maxf.w
	local diffh = winf.h - relSize.h * maxf.h
	local diffx = relSize.x * maxf.w + maxf.x - winf.x -- calculated this way for two screens
	local diffy = relSize.y * maxf.h + maxf.y - winf.y

	local leeway = 5 -- terminal cell widths creating some minor inprecision
	local widthOkay = (diffw > -leeway and diffw < leeway)
	local heightOkay = (diffh > -leeway and diffh < leeway)
	local posyOkay = (diffy > -leeway and diffy < leeway)
	local posxOkay = (diffx > -leeway and diffx < leeway)

	return widthOkay and heightOkay and posxOkay and posyOkay
end

---@param win hs.window
---@param pos hs.geometry
function M.moveResize(win, pos)
	-- guard clauses
	local appsToIgnore =
		{ "System Settings", "Twitter", "Transmission", "Alfred", "Hammerspoon", "CleanShot X" }
	local appName = win:application():name()
	if not win or not win:application() or u.tbl_contains(appsToIgnore, appName) or win:title() == "Quick Look" or win:title() == "qlmanage" then
		return
	end

	-- resize with safety redundancy
	u.runWithDelays({ 0, 0.2, 0.4, 0.6, 0.8 }, function()
		-- check for false, since non-resizable wins return nil
		if M.CheckSize(win, pos) ~= false then return end
		win:moveToUnit(pos)
	end)
end

--------------------------------------------------------------------------------
-- WINDOW TILING (OF SAME APP)

---bring all windows of front app to the front
function M.bringAllWinsToFront()
	local app = hs.application.frontmostApplication()
	if #app:allWindows() < 2 then return end -- the occasional faulty creation of task manager windows in Browser
	app:selectMenuItem { "Window", "Bring All to Front" }
end

local autoTilingInProgress = false

---automatically apply per-app auto-tiling of the windows of the app
---@param winSrc hs.window.filter|"Finder" source for the windows; windowfilter or
---appname. If this function is not triggered by a windowfilter event, the window
---filter does not contain any windows, therefore we need to get the windows from
---the appObj instead in those cases
-- selene: allow(high_cyclomatic_complexity)
function M.autoTile(winSrc)
	-- prevent concurrent runs
	if autoTilingInProgress then return end

	local wins = {}
	if type(winSrc) == "string" then
		-- cannot use windowfilter, since it's empty when not called from a
		-- window filter subscription
		local finder = u.app("Finder")
		if not finder then return end
		for _, finderWin in pairs(finder:allWindows()) do
			local rejected = false
			for _, bannedTitle in pairs(M.rejectedFinderWins) do
				if finderWin:title():find(bannedTitle) then rejected = true end
			end
			if not rejected then table.insert(wins, finderWin) end
		end
	else
		wins = winSrc:getWindows()
	end

	autoTilingInProgress = true

	if #wins > 1 then M.bringAllWinsToFront() end

	if #wins == 0 and u.isFront("Finder") and not (env.isProjector()) then
		-- hide finder when no windows
		-- delay needed for quitting fullscreen apps, which are sometimes counted
		-- as finder windows (SIC)
		u.runWithDelays(0.2, function()
			if #(u.app("Finder"):allWindows()) == 0 then u.app("Finder"):hide() end
		end)
	elseif #wins == 1 then
		local pos
		if env.isProjector() then
			pos = M.maximized
		elseif u.isFront("Finder") then
			pos = M.centered
		else
			pos = M.pseudoMax
		end
		M.moveResize(wins[1], pos)
	elseif #wins == 2 then
		M.moveResize(wins[1], hs.layout.left50)
		M.moveResize(wins[2], hs.layout.right50)
	elseif #wins == 3 then
		M.moveResize(wins[1], { h = 1, w = 0.33, x = 0, y = 0 })
		M.moveResize(wins[2], { h = 1, w = 0.34, x = 0.33, y = 0 })
		M.moveResize(wins[3], { h = 1, w = 0.33, x = 0.67, y = 0 })
	elseif #wins == 4 then
		M.moveResize(wins[1], { h = 0.5, w = 0.5, x = 0, y = 0 })
		M.moveResize(wins[2], { h = 0.5, w = 0.5, x = 0, y = 0.5 })
		M.moveResize(wins[3], { h = 0.5, w = 0.5, x = 0.5, y = 0 })
		M.moveResize(wins[4], { h = 0.5, w = 0.5, x = 0.5, y = 0.5 })
	elseif #wins == 5 or #wins == 6 then
		M.moveResize(wins[1], { h = 0.5, w = 0.33, x = 0, y = 0 })
		M.moveResize(wins[2], { h = 0.5, w = 0.33, x = 0, y = 0.5 })
		M.moveResize(wins[3], { h = 0.5, w = 0.33, x = 0.33, y = 0 })
		M.moveResize(wins[4], { h = 0.5, w = 0.33, x = 0.33, y = 0.5 })
		M.moveResize(wins[5], { h = 0.5, w = 0.33, x = 0.66, y = 0 })
		if #wins == 6 then M.moveResize(wins[6], { h = 0.5, w = 0.33, x = 0.66, y = 0.5 }) end
	end
	u.runWithDelays(0.1, function() autoTilingInProgress = false end)
end

--------------------------------------------------------------------------------

-- Open Apps always at Mouse Screen
Wf_appsOnMouseScreen = u.wf
	.new({
		"Vivaldi",
		"Mimestream",
		"BetterTouchTool",
		"Obsidian",
		"Slack",
		"IINA",
		"WezTerm",
		"Hammerspoon",
		"System Settings",
		"Discord",
		"Neovide",
		"neovide",
		"Espanso",
		"BusyCal",
		"Alfred Preferences",
		"YouTube",
		"Netflix",
		"CrunchyRoll",
		"Finder",
	})
	:subscribe(u.wf.windowCreated, function(newWin)
		local mouseScreen = hs.mouse.getCurrentScreen()
		if not mouseScreen then return end
		local screenOfWindow = newWin:screen()
		if not (env.isProjector()) or mouseScreen:name() == screenOfWindow:name() then return end
		local app = newWin:application()
		if not app then return end

		u.runWithDelays({ 0, 0.2, 0.5, 0.8, 1.1 }, function()
			if mouseScreen:name() ~= screenOfWindow:name() then newWin:moveToScreen(mouseScreen) end

			if app:name() == "Finder" or app:name() == "Script Editor" then
				M.moveResize(newWin, M.centered)
			else
				M.moveResize(newWin, M.maximized)
			end
		end)
	end)

--------------------------------------------------------------------------------
-- HOTKEY ACTIONS

local function controlSpaceAction()
	local curWin = hs.window.focusedWindow()
	local pos

	if u.isFront("SideNotes") then
		local changeTo = M.CheckSize(curWin, M.sideNotesWide) and sideNotesNarrow or M.sideNotesWide
		M.moveResize(curWin, changeTo)
	elseif u.isFront { "Finder", "Script Editor" } then
		pos = M.CheckSize(curWin, M.centered) and M.maximized or M.centered
	else
		pos = M.CheckSize(curWin, M.pseudoMax) and M.maximized or M.pseudoMax
	end

	M.moveResize(curWin, pos)
end

local function moveCurWinToOtherDisplay()
	if #hs.screen.allScreens() < 2 then return end
	local win = hs.window.focusedWindow()
	if not win then return end
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	u.runWithDelays({ 0.1, 0.4, 0.7 }, function()
		-- workaround for ensuring proper resizing
		win = hs.window.focusedWindow()
		if not win then return end
		win:setFrameInScreenBounds(win:frame())
	end)
end

local function moveAllWinsToProjectorScreen()
	if #hs.screen.allScreens() < 2 then return end
	if not env.isProjector() then return end

	local projectorScreen = hs.screen.primaryScreen()
	for _, win in pairs(hs.window:orderedWindows()) do
		win:moveToScreen(projectorScreen, true)
		u.runWithDelays(0.1, function() win:setFrameInScreenBounds(win:frame()) end)
	end
end

local function endAction()
	if u.appRunning("zoom.us") then
		hs.alert("📹") -- toggle video
		u.keystroke({ "shift", "command" }, "V", 1, u.app("zoom.us"))
	elseif #(hs.screen.allScreens()) > 1 then
		moveCurWinToOtherDisplay()
	else
		hs.alert("<Nop>")
	end
end

--------------------------------------------------------------------------------
-- Triggers: Hotkeys & URI Scheme
u.hotkey({}, "end", endAction)
u.hotkey(u.hyper, "right", function() M.moveResize(hs.window.focusedWindow(), hs.layout.right50) end)
u.hotkey(u.hyper, "left", function() M.moveResize(hs.window.focusedWindow(), hs.layout.left50) end)
-- stylua: ignore start
u.hotkey(u.hyper, "down", function() M.moveResize(hs.window.focusedWindow(), { x = 0, y = 0.5, w = 1, h = 0.5 }) end)
u.hotkey(u.hyper, "up", function() M.moveResize(hs.window.focusedWindow(), { x = 0, y = 0, w = 1, h = 0.5 }) end)
-- stylua: ignore end
u.hotkey({ "ctrl" }, "space", controlSpaceAction) -- fn+space also bound to ctrl+space via Karabiner

-- for adding to Shortcuts.app
u.urischeme("move-all-wins-to-projector", moveAllWinsToProjectorScreen)

--------------------------------------------------------------------------------
return M
