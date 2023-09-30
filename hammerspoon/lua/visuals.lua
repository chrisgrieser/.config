local M = {}

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/Spoons/RoundedCorners.html
local roundedCorners = hs.loadSpoon("RoundedCorners")
roundedCorners.radius = 8
if roundedCorners then roundedCorners:start() end

---to stop wallpaper shining through
---@param arg? string
function M.holeCover(arg)
	if CoverParts then
		---@diagnostic disable-next-line: unused-local
		for _, cover in pairs(CoverParts) do
			cover:delete()
			cover = nil ---@diagnostic disable-line: unused-local
		end
		CoverParts = nil
	end
	if arg == "remove" or env.isProjector() then return end

	local bgColor
	local screen = hs.screen.mainScreen():frame()
	if u.isDarkMode() then
		bgColor = { red = 0.2, green = 0.2, blue = 0.2, alpha = 1 }
	else
		bgColor = { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 }
	end

	local pseudoMaxCorner = wu.toTheSide.w + wu.toTheSide.x

	-- three points, forming roughly a triangle
	CoverParts = {}
	CoverParts[1] = hs.drawing.rectangle { x = pseudoMaxCorner - 9, y = screen.h - 3, w = 18, h = 3 }
	CoverParts[2] = hs.drawing.rectangle { x = pseudoMaxCorner - 6, y = screen.h - 6, w = 12, h = 3 }
	CoverParts[3] = hs.drawing.rectangle { x = pseudoMaxCorner - 3, y = screen.h - 9, w = 6, h = 3 }

	for _, cover in pairs(CoverParts) do
		cover:setFillColor(bgColor)
		cover:sendToBack()
		cover:setFill(true)
		cover:setStrokeColor(bgColor)
		cover:show()
	end
end

--------------------------------------------------------------------------------
-- initialize on system start
if u.isSystemStart() then M.holeCover() end

--------------------------------------------------------------------------------
return M
