local M = {}

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/Spoons/RoundedCorners.html
local roundedCorners = hs.loadSpoon("RoundedCorners")
if roundedCorners then roundedCorners:start() end

--------------------------------------------------------------------------------

---to stop wallpaper shining through
---@param toMode "dark"|"light"|"auto"|"remove"
function M.holeCover(toMode)
	if toMode == "auto" then toMode = u.isDarkMode() and "dark" or "light" end

	if M.coverParts then
		for _, cover in pairs(M.coverParts) do
			cover:delete()
			cover = nil
		end
		M.CoverParts = nil
	end
	if toMode == "remove" or env.isProjector() then return end

	local screen = hs.screen.mainScreen():frame()
	local pseudoMaxCorner = wu.toTheSide.w + wu.toTheSide.x
	local bgColor = toMode == "dark" and { red = 0.2, green = 0.2, blue = 0.2, alpha = 1 }
		or { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 }

	-- three points, forming roughly a triangle
	M.coverParts = {} -- needs to be assigned this way for some reason?
	M.coverParts[1] =
		hs.drawing.rectangle { x = pseudoMaxCorner - 9, y = screen.h - 3, w = 18, h = 3 }
	M.coverParts[2] =
		hs.drawing.rectangle { x = pseudoMaxCorner - 6, y = screen.h - 6, w = 12, h = 3 }
	M.coverParts[3] =
		hs.drawing.rectangle { x = pseudoMaxCorner - 3, y = screen.h - 9, w = 6, h = 3 }

	for _, cover in pairs(M.coverParts) do
		cover:setFillColor(bgColor)
		cover:sendToBack()
		cover:setFill(true)
		cover:setStrokeColor(bgColor)
		cover:show()
	end
end

if u.isSystemStart() then M.holeCover("auto") end

--------------------------------------------------------------------------------
return M
