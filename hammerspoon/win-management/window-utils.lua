local M = {} -- persist from garbage collector

local u = require("meta.utils")
--------------------------------------------------------------------------------

M.iMacDisplay = hs.screen("Built%-in")
local sideW = 0.185
M.pseudoMax = hs.geometry { x = sideW, y = 0, w = (1 - sideW), h = 1 }
M.middleHalf = hs.geometry { x = sideW, y = 0, w = 0.6, h = 1 }
M.toTheSide = hs.geometry { x = 0, y = 0.06, w = sideW, h = 1 } -- height 1 to not leave corners at bottom

--------------------------------------------------------------------------------
-- INFO to allow a narrower window in Mona
-- 1. Click `…` -> open new window
-- 2. Close old window
-- 3. System Settings -> Desktop & Dock -> Disable "Close windows when qutting application"
--------------------------------------------------------------------------------

---@param win hs.window|string if string, search for main window of app with that name
---@param pos hs.geometry
function M.moveResize(win, pos)
	if type(win) == "string" then win = u.app(win):mainWindow() end
	if not (win and win:isMaximizable() and win:isStandard()) then return end

	-- resize with redundancy, since macOS sometimes doesn't resize properly
	u.defer({ 0, 0.5 }, function() win:moveToUnit(pos) end)
end

--------------------------------------------------------------------------------
return M
