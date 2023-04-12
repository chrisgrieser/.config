local M = {}

local u = require("lua.utils")
--------------------------------------------------------------------------------

M.iMacDisplay = hs.screen("Built%-in")
M.maximized = hs.layout.maximized
M.pseudoMax = { x = 0.184, y = 0, w = 0.817, h = 1 }
M.centered = { x = 0.184, y = 0, w = 0.6, h = 1 }
M.toTheSide = hs.geometry.rect(-70.0, 54.0, 425.0, 1026.0) -- negative x to hide useless sidebar
if u.isAtMother() then M.toTheSide = hs.geometry.rect(-70.0, 54.0, 380.0, 890.0) end

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
-- OBSIDIAN SIDEBAR

---@param obsiWin hs.window
local function toggleObsidianSidebar(obsiWin)
	u.runWithDelays({ 0.05, 0.2 }, function()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if numberOfObsiWindows > 1 then return end -- prevent popout window resizing to affect sidebars

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w

		-- half -> hide right sidebar
		-- pseudo-maximized -> show right sidebar
		-- max -> show both sidebars
		local modeRight = (obsi_width / screen_width > 0.6) and "expand" or "collapse"
		u.openLinkInBg(
			"obsidian://advanced-uri?eval=this.app.workspace.rightSplit." .. modeRight .. "%28%29"
		)
		local modeLeft = (obsi_width / screen_width > 0.99) and "expand" or "collapse"
		u.openLinkInBg(
			"obsidian://advanced-uri?eval=this.app.workspace.leftSplit." .. modeLeft .. "%28%29"
		)
	end)
end

---ensures Obsidian windows are always shown when developing, mostly for developing CSS
---@param win hs.window
---@param pos hs.geometry
local function obsidianThemeDevHelper(win, pos)
	if
		not win
		or not win:application()
		or not (win:application():name():lower() == "neovide")
		or not (pos == M.pseudoMax or pos == M.maximized)
		or not u.appRunning("Obsidian")
	then
		return
	end
	u.runWithDelays(0.15, function()
		u.app("Obsidian"):unhide()
		u.app("Obsidian"):mainWindow():raise()
	end)
end

--------------------------------------------------------------------------------
-- TWITTER

function M.twitterToTheSide()
	-- in case of active split, prevent left window of covering the sketchybar
	if LEFT_SPLIT and LEFT_SPLIT:application() then LEFT_SPLIT:application():hide() end

	if u.isFront("Alfred") then return end

	local app = u.app("Twitter")
	if not app then return end

	if app:isHidden() then app:unhide() end

	-- not using mainWindow to not unintentionally move Media or new-tweet window
	local win = app:findWindow("Twitter")
	if not win then return end

	win:raise()
	win:setFrame(M.toTheSide)
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

