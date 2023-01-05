require("lua.utils")

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT UTILS
iMacDisplay = hs.screen("Built%-in")
maximized = hs.layout.maximized
rightHalf = hs.layout.right50
leftHalf = hs.layout.left50

-- device-specific parameters
if isIMacAtHome() then
	pseudoMaximized = { x = 0.184, y = 0, w = 0.817, h = 1 }
	toTheSide = { x = 0, y = 0.05, w = 0.185, h = 0.95 }
	centered = { x = 0.186, y = 0, w = 0.6, h = 1 }
	baseLayout = pseudoMaximized
elseif isAtMother() then
	pseudoMaximized = { x = 0.2125, y = 0, w = 0.7875, h = 1 }
	toTheSide = { x = 0, y = 0.05, w = 0.185, h = 0.95 }
	centered = { x = 0.212, y = 0, w = 0.6, h = 1 }
	baseLayout = pseudoMaximized
elseif isAtOffice() then
	baseLayout = maximized
	pseudoMaximized = maximized
	centered = { x = 0.2, y = 0, w = 0.616, h = 1 }
end

---@param win hs.window
---@param size hs.geometry
---@return boolean
function checkSize(win, size)
	if not win then return false end
	local maxf = win:screen():frame()
	local winf = win:frame()

	local diffw = winf.w - size.w * maxf.w
	local diffh = winf.h - size.h * maxf.h
	local diffx = size.x * maxf.w + maxf.x - winf.x -- calculated this way for two screens
	local diffy = size.y * maxf.h + maxf.y - winf.y
	local widthOkay = (diffw > -5 and diffw < 5) -- leeway for rounding
	local heightOkay = (diffh > -5 and diffh < 5)
	local posyOkay = (diffy > -5 and diffy < 5)
	local posxOkay = (diffx > -5 and diffx < 5)

	return widthOkay and heightOkay and posxOkay and posyOkay
end

--------------------------------------------------------------------------------
-- SIDEBARS

-- requires these two helper actions for Drafts installed:
-- https://directory.getdrafts.com/a/2BS & https://directory.getdrafts.com/a/2BR
---@param draftsWin hs.window
local function toggleDraftsSidebar(draftsWin)
	runWithDelays({ 0.05, 0.2 }, function()
		local drafts_w = draftsWin:frame().w
		local screen_w = draftsWin:screen():frame().w
		local mode = drafts_w / screen_w > 0.6 and "show" or "hide"
		openLinkInBackground("drafts://x-callback-url/runAction?text=&action=" .. mode .. "-sidebar")
	end)
end

---@param highlightsWin hs.window
local function toggleHighlightsSidebar(highlightsWin)
	runWithDelays(0.3, function()
		local highlights_w = highlightsWin:frame().w
		local screen_w = highlightsWin:screen():frame().w
		local highlightsApp = hs.application("Highlights")
		highlightsApp:activate()
		local mode = highlights_w / screen_w > 0.6 and "Show" or "Hide"
		highlightsApp:selectMenuItem { "View", mode .. " Sidebar" }
	end)
end

-- requires Obsidian Sidebar Toggler Plugin https://github.com/chrisgrieser/obsidian-sidebar-toggler
---@param obsiWin hs.window
local function toggleObsidianSidebar(obsiWin)
	runWithDelays({ 0.05, 0.2 }, function()
		local numberOfObsiWindows = #(hs.application("Obsidian"):allWindows())
		if numberOfObsiWindows > 1 then return end -- prevent popout window resizing to affect sidebars

		local obsi_width = obsiWin:frame().w
		local screen_width = obsiWin:screen():frame().w

		-- if pseudo-maximized, hide sidebar, if half or full show sidebar
		-- (full = used as split pane)
		local mode = (obsi_width / screen_width > 0.6 and obsi_width / screen_width < 0.99) and "true"
			or "false"
		openLinkInBackground("obsidian://sidebar?showRight=" .. mode .. "&showLeft=false")
	end)
end

---@param win hs.window
function toggleWinSidebar(win)
	if not win or not win:application() then return end
	local appOfWin = win:application():name()
	if appOfWin == "Drafts" then
		toggleDraftsSidebar(win)
	elseif appOfWin == "Obsidian" then
		toggleObsidianSidebar(win)
	elseif appOfWin == "Highlights" then
		toggleHighlightsSidebar(win)
	end
end

function showAllSidebars()
	if appIsRunning("Highlights") then app("Highlights"):selectMenuItem { "View", "Show Sidebar" } end
	openLinkInBackground("obsidian://sidebar?showLeft=false&showRight=true")
	openLinkInBackground("drafts://x-callback-url/runAction?text=&action=show-sidebar")
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT HELPERS

