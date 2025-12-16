local M = {} -- persist from garbage collector

local u = require("meta.utils")
--------------------------------------------------------------------------------

M.iMacDisplay = hs.screen("Built%-in")
local side = { w = 0.185, cutoff = 0.055 }
M.pseudoMax = hs.geometry { x = side.w, y = 0, w = (1 - side.w), h = 1 }
M.middleHalf = hs.geometry { x = side.w, y = 0, w = 0.6, h = 1 }
M.toTheSide = hs.geometry { x = -side.cutoff, y = 0.055, w = side.w + side.cutoff, h = 0.945 }

--------------------------------------------------------------------------------

---@param win hs.window|string if string, search for main window of app with that name
---@param pos hs.geometry
function M.moveResize(win, pos)
	if type(win) == "string" then
		win = u.app(win):mainWindow()
		if not win then return end
	end
	if not (win and win:isMaximizable() and win:isStandard()) then return end

	-- handle negative positions (= win partially not on screen) by converting
	-- them to a frame, since `moveToUnit` doesn't support negative positions
	if pos.x < 0 then
		local screenFrame = win:screen():frame()
		local x = pos.x
		pos.x = 0 -- store, since `fromUnitRect` cannot handle negative values
		local rect = pos:fromUnitRect(screenFrame)
		pos.x = x
		rect.x = x * screenFrame.w
		win:setFrame(rect)
		return
	end

	-- resize with redundancy, since macOS sometimes doesn't resize properly
	u.defer({ 0, 0.4, 0.8 }, function() win:moveToUnit(pos) end)
end

--------------------------------------------------------------------------------
return M
