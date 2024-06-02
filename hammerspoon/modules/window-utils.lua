local M = {} -- persist from garbage collector

local env = require("modules.environment-vars")
local u = require("modules.utils")

local hotkey = hs.hotkey.bind
local wf = hs.window.filter
--------------------------------------------------------------------------------

M.iMacDisplay = hs.screen("Built%-in")
M.maximized = hs.layout.maximized
M.pseudoMax = { x = 0.184, y = 0, w = 0.817, h = 1 }
M.center = { x = 0.184, y = 0, w = 0.6, h = 1 }
M.centerThird = { x = 0.34, y = 0, w = 0.66, h = 1 }

-- negative x to hide useless sidebar
if env.isAtMother then
	M.toTheSide = hs.geometry.rect(-78, 54, 387, 890)
elseif env.isAtOffice then
	M.toTheSide = hs.geometry.rect(-94, 54, 471, 1100)
else
	M.toTheSide = hs.geometry.rect(-92, 54, 446, 1026)
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

---@param win hs.window
---@param relSize hs.geometry
---@nodiscard
---@return boolean|nil nil if no win
function M.checkSize(win, relSize)
	if not win then return end
	local maxf = win:screen():frame()
	local winf = win:frame()
	local diffw = winf.w - relSize.w * maxf.w
	local diffh = winf.h - relSize.h * maxf.h
	local diffx = relSize.x * maxf.w + maxf.x - winf.x -- calculated this way for two screens
	local diffy = relSize.y * maxf.h + maxf.y - winf.y

	local leeway = 5 -- CONFIG e.g., terminal cell widths creating some minor inprecision
	local widthOkay = (diffw > -leeway and diffw < leeway)
	local heightOkay = (diffh > -leeway and diffh < leeway)
	local posyOkay = (diffy > -leeway and diffy < leeway)
	local posxOkay = (diffx > -leeway and diffx < leeway)

	return widthOkay and heightOkay and posxOkay and posyOkay
end