---(HACK) show/hide second row of sketchybar, workaround for https://github.com/FelixKratz/SketchyBar/issues/309
---@param arg string|hs.geometry "show"|"hide"|hs.geometry obj
function sketchybarPopup(arg)
	local mode
	if isProjector() or isAtOffice() then
		mode = "false" -- always hide
	elseif type(arg) == "string" then
		mode = (arg == "show") and "true" or "false"
	elseif type(arg) == "table" then
		if arg.x == 0 and arg.y == 0 then -- comparing to 0 works for rect (absolute) and unitrect (relative)
			mode = "false"
		else
			mode = "true"
		end
	end
	hs.execute(
		"export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; "
			.. "sketchybar --set clock popup.drawing="
			.. mode
	)
end

-- change sketchybarPopups on change of active app
-- since window size saving & session saving is not separated
watcherForSketchy = aw.new(function(_, eventType, appObj)
	if eventType == aw.activated or eventType == aw.launched then
		local win = appObj:focusedWindow()
		if not win then return end
		sketchybarPopup(win:frame())
	end
end):start()

--------------------------------------------------------------------------------

---ensures Obsidian windows are always shown when developing css
---@param win hs.window
---@param pos hs.geometry
local function obsidianThemeDevHelper(win, pos)
	if
		not (pos == pseudoMaximized or pos == maximized)
		and win:application():name():lower() == "neovide"
		and appIsRunning("Obsidian")
	then
		runWithDelays(0.15, function()
			app("Obsidian"):unhide()
			app("Obsidian"):mainWindow():raise()
		end)
	end
end

--------------------------------------------------------------------------------
-- WINDOW MOVEMENT

---@param win hs.window
---@param pos hs.geometry
---@param updateSketchy? boolean whether to use the sketchybarpopup-toggle-hack. defaults to `true`
function moveResize(win, pos, updateSketchy)
	if not win then return end -- window been closed before

	toggleWinSidebar(win)
	obsidianThemeDevHelper(win, pos)

	if (pos == pseudoMaximized or pos == centered) and appIsRunning("Twitterrific") then
		app("Twitterrific"):mainWindow():raise()
	end

	if updateSketchy ~= false then sketchybarPopup(pos) end

	local i = 0 -- pseudo-timeout
	while win and i < 30 and not (checkSize(win, pos)) do
		win:moveToUnit(pos)
		os.execute("sleep 0.1") -- since lua itself does not have a blocking wait function
	end
end

local function moveCurWinToOtherDisplay()
	local win = hs.window.focusedWindow()
	local targetScreen = win:screen():next()
	win:moveToScreen(targetScreen, true)

	runWithDelays({ 0.1, 0.2 }, function()
		-- workaround for ensuring proper resizing
		win = hs.window.focusedWindow()
		win:setFrameInScreenBounds(win:frame())
	end)
end

--------------------------------------------------------------------------------
-- WINDOW TILING (OF SAME APP)

---automatically apply per-app auto-tiling of the windows of the app
---@param windowSource hs.window.filter|string windowFilter OR string representing app name
function autoTile(windowSource)
	---necessary b/c windowfilter is null when not triggered via
	---windowfilter-subscription-event. This check allows for using app names,
	---which enables using the autotile-function e.g. within app watchers
	---@param _windowSource hs.window.filter|string windowFilter OR string representing app name
	---@return hs.window[]
	local function getWins(_windowSource)
		if type(_windowSource) == "string" then
			return app(_windowSource):allWindows()
		else
			return _windowSource:getWindows()
		end
	end
	local wins = getWins(windowSource)

	if #wins > 1 then -- needed to avoid every call of moveResize changing the popup
		sketchybarPopup("hide")
	else
		sketchybarPopup("show")
	end

	if #wins == 0 and frontAppName() == "Finder" then
		-- prevent quitting when window is created imminently
		runWithDelays(0.2, function()
			-- INFO: quitting Finder requires `defaults write com.apple.finder QuitMenuItem -bool true`
			-- getWins() again to check if window count has changed in the meantime
			if #getWins(windowSource) == 0 then app("Finder"):kill() end
		end)
	elseif #wins == 1 then
		if isProjector() then
			moveResize(wins[1], maximized)
		elseif frontAppName() == "Finder" then
			moveResize(wins[1], centered)
		else
			moveResize(wins[1], baseLayout)
		end
	elseif #wins == 2 then
		moveResize(wins[1], leftHalf, false)
		moveResize(wins[2], rightHalf, false)
	elseif #wins == 3 then
		moveResize(wins[1], { h = 1, w = 0.33, x = 0, y = 0 }, false)
		moveResize(wins[2], { h = 1, w = 0.34, x = 0.33, y = 0 }, false)
		moveResize(wins[3], { h = 1, w = 0.33, x = 0.67, y = 0 }, false)
	elseif #wins == 4 then
		moveResize(wins[1], { h = 0.5, w = 0.5, x = 0, y = 0 }, false)
		moveResize(wins[2], { h = 0.5, w = 0.5, x = 0, y = 0.5 }, false)
		moveResize(wins[3], { h = 0.5, w = 0.5, x = 0.5, y = 0 }, false)
		moveResize(wins[4], { h = 0.5, w = 0.5, x = 0.5, y = 0.5 }, false)
	elseif #wins == 5 then
		moveResize(wins[1], { h = 0.5, w = 0.5, x = 0, y = 0 }, false)
		moveResize(wins[2], { h = 0.5, w = 0.5, x = 0, y = 0.5 }, false)
		moveResize(wins[3], { h = 0.5, w = 0.5, x = 0.5, y = 0 }, false)
		moveResize(wins[4], { h = 0.5, w = 0.5, x = 0.5, y = 0.5 }, false)
		moveResize(wins[5], { h = 0.5, w = 0.5, x = 0.25, y = 0.25 }, false)
	elseif #wins == 6 then
		moveResize(wins[1], { h = 0.5, w = 0.33, x = 0, y = 0 }, false)
		moveResize(wins[2], { h = 0.5, w = 0.33, x = 0, y = 0.5 }, false)
		moveResize(wins[3], { h = 0.5, w = 0.34, x = 0.33, y = 0 }, false)
		moveResize(wins[4], { h = 0.5, w = 0.34, x = 0.33, y = 0.5 }, false)
		moveResize(wins[5], { h = 0.5, w = 0.33, x = 0.67, y = 0 }, false)
		moveResize(wins[6], { h = 0.5, w = 0.33, x = 0.67, y = 0.5 }, false)
	end
