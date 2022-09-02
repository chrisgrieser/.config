require("utils")
require("window-management")
require("dark-mode")
--------------------------------------------------------------------------------

-- since
function activationHighlight()
	local allWins=wf.new(true):setOverrideFilter{allowRoles='AXStandardWindow'}

	-- overlay deactivated by default, so this way *only* the flash is in effect
	-- however, it only triggers on window creation, not window activation
	hs.window.highlight.start({} ,allWins)
	hs.window.highlight.ui.flashDuration = 0.3
end

if isAtOffice() then activationHighlight() end

--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/Spoons/RoundedCorners.html
-- this mostly round the corners in the bottom
roundedCorners = hs.loadSpoon("RoundedCorners")
roundedCorners.radius = 10
roundedCorners:start()

-- for whatever reason, passing rectangles into a function does not work,
-- therefore the unrolled madness :(
function menubarLine ()
	if corner1 then
		corner1:delete()
		corner1 = nil
	end
	if corner2 then
		corner2:delete()
		corner2 = nil
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
	if thinLine then
		thinLine:delete()
		thinLine = nil
	end
	if menubarOverlay then
		menubarOverlay:delete()
		menubarOverlay = nil
	end

	local bgColor
	local menuBarColor
	local max = hs.screen.mainScreen():frame()
	if isDarkMode() then
		bgColor = {["red"]=0.2,["blue"]=0.2,["green"]=0.2,["alpha"]=1}
		menuBarColor = {["red"]=0.095,["blue"]=0.095,["green"]=0.095,["alpha"]=1}
	else
		bgColor = {["red"]=0.8,["blue"]=0.8,["green"]=0.8,["alpha"]=1}
		menuBarColor = {["red"]=0.83,["blue"]=0.83,["green"]=0.83,["alpha"]=1}
	end

	corner1 = hs.drawing.rectangle({x=max.w-8, y=23, w=8, h=11})
	corner2 = hs.drawing.rectangle({x=0, y=23, w=8, h=11})
	thinLine = hs.drawing.rectangle({x=0, y=24, w=max.w, h=1}) -- wallpaper shining through
	menubarOverlay = hs.drawing.rectangle({x=50, y=0, w=max.w/2, h=24}) -- x=50 to keep apple logo

	corner1:setFillColor(bgColor)
	corner1:sendToBack()
	corner1:setFill(true)
	corner1:setStrokeColor(bgColor)
	corner1:show()

	corner2:setFillColor(bgColor)
	corner2:sendToBack()
	corner2:setFill(true)
	corner2:setStrokeColor(bgColor)
	corner2:show()

	thinLine:setFillColor(bgColor)
	thinLine:setFill(true)
	thinLine:setStrokeColor(bgColor)
	thinLine:show()

	menubarOverlay:setFillColor(menuBarColor)
	menubarOverlay:setFill(true)
	menubarOverlay:setStrokeColor(menuBarColor)
	menubarOverlay:show()

	if isAtOffice() or isProjector() then return end

	-- pseudoMaxPoints
	asdf1 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-8, y=24, w=18, h=3})
	asdf2 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-6, y=27, w=12, h=3})
	asdf3 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-3, y=30, w=6, h=3})
	bsdf3 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-3, y=max.h+25-9, w=6, h=3})
	bsdf2 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-6, y=max.h+25-6, w=12, h=3})
	bsdf1 = hs.drawing.rectangle({x=pseudoMaximized.w*max.w-8, y=max.h+25-3, w=18, h=3})

	asdf1:setFillColor(bgColor)
	asdf1:sendToBack()
	asdf1:setFill(true)
	asdf1:setStrokeColor(bgColor)
	asdf1:show()

	asdf2:setFillColor(bgColor)
	asdf2:sendToBack()
	asdf2:setFill(true)
	asdf2:setStrokeColor(bgColor)
	asdf2:show()

	asdf3:setFillColor(bgColor)
	asdf3:sendToBack()
	asdf3:setFill(true)
	asdf3:setStrokeColor(bgColor)
	asdf3:show()

	bsdf1:setFillColor(bgColor)
	bsdf1:sendToBack()
	bsdf1:setFill(true)
	bsdf1:setStrokeColor(bgColor)
	bsdf1:show()

	bsdf2:setFillColor(bgColor)
	bsdf2:sendToBack()
	bsdf2:setFill(true)
	bsdf2:setStrokeColor(bgColor)
	bsdf2:show()

	bsdf3:setFillColor(bgColor)
	bsdf3:sendToBack()
	bsdf3:setFill(true)
	bsdf3:setStrokeColor(bgColor)
	bsdf3:show()
end