---@param win hs.window
---@param pos hs.geometry
function M.moveResize(win, pos)
	-- GUARD
	local appsToIgnore = { "Transmission", "Hammerspoon", "Mona" }
	if
		not win
		or not (win:application())
		or hs.fnutils.contains(appsToIgnore, win:application():name()) ---@diagnostic disable-line: undefined-field
		or not win:isMaximizable()
		or not win:isStandard()
	then
		return
	end

	-- resize with safety redundancy
	u.runWithDelays({ 0, 0.45, 0.9 }, function()
		if M.checkSize(win, pos) then return end
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

---automatically apply per-app auto-tiling of the windows of the app
---@param winSrc hs.window.filter|"Finder" source for the windows; windowfilter or
---appname. If this function is not triggered by a windowfilter event, the window
---filter does not contain any windows, therefore we need to get the windows from
---the appObj instead in those cases
function M.autoTile(winSrc)
	local isMultiscreen = #(hs.screen.allScreens()) > 1
	if isMultiscreen then return end
	if M.AutoTileInProgress then return end

	local wins = {}
	if type(winSrc) == "string" then
		-- cannot use windowfilter, since it's empty when not called from a
		-- window filter subscription
		local app = u.app(winSrc)
		if not app then return end
		wins = app:allWindows()
	else
		wins = winSrc:getWindows()
	end
	-- prevent autotiling of special windows, e.g. copy progress or info wins
	wins = hs.fnutils.filter(wins, function(win)
		local rejectTitles = { "Move", "Copy", "Delete", "Finder Settings" }
		return win:isStandard()
			and not hs.fnutils.contains(rejectTitles, win:title())
			and not win:title():find(" Info$")
	end)
	if not wins then return end

	-----------------------------------------------------------------------------

	M.bringAllWinsToFront()

	M.autoTileInProgress = true
	u.runWithDelays(0.2, function() M.autoTileInProgress = false end)
	local pos = {}

	if #wins == 0 and u.isFront("Finder") then
		-- hide finder when no windows (delay needed for quitting fullscreen apps,
		-- which are sometimes counted as finder windows)
		u.runWithDelays(0.2, function()
			if #(u.app("Finder"):allWindows()) > 0 or env.isProjector() then return end
			u.app("Finder"):hide()
		end)
	elseif #wins == 1 then
		if env.isProjector() then
			pos[1] = M.maximized
		elseif u.isFront("Finder") then
			pos[1] = M.center
		else
			pos[1] = M.pseudoMax
		end
	elseif #wins == 2 then
		pos = { hs.layout.left50, hs.layout.right50 }
	elseif #wins == 3 then
		pos = {
			{ h = 1, w = 0.33, x = 0, y = 0 },
			{ h = 1, w = 0.34, x = 0.33, y = 0 },
			{ h = 1, w = 0.33, x = 0.67, y = 0 },
		}
	elseif #wins == 4 then
		pos = {
			{ h = 0.5, w = 0.5, x = 0, y = 0 },
			{ h = 0.5, w = 0.5, x = 0, y = 0.5 },
			{ h = 0.5, w = 0.5, x = 0.5, y = 0 },
			{ h = 0.5, w = 0.5, x = 0.5, y = 0.5 },
		}
	elseif #wins == 5 or #wins == 6 then
		pos = {
			{ h = 0.5, w = 0.33, x = 0, y = 0 },
			{ h = 0.5, w = 0.33, x = 0, y = 0.5 },
			{ h = 0.5, w = 0.33, x = 0.33, y = 0 },
			{ h = 0.5, w = 0.33, x = 0.33, y = 0.5 },
			{ h = 0.5, w = 0.33, x = 0.66, y = 0 },
		}
		if #wins == 6 then table.insert(pos, { h = 0.5, w = 0.33, x = 0.66, y = 0.5 }) end
	end

	-- Do not autotile when windows are already tiled but not in the order of the
	-- wins[], to prevent windows glitching around. (wins[] is ordered by order
	-- of the window being front.)
	local existingPositions = 0
	for _, position in pairs(pos) do
		local thisPositionExists = false
		for _, win in pairs(wins) do
			if not thisPositionExists and M.checkSize(win, position) then thisPositionExists = true end
		end
		if thisPositionExists then existingPositions = existingPositions + 1 end
	end
	if existingPositions == #pos and #wins == #pos then return end

	for i = 1, #pos, 1 do
		M.moveResize(wins[i], pos[i])
	end
end

--------------------------------------------------------------------------------

-- Open Apps always at Mouse Screen
M.wf_appsOnMouseScreen = wf.new({
	"Mimestream",
	"Obsidian",
	"Finder",
	"WezTerm",
	"Hammerspoon",
	"System Settings",
	"Discord",
	"neovide",
	"espanso",
	"BusyCal",
	"Alfred Preferences",
	"Brave Browser",
	table.unpack(env.videoAndAudioApps), -- must be last for all items to be unpacked
}):subscribe(wf.windowCreated, function(newWin)
	local mouseScreen = hs.mouse.getCurrentScreen()
	if not mouseScreen or not env.isProjector() then return end
	local alreadyOnMouseScreen = newWin:screen():name() == mouseScreen:name()
	if not alreadyOnMouseScreen then newWin:moveToScreen(mouseScreen) end
end)

--------------------------------------------------------------------------------
-- HOTKEY ACTIONS

local function controlSpaceAction()
	local curWin = hs.window.focusedWindow()

	local pos
	if u.isFront { "Finder", "Script Editor", "Reminders" } then
		pos = M.checkSize(curWin, M.center) and M.maximized or M.center
	elseif u.isFront("System Settings") then
		pos = M.centerThird
	else
		pos = M.checkSize(curWin, M.pseudoMax) and M.maximized or M.pseudoMax
	end

	M.moveResize(curWin, pos)
end

local function moveWinToNextDisplay()
	if #hs.screen.allScreens() < 2 then return end
	local win = hs.window.focusedWindow()
	if not win then return end
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	local frame = win:frame()
	u.runWithDelays({ 0.1, 0.4 }, function()
		win = hs.window.focusedWindow()
		if win then win:setFrameInScreenBounds(frame) end
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

--------------------------------------------------------------------------------

-- Triggers: Hotkeys & URI Scheme
hotkey(u.hyper, "M", moveWinToNextDisplay)
hotkey({ "ctrl" }, "space", controlSpaceAction) -- fn+space also bound to ctrl+space via Karabiner

-- stylua: ignore start
hotkey(u.hyper, "right", function() M.moveResize(hs.window.focusedWindow(), hs.layout.right50) end)
hotkey(u.hyper, "left", function() M.moveResize(hs.window.focusedWindow(), hs.layout.left50) end)
hotkey(u.hyper, "down", function() M.moveResize(hs.window.focusedWindow(), { x = 0, y = 0.5, w = 1, h = 0.5 }) end)
hotkey(u.hyper, "up", function() M.moveResize(hs.window.focusedWindow(), { x = 0, y = 0, w = 1, h = 0.5 }) end)
-- stylua: ignore end

-- for adding to Shortcuts.app
hs.urlevent.bind("move-all-wins-to-projector", moveAllWinsToProjectorScreen)

--------------------------------------------------------------------------------
return M
