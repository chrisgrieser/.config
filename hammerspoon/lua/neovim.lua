local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local aw = require("lua.utils").aw

--------------------------------------------------------------------------------

---ensures Obsidian windows are always shown when developing, mostly for developing CSS
---@param win hs.window
local function obsidianThemeDevHelper(win)
	local obsi = u.app("Obsidian")
	if
		not win
		or not win:application()
		or not (win:application():name():lower() == "neovide")
		or not obsi
	then
		return
	end

	-- delay to avoid conflict with app-hider.lua and that resizing took place
	u.runWithDelays(0.1, function()
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
	if not appName or appName:lower() ~= "neovide" then return end

	if eventType == aw.activated then
		addCssSelectorLeadingDot()
		obsidianThemeDevHelper(neovide:mainWindow())

		-- HACK bugfix for: https://github.com/neovide/neovide/issues/1595
	elseif eventType == aw.terminated then
		u.runWithDelays(3, function() hs.execute("pgrep -xq 'neovide' || killall 'nvim' || killall -9 'nvim'") end)
	end
end):start()

Wf_neovideMoved = u.wf
	.new({ "Neovide", "neovide" })
	:subscribe(u.wf.windowMoved, function(movedWin) obsidianThemeDevHelper(movedWin) end)

	-----------------------------------------------------------------------------

-- HACK since neovide does not send a launch signal, triggering window resizing
-- via its URI scheme called on VimEnter
u.urischeme("enlarge-neovide-window", function()
	u.asSoonAsAppRuns("neovide", function()
		local neovideWin = u.app("neovide"):mainWindow()
		local size = env.isProjector() and wu.maximized or wu.pseudoMax
		wu.moveResize(neovideWin, size)
	end)
end)

--------------------------------------------------------------------------------

