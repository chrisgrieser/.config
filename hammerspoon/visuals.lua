require("utils")
require("window-management")
--------------------------------------------------------------------------------

hs.window.animationDuration = 0

-- https://www.hammerspoon.org/Spoons/RoundedCorners.html
roundedCorners = hs.loadSpoon("RoundedCorners")
roundedCorners.radius = 8
roundedCorners:start()

-- visual fix of the wallpaper line shining through
function menubarLine (arg)
	if point1 then
		point1:delete()
		point1 = nil
	end
	if point2 then
		point2:delete()
		point2 = nil
	end
	if asdf1 then
		asdf1:delete()
		asdf1 = nil
	end
	if asdf2 then
		asdf2:delete()
		asdf2 = nil
	end
	if asdf3 then
		asdf3:delete()
		asdf3 = nil
	end
	if bsdf1 then
		bsdf1:delete()
		bsdf1 = nil
	end
	if bsdf2 then
		bsdf2:delete()
		bsdf2 = nil
	end
	if bsdf3 then
		bsdf3:delete()
		bsdf3 = nil
	end
	if line1 then
		line1:delete()
		line1 = nil
	end

	if arg == "delete" then return end

	local color
	if isDarkMode() then color = {["red"]=0.2,["blue"]=0.2,["green"]=0.2,["alpha"]=1}
	else color = {["red"]=0.7,["blue"]=0.7,["green"]=0.7,["alpha"]=1} end
	local max = hs.screen.mainScreen():frame()

	point1 = hs.drawing.rectangle({x=max.w-8, y=23, w=8, h=11})
	point2 = hs.drawing.rectangle({x=0, y=23, w=8, h=11})
	line1 = hs.drawing.rectangle({x=0, y=24, w=max.w, h=1})
	asdf1 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-8, y=24, w=18, h=3})
	asdf2 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-6, y=27, w=12, h=3})
	asdf3 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-3, y=30, w=6, h=3})
	bsdf3 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-3, y=max.h+25-9, w=6, h=3})
	bsdf2 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-6, y=max.h+25-6, w=12, h=3})
	bsdf1 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-8, y=max.h+25-3, w=18, h=3})

	point1:setFillColor(color)
	point1:sendToBack()
	point1:setFill(true)
	point1:setStrokeColor(color)
	point1:show()

	point2:setFillColor(color)
	point2:sendToBack()
	point2:setFill(true)
	point2:setStrokeColor(color)
	point2:show()

	asdf1:setFillColor(color)
	asdf1:sendToBack()
	asdf1:setFill(true)
	asdf1:setStrokeColor(color)
	asdf1:show()

	asdf2:setFillColor(color)
	asdf2:sendToBack()
	asdf2:setFill(true)
	asdf2:setStrokeColor(color)
	asdf2:show()

	asdf3:setFillColor(color)
	asdf3:sendToBack()
	asdf3:setFill(true)
	asdf3:setStrokeColor(color)
	asdf3:show()

	bsdf1:setFillColor(color)
	bsdf1:sendToBack()
	bsdf1:setFill(true)
	bsdf1:setStrokeColor(color)
	bsdf1:show()

	bsdf2:setFillColor(color)
	bsdf2:sendToBack()
	bsdf2:setFill(true)
	bsdf2:setStrokeColor(color)
	bsdf2:show()

	bsdf3:setFillColor(color)
	bsdf3:sendToBack()
	bsdf3:setFill(true)
	bsdf3:setStrokeColor(color)
	bsdf3:show()

	line1:setFillColor(color)
	line1:setStrokeColor(color)
	line1:setFill(true)
	line1:show()
end

if isIMacAtHome() and not(isProjector()) then
	menubarLine()
end