---@param win hs.window
---@param size hs.geometry
---@nodiscard
---@return boolean|nil whether win has the given size. returns nil for invalid win
function M.CheckSize(win, size)
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
	local diffw = winf.w - size.w * maxf.w
	local diffh = winf.h - size.h * maxf.h
	local diffx = size.x * maxf.w + maxf.x - winf.x -- calculated this way for two screens
	local diffy = size.y * maxf.h + maxf.y - winf.y

	local leeway = 5 -- terminal cell widths creating some imprecision
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
	if not win or not win:application() or win:title() == "Quick Look" or win:title() == "qlmanage" then
		return
	end
	local appsToIgnore =
		{ "System Settings", "Twitter", "Transmission", "Alfred", "Hammerspoon", "CleanShot X" }
	local appName = win:application():name()
	if u.tbl_contains(appsToIgnore, appName) then
		u.notify("⚠️ " .. appName .. " cannot be resized properly.")
		return
	end

	-- Twitter Extras
	if pos == M.pseudoMax or pos == M.centered then
		M.twitterToTheSide()
	elseif pos == M.maximized and u.appRunning("Twitter") then
		if u.app("Twitter") then u.app("Twitter"):hide() end
	end

	-- resize
	-- check for false, since non-resizable wins return nil
	if M.CheckSize(win, pos) == false then win:moveToUnit(pos) end

	-- Obsidian extras (has to come after resizing)
	if win:application():name() == "Obsidian" then toggleObsidianSidebar(win) end
	obsidianThemeDevHelper(win, pos)
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
	local wins = {}
	if type(winSrc) == "string" then
		-- cannot use windowfilter, since it's empty when not called from a
		-- window filter subscription
		for _, finderWin in pairs(u.app("Finder"):allWindows()) do
			local rejected = false
			for _, bannedTitle in pairs(M.rejectedFinderWins) do
				if finderWin:title():find(bannedTitle) then rejected = true end
			end
			if not rejected then table.insert(wins, finderWin) end
		end
	else
		wins = winSrc:getWindows()
	end

	if #wins > 1 then M.bringAllWinsToFront() end

	if #wins == 0 and u.isFront("Finder") and not (u.isProjector()) then
		-- hide finder when no windows
		u.runWithDelays(0.1, function()
			if #(u.app("Finder"):allWindows()) == 0 then u.app("Finder"):hide() end
		end)
	elseif #wins == 1 then
		local pos
		if u.isProjector() then
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
	elseif #wins == 5 then
		M.moveResize(wins[1], { h = 0.5, w = 0.5, x = 0, y = 0 })
		M.moveResize(wins[2], { h = 0.5, w = 0.5, x = 0, y = 0.5 })
		M.moveResize(wins[3], { h = 0.5, w = 0.5, x = 0.5, y = 0 })
		M.moveResize(wins[4], { h = 0.5, w = 0.5, x = 0.5, y = 0.5 })
		M.moveResize(wins[5], { h = 0.5, w = 0.5, x = 0.25, y = 0.25 })
	elseif #wins == 6 then
		M.moveResize(wins[1], { h = 0.5, w = 0.33, x = 0, y = 0 })
		M.moveResize(wins[2], { h = 0.5, w = 0.33, x = 0, y = 0.5 })
		M.moveResize(wins[3], { h = 0.5, w = 0.33, x = 0.33, y = 0 })
		M.moveResize(wins[4], { h = 0.5, w = 0.33, x = 0.33, y = 0.5 })
		M.moveResize(wins[5], { h = 0.5, w = 0.33, x = 0.66, y = 0 })
		M.moveResize(wins[6], { h = 0.5, w = 0.33, x = 0.66, y = 0.5 })
	end
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
		if not (u.isProjector()) or mouseScreen:name() == screenOfWindow:name() then return end

		local appn = newWin:application():name()
		u.runWithDelays({ 0, 0.2, 0.5, 0.8, 1.1 }, function()
			if mouseScreen:name() ~= screenOfWindow:name() then newWin:moveToScreen(mouseScreen) end

			if appn == "Finder" or appn == "Script Editor" then
				M.moveResize(newWin, M.centered)
			else
				M.moveResize(newWin, M.maximized)
			end
		end)
	end)

--------------------------------------------------------------------------------
-- HOTKEY ACTIONS

local function controlSpaceAction()
	if u.isFront("SideNotes") then
		ToggleSideNotesSize()
		return
	end
	local currentWin = hs.window.focusedWindow()
	local pos
	if u.isFront { "Finder", "Script Editor" } then
		pos = M.centered
	elseif not M.CheckSize(currentWin, M.pseudoMax) then
		pos = M.pseudoMax
	else
		pos = M.maximized
	end
	M.moveResize(currentWin, pos)
end

local function moveCurWinToOtherDisplay()
	local win = hs.window.focusedWindow()
	if not win then return end
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	u.runWithDelays({ 0.1, 0.4 }, function()
		-- workaround for ensuring proper resizing
		win = hs.window.focusedWindow()
		if not win then return end
		win:setFrameInScreenBounds(win:frame())
	end)
end

local function homeAction()
	if #(hs.screen.allScreens()) > 1 then
		moveCurWinToOtherDisplay()
	elseif u.appRunning("zoom.us") then
		hs.alert("🔈/🔇") -- toggle mute
		u.keystroke({ "shift", "command" }, "A", 1, u.app("zoom.us"))
	end
end

local function endAction()
	if #(hs.screen.allScreens()) > 1 then
		moveCurWinToOtherDisplay()
	elseif u.appRunning("zoom.us") then
		hs.alert("📹") -- toggle video
		u.keystroke({ "shift", "command" }, "V", 1, u.app("zoom.us"))
	else
		hs.alert("<Nop>")
	end
end

--------------------------------------------------------------------------------
-- HOTKEYS
u.hotkey({}, "home", homeAction)
u.hotkey({}, "end", endAction)
u.hotkey(u.hyper, "right", function() M.moveResize(hs.window.focusedWindow(), hs.layout.right50) end)
u.hotkey(u.hyper, "left", function() M.moveResize(hs.window.focusedWindow(), hs.layout.left50) end)
-- stylua: ignore start
u.hotkey(u.hyper, "down", function() M.moveResize(hs.window.focusedWindow(), { x = 0, y = 0.5, w = 1, h = 0.5 }) end)
u.hotkey(u.hyper, "up", function() M.moveResize(hs.window.focusedWindow(), { x = 0, y = 0, w = 1, h = 0.5 }) end)
-- stylua: ignore end
u.hotkey({ "ctrl" }, "space", controlSpaceAction) -- fn+space also bound to ctrl+space via Karabiner

--------------------------------------------------------------------------------
return M