end

--------------------------------------------------------------------------------
-- HOTKEY ACTIONS

---@param type string
function twitterrificAction(type)
	local previousApp = frontAppName()
	openApp("Twitterrific")
	local twitterrific = app("Twitterrific")
	twitterrific:activate() -- needs activation, cause sending to app in background doesn't work w/ cmd

	if type == "link" then
		keystroke({}, "right")
	elseif type == "scrollup" then
		local prevMousePos = hs.mouse.absolutePosition()

		local f = twitterrific:mainWindow():frame()
		keystroke({ "cmd" }, "1") -- properly up (to avoid clicking on tweet content)
		hs.eventtap.leftClick { x = f.x + f.w * 0.04, y = f.y + 150 }
		keystroke({ "cmd" }, "k") -- mark all as red
		keystroke({ "cmd" }, "j") -- scroll up
		keystroke({}, "down") -- enable j/k movement

		hs.mouse.absolutePosition(prevMousePos)
		app(previousApp):activate()
	end
end

local function controlSpaceAction()
	local currentWin = hs.window.focusedWindow()
	local pos
	if frontAppName() == "Finder" or frontAppName() == "Script Editor" then
		pos = centered
	elseif (isIMacAtHome() or isAtMother()) and not checkSize(currentWin, pseudoMaximized) then
		pos = pseudoMaximized
	else
		pos = maximized
	end
	moveResize(currentWin, pos)
end

local function pagedownAction()
	if #hs.screen.allScreens() > 1 then
		moveCurWinToOtherDisplay()
	elseif appIsRunning("Twitterrific") then
		keystroke({}, "down", 1, app("Twitterrific"))
	end
end

local function pageupAction()
	if #hs.screen.allScreens() > 1 then
		moveCurWinToOtherDisplay()
	elseif appIsRunning("Twitterrific") then
		keystroke({}, "up", 1, app("Twitterrific"))
	end
end

local function homeAction()
	if appIsRunning("zoom.us") then
		alert("🔈/🔇") -- toggle mute
		keystroke({ "shift", "command" }, "A", 1, app("zoom.us"))
	elseif appIsRunning("Twitterrific") then
		twitterrificAction("scrollup")
	end
end

local function endAction()
	if appIsRunning("Twitterrific") then twitterrificAction("link") end
end

--------------------------------------------------------------------------------
-- HOTKEYS
-- Window resizing
hotkey(hyper, "right", function() moveResize(hs.window.focusedWindow(), rightHalf) end)
hotkey(hyper, "left", function() moveResize(hs.window.focusedWindow(), leftHalf) end)
hotkey({ "ctrl" }, "space", controlSpaceAction) -- fn+space also bound to ctrl+space via Karabiner

-- move to other display or scroll Twitterrific
hotkey({}, "f6", moveCurWinToOtherDisplay) -- for apple keyboard
hotkey({}, "pagedown", pagedownAction, nil, pagedownAction)
hotkey({}, "pageup", pageupAction, nil, pageupAction)

-- Twitterrific or Zoom
hotkey({}, "home", homeAction)
hotkey({}, "end", endAction)
