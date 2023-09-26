local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter

--------------------------------------------------------------------------------

---ensures Obsidian windows are always shown when developing (for CSS live reloads)
---@param win hs.window
local function obsidianThemeDevHelper(win)
	local obsi = u.app("Obsidian")
	---@diagnostic disable-next-line: undefined-field
	local isNeovideWin = win and win:application() and (win:application():name():lower() == "neovide")
	local obsiMinimized = obsi and obsi:mainWindow() and not (obsi:mainWindow():isMinimized())
	if not isNeovideWin or not obsiMinimized then return end

	-- delay to avoid conflict with `app-hider.lua`
	u.runWithDelays(0.1, function()
		if not obsi or not obsi:mainWindow() then return end
		if wu.CheckSize(win, wu.pseudoMax) or wu.CheckSize(win, wu.maximized) then
			obsi:hide()
		else
			obsi:unhide()
			obsi:mainWindow():raise()
		end
	end)
end

-- Add dots when copypasting from dev tools
local function addCssSelectorLeadingDot()
	local neovide = u.app("neovide")
	if not (neovide and neovide:mainWindow() and neovide:mainWindow():title():find("%.css$")) then
		return
	end

	local clipb = hs.pasteboard.getContents()
	if not clipb then return end

	local hasSelectorAndClass = clipb:find(".%-.")
		and not (clipb:find("[\n.=]"))
		and not (clipb:find("^%-%-"))
	if not hasSelectorAndClass then return end

	clipb = clipb:gsub("^", "."):gsub(" ", ".")
	hs.pasteboard.setContents(clipb)
end

NeovideWatcher = aw.new(function(appName, eventType, neovide)
	if not appName then return end
	if appName:lower() == "neovide" and eventType == aw.activated then
		addCssSelectorLeadingDot()
		obsidianThemeDevHelper(neovide:mainWindow())
	end
end):start()

Wf_neovideMoved = wf
	.new({ "Neovide", "neovide" })
	:subscribe(wf.windowMoved, function(movedWin) obsidianThemeDevHelper(movedWin) end)

--------------------------------------------------------------------------------

-- HACK since neovide does not send a launch signal, triggering window resizing
-- via its URI scheme called on VimEnter
-- (window-movement also triggers hiding other apps via `app-hider`)
u.urischeme("neovide-post-startup", function()
	u.whenAppWinAvailable("neovide", function()
		local neovideWin = u.app("neovide"):mainWindow()
		local size = env.isProjector() and wu.maximized or wu.pseudoMax
		wu.moveResize(neovideWin, size)
		u.app("neovide"):activate()
	end)
end)
