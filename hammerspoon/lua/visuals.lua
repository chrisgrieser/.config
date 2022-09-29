require("lua.utils")
require("lua.window-management")
require("lua.dark-mode")

--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/Spoons/RoundedCorners.html
-- this mostly round the corners in the bottom
roundedCorners = hs.loadSpoon("RoundedCorners")
roundedCorners.radius = 8
roundedCorners:start()

-- to stop wallpaper shining through
function holeCover ()
	if isAtOffice() or isProjector() then return end

	if cover1 then
		cover1:delete()
		cover1 = nil
	end
	if cover2 then
		cover2:delete()
		cover2 = nil
	end
	if cover3 then
		cover3:delete()
		cover3 = nil
	end

	local bgColor
	local screen = hs.screen.mainScreen():frame()
	if isDarkMode() then
		bgColor = {["red"]=0.2,["blue"]=0.2,["green"]=0.2,["alpha"]=1}
	else
		bgColor = {["red"]=0.8,["blue"]=0.8,["green"]=0.8,["alpha"]=1}
	end

	-- three points, forming roughly a triangle
	cover1 = hs.drawing.rectangle({x=pseudoMaximized.w*screen.w-9, y=screen.h-3, w=18, h=3})
	cover2 = hs.drawing.rectangle({x=pseudoMaximized.w*screen.w-6, y=screen.h-6, w=12, h=3})
	cover3 = hs.drawing.rectangle({x=pseudoMaximized.w*screen.w-3, y=screen.h-9, w=6, h=3})

	-- for some reason, these cannot be put into a function :/
	cover1:setFillColor(bgColor)
	cover1:sendToBack()
	cover1:setFill(true)
	cover1:setStrokeColor(bgColor)
	cover1:show()

	cover2:setFillColor(bgColor)
	cover2:sendToBack()
	cover2:setFill(true)
	cover2:setStrokeColor(bgColor)
	cover2:show()

	cover3:setFillColor(bgColor)
	cover3:sendToBack()
	cover3:setFill(true)
	cover3:setStrokeColor(bgColor)
	cover3:show()
end

