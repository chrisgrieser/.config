require("lua.utils")
require("lua.twitter")
--------------------------------------------------------------------------------

IMacDisplay = hs.screen("Built%-in")
Maximized = hs.layout.maximized
RightHalf = hs.layout.right50
LeftHalf = hs.layout.left50
TopHalf = { x = 0, y = 0, w = 1, h = 0.5 }
BottomHalf = { x = 0, y = 0.5, w = 1, h = 0.5 }
PseudoMaximized = { x = 0.184, y = 0, w = 0.817, h = 1 }
Centered = { x = 0.184, y = 0, w = 0.6, h = 1 }
ToTheSide = hs.geometry.rect(-70.0, 54.0, 425.0, 1026.0) -- negative x to hide useless sidebar
if IsAtMother() then ToTheSide = hs.geometry.rect(-70.0, 54.0, 380.0, 890.0) end

RejectedFinderWindows = {
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
	RunWithDelays({ 0.05, 0.2 }, function()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if numberOfObsiWindows > 1 then return end -- prevent popout window resizing to affect sidebars

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w

		-- half -> hide right sidebar
		-- pseudo-maximized -> show right sidebar
		-- max -> show both sidebars
		local modeRight = (obsi_width / screen_width > 0.6) and "expand" or "collapse"
		OpenLinkInBackground(
			"obsidian://advanced-uri?eval=this.app.workspace.rightSplit." .. modeRight .. "%28%29"
		)
		local modeLeft = (obsi_width / screen_width > 0.99) and "expand" or "collapse"
		OpenLinkInBackground(
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
		or not win:application():name():lower() == "neovide"
		or not (pos == PseudoMaximized or pos == Maximized)
		or not AppRunning("Obsidian")
	then
		return
	end
	RunWithDelays(0.15, function()
		App("Obsidian"):unhide()
		App("Obsidian"):mainWindow():raise()
	end)
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

---@param win hs.window
---@param size hs.geometry
---@nodiscard
---@return boolean|nil whether win has the given size. returns nil for invalid win
function CheckSize(win, size)
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
	if not win or TableContains(invalidWinsByTitle, win:title()) then return nil end

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
function MoveResize(win, pos)
	-- guard clauses
	if not win or not win:application() or win:title() == "Quick Look" or win:title() == "qlmanage" then
		return
	end
	local appsToIgnore =
		{ "System Settings", "Twitter", "Transmission", "Alfred", "Hammerspoon", "CleanShot X" }
	local appName = win:application():name()
	if TableContains(appsToIgnore, appName) then
		Notify("⚠️ " .. appName .. " cannot be resized properly.")
		return
	end

	-- Twitter Extras
	if pos == PseudoMaximized or pos == Centered then
		TwitterToTheSide()
	elseif pos == Maximized and AppRunning("Twitter") then
		if App("Twitter") then App("Twitter"):hide() end
	end

	-- resize
	local function resize(_win, _pos)
		if CheckSize(_win, _pos) ~= false then return end -- check for unequal false, since non-resizable wins return nil
		_win:moveToUnit(_pos)
	end
	resize(win, pos)

	-- Obsidian extras (has to come after resizing)
	if win:application():name() == "Obsidian" then toggleObsidianSidebar(win) end
	obsidianThemeDevHelper(win, pos)
end

--------------------------------------------------------------------------------
-- WINDOW TILING (OF SAME APP)

---bring all windows of front app to the front
function BringAllWinsToFront()
	local app = hs.application.frontmostApplication()
	if #app:allWindows() < 2 then return end -- the occasional faulty creation of task manager windows in Browser
	app:selectMenuItem { "Window", "Bring All to Front" }
end

---automatically apply per-app auto-tiling of the windows of the app
---@param winSrc hs.window.filter|"Finder" source for the windows; windowfilter or
---appname. If this function is not triggered by a windowfilter event, the window
---filter does not contain any windows, therefore we need to get the windows from
---the appObj instead in those cases
function AutoTile(winSrc)
	local wins = {}
	if type(winSrc) == "string" then
		-- cannot use windowfilter, since it's empty when not called from a
		-- window filter subscription
		for _, finderWin in pairs(App("Finder"):allWindows()) do
			local rejected = false
			for _, bannedTitle in pairs(RejectedFinderWindows) do
				if finderWin:title():find(bannedTitle) then rejected = true end
			end
			if not rejected then table.insert(wins, finderWin) end
		end
	else
		wins = winSrc:getWindows()
	end

	if #wins > 1 then BringAllWinsToFront() end

	if #wins == 0 and IsFront("Finder") then
		-- hide finder when no windows
		RunWithDelays(0.1, function()
			if #(App("Finder"):allWindows()) == 0 then App("Finder"):hide() end
		end)
	elseif #wins == 1 then
		local pos
		if IsProjector() then
			pos = Maximized
		elseif IsFront("Finder") then
			pos = Centered
		else
			pos = PseudoMaximized
		end
		MoveResize(wins[1], pos)
	elseif #wins == 2 then
		MoveResize(wins[1], LeftHalf)
		MoveResize(wins[2], RightHalf)
	elseif #wins == 3 then
		MoveResize(wins[1], { h = 1, w = 0.33, x = 0, y = 0 })
		MoveResize(wins[2], { h = 1, w = 0.34, x = 0.33, y = 0 })
		MoveResize(wins[3], { h = 1, w = 0.33, x = 0.67, y = 0 })
	elseif #wins == 4 then
		MoveResize(wins[1], { h = 0.5, w = 0.5, x = 0, y = 0 })
		MoveResize(wins[2], { h = 0.5, w = 0.5, x = 0, y = 0.5 })
		MoveResize(wins[3], { h = 0.5, w = 0.5, x = 0.5, y = 0 })
		MoveResize(wins[4], { h = 0.5, w = 0.5, x = 0.5, y = 0.5 })
	elseif #wins == 5 then
		MoveResize(wins[1], { h = 0.5, w = 0.5, x = 0, y = 0 })
		MoveResize(wins[2], { h = 0.5, w = 0.5, x = 0, y = 0.5 })
		MoveResize(wins[3], { h = 0.5, w = 0.5, x = 0.5, y = 0 })
		MoveResize(wins[4], { h = 0.5, w = 0.5, x = 0.5, y = 0.5 })
		MoveResize(wins[5], { h = 0.5, w = 0.5, x = 0.25, y = 0.25 })
	elseif #wins == 6 then
		MoveResize(wins[1], { h = 0.5, w = 0.33, x = 0, y = 0 })
		MoveResize(wins[2], { h = 0.5, w = 0.33, x = 0, y = 0.5 })
		MoveResize(wins[3], { h = 0.5, w = 0.33, x = 0.33, y = 0 })
		MoveResize(wins[4], { h = 0.5, w = 0.33, x = 0.33, y = 0.5 })
		MoveResize(wins[5], { h = 0.5, w = 0.33, x = 0.66, y = 0 })
		MoveResize(wins[6], { h = 0.5, w = 0.33, x = 0.66, y = 0.5 })
	end
end

--------------------------------------------------------------------------------

-- Open Apps always at Mouse Screen
Wf_appsOnMouseScreen = Wf.new({
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
}):subscribe(Wf.windowCreated, function(newWin)
	local mouseScreen = hs.mouse.getCurrentScreen()
	if not mouseScreen then return end
	local screenOfWindow = newWin:screen()
	if not (IsProjector()) or mouseScreen:name() == screenOfWindow:name() then return end

	local appn = newWin:application():name()
	RunWithDelays({ 0.2, 1, 1.5 }, function()
		if mouseScreen:name() ~= screenOfWindow:name() then newWin:moveToScreen(mouseScreen) end

		if appn == "Finder" or appn == "Script Editor" or appn == "Hammerspoon" then
			MoveResize(newWin, Centered)
		else
			MoveResize(newWin, Maximized)
		end
	end)
end)

--------------------------------------------------------------------------------
-- HOTKEY ACTIONS

local function controlSpaceAction()
	local currentWin = hs.window.focusedWindow()
	local pos
	if IsFront { "Finder", "Script Editor" } then
		pos = Centered
	elseif IsFront("SideNotes") then
		ToggleSideNotesSize()
		return
	elseif not CheckSize(currentWin, PseudoMaximized) then
		pos = PseudoMaximized
	else
		pos = Maximized
	end
	MoveResize(currentWin, pos)
end

local function moveCurWinToOtherDisplay()
	local win = hs.window.focusedWindow()
	if not win then return end
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	RunWithDelays({ 0.1, 0.4 }, function()
		-- workaround for ensuring proper resizing
		win = hs.window.focusedWindow()
		if not win then return end
		win:setFrameInScreenBounds(win:frame())
	end)
end

local function homeAction()
	if #(hs.screen.allScreens()) > 1 then
		moveCurWinToOtherDisplay()
	elseif AppRunning("zoom.us") then
		hs.alert("🔈/🔇") -- toggle mute
		Keystroke({ "shift", "command" }, "A", 1, App("zoom.us"))
	else
		TwitterScrollUp()
	end
end

local function endAction()
	if #(hs.screen.allScreens()) > 1 then
		moveCurWinToOtherDisplay()
	elseif AppRunning("zoom.us") then
		hs.alert("📹") -- toggle video
		Keystroke({ "shift", "command" }, "V", 1, App("zoom.us"))
	else
		hs.alert("<Nop>")
	end
end

--------------------------------------------------------------------------------
-- HOTKEYS

Hotkey({}, "home", homeAction)
Hotkey({}, "end", endAction)
Hotkey(Hyper, "right", function() MoveResize(hs.window.focusedWindow(), RightHalf) end)
Hotkey(Hyper, "left", function() MoveResize(hs.window.focusedWindow(), LeftHalf) end)
Hotkey(Hyper, "down", function() MoveResize(hs.window.focusedWindow(), BottomHalf) end)
Hotkey(Hyper, "up", function() MoveResize(hs.window.focusedWindow(), TopHalf) end)
Hotkey({ "ctrl" }, "space", controlSpaceAction) -- fn+space also bound to ctrl+space via Karabiner
