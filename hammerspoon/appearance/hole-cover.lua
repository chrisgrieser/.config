local M = {}

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/Spoons/RoundedCorners.html
local roundedCorner = hs.loadSpoon("RoundedCorners")
if roundedCorner then
	roundedCorner.radius = 18 -- macOS Tahoe's radius
	roundedCorner:start()
end

--------------------------------------------------------------------------------

---to stop wallpaper shining through
function M.update()
	local toMode = u.isDarkMode() and "dark" or "light"

	if M.coverParts then
		for _, cover in pairs(M.coverParts) do
			if cover.delete then cover:delete() end
			cover = nil
		end
		M.CoverParts = nil
	end
	if env.isProjector() then return end

	local screen = hs.screen.mainScreen():frame()
	local pseudoMaxCorner = wu.toTheSide.w + wu.toTheSide.x
	local bgColor = toMode == "dark" and { red = 0.2, green = 0.2, blue = 0.2, alpha = 1 }
		or { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 }

	-- forming roughly a triangle
	M.coverParts = {
		hs.drawing.rectangle { x = pseudoMaxCorner - 24, y = screen.h - 5, w = 48, h = 5 },
		hs.drawing.rectangle { x = pseudoMaxCorner - 20, y = screen.h - 10, w = 40, h = 5 },
		hs.drawing.rectangle { x = pseudoMaxCorner - 16, y = screen.h - 15, w = 32, h = 5 },
		hs.drawing.rectangle { x = pseudoMaxCorner - 12, y = screen.h - 20, w = 24, h = 5 },
		hs.drawing.rectangle { x = pseudoMaxCorner - 8, y = screen.h - 25, w = 16, h = 5 },
		hs.drawing.rectangle { x = pseudoMaxCorner - 4, y = screen.h - 30, w = 8, h = 5 },
	}

	for _, cover in pairs(M.coverParts) do
		cover:setFillColor(bgColor)
		cover:setFill(true)
		cover:setStrokeColor(bgColor)
		cover:sendToBack()
		cover:show()
	end
end

M.update()

--------------------------------------------------------------------------------
return M
