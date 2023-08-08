local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local aw = require("lua.utils").aw

--------------------------------------------------------------------------------

---ensures Obsidian windows are always shown when developing (for CSS live reloads)
---@param win hs.window
local function obsidianThemeDevHelper(win)
	local obsi = u.app("Obsidian")
	if
		not win
		or not win:application()
		or not (win:application():name():lower() == "neovide")
		or not obsi:mainWindow()
		or obsi:mainWindow():isMinimized()
	then
		return
	end

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
	if
		not u.appRunning("neovide")
		or not u.app("neovide"):mainWindow()
		or not u.app("neovide"):mainWindow():title():find("%.css$")
	then
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

Wf_neovideMoved = u.wf
	.new({ "Neovide", "neovide" })
	:subscribe(u.wf.windowMoved, function(movedWin) obsidianThemeDevHelper(movedWin) end)

--------------------------------------------------------------------------------

-- HACK since neovide does not send a launch signal, triggering window resizing
-- via its URI scheme called on VimEnter
u.urischeme("neovide-post-startup", function()
	-- properly size the window
	u.asSoonAsAppRuns("neovide", function()
		local neovideWin = u.app("neovide"):mainWindow()
		local size = env.isProjector() and wu.maximized or wu.pseudoMax
		wu.moveResize(neovideWin, size)
	end)
end)
