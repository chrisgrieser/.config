local u = require("lua.utils")
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/Spoons/RoundedCorners.html
RoundedCorners = hs.loadSpoon("RoundedCorners")
RoundedCorners.radius = 9
RoundedCorners:start()

---to stop wallpaper shining through
---@param arg? string
function HoleCover(arg)
	if u.isAtOffice() or u.isProjector() then return end

	if Cover1 then Cover1 = nil end
	if Cover2 then Cover2 = nil end
	if Cover3 then Cover3 = nil end
	if arg == "remove" then return end

	local bgColor
	local screen = hs.screen.mainScreen():frame()
	if u.isDarkMode() then
		bgColor = { red = 0.2, green = 0.2, blue = 0.2, alpha = 1 }
	else
		bgColor = { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 }
	end

	local pseudoMaxCorner = wu.toTheSide.w + wu.toTheSide.x

	-- three points, forming roughly a triangle
	Cover1 = hs.drawing.rectangle { x = pseudoMaxCorner - 9, y = screen.h - 3, w = 18, h = 3 }
	Cover2 = hs.drawing.rectangle { x = pseudoMaxCorner - 6, y = screen.h - 6, w = 12, h = 3 }
	Cover3 = hs.drawing.rectangle { x = pseudoMaxCorner - 3, y = screen.h - 9, w = 6, h = 3 }

	-- for some reason, these cannot be put into a function :/
	Cover1:setFillColor(bgColor)
	Cover1:sendToBack()
	Cover1:setFill(true)
	Cover1:setStrokeColor(bgColor)
	Cover1:show()

	Cover2:setFillColor(bgColor)
	Cover2:sendToBack()
	Cover2:setFill(true)
	Cover2:setStrokeColor(bgColor)
	Cover2:show()

	Cover3:setFillColor(bgColor)
	Cover3:sendToBack()
	Cover3:setFill(true)
	Cover3:setStrokeColor(bgColor)
	Cover3:show()
end
