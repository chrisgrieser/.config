local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
--------------------------------------------------------------------------------

M.iMacDisplay = hs.screen("Built%-in")
M.pseudoMax = { x = 0.184, y = 0, w = 0.817, h = 1 }
M.middleHalf = { x = 0.184, y = 0, w = 0.6, h = 1 }

-- negative x to hide useless sidebar
M.toTheSide = hs.geometry.rect(-90, 54, 444, 1026)
if env.isAtOffice then M.toTheSide = hs.geometry.rect(-90, 54, 466, 1100) end
if env.isAtMother then M.toTheSide = hs.geometry.rect(-90, 54, 399, 890) end

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

	local leeway = 5 -- e.g., terminal cell widths creating some minor inprecision
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
	local appsToIgnore = { "Transmission", "Hammerspoon", "Ivory" }
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
	u.defer({ 0, 0.4, 0.8 }, function()
		if not M.winHasSize(win, pos) then win:moveToUnit(pos) end
	end)
end

--------------------------------------------------------------------------------
return M
