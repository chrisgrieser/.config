local M = {} -- persist from garbage collector

local u = require("meta.utils")
--------------------------------------------------------------------------------

M.iMacDisplay = hs.screen("Built%-in")
local side = { w = 0.185, cutoff = 0.05 }
M.pseudoMax = hs.geometry { x = side.w, y = 0, w = (1 - side.w), h = 1 }
M.middleHalf = hs.geometry { x = side.w, y = 0, w = 0.6, h = 1 }
M.toTheSide = hs.geometry { x = -side.cutoff, y = 0.06, w = side.w + side.cutoff, h = 0.94 }

--------------------------------------------------------------------------------

---@param win hs.window
---@param relSize hs.geometry
---@nodiscard
---@return boolean|nil -- nil if no win
function M.winHasSize(win, relSize)
	if not win then return end
	local maxf = win:screen():frame()
	local winf = win:frame()
	local diffw = winf.w - relSize.w * maxf.w
	local diffh = winf.h - relSize.h * maxf.h
	local diffx = relSize.x * maxf.w + maxf.x - winf.x -- calculated this way for two screens
	local diffy = relSize.y * maxf.h + maxf.y - winf.y

	local leeway = 3 -- e.g., terminal cell widths creating some minor inprecision
	local widthOkay = (diffw > -leeway and diffw < leeway)
	local heightOkay = (diffh > -leeway and diffh < leeway)
	local posyOkay = (diffy > -leeway and diffy < leeway)
	local posxOkay = (diffx > -leeway and diffx < leeway)

	return widthOkay and heightOkay and posxOkay and posyOkay
end

---@param win hs.window
---@param pos hs.geometry
function M.moveResize(win, pos)
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
