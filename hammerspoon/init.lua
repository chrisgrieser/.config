-- SETTINGS
hs.window.animationDuration = 0
--
-- IMPORTS
-- Helpers
require("meta")
require("utils")

-- Base
require("scroll-and-cursor")
require("menubar")
require("system-and-cron")
require("window-management")
require("layouts")
require("splits")
require("filesystem-watchers")
require("usb-watchers")
require("dark-mode")
require("app-specific-behavior")
require("twitterrific-controls")
if isAtMother() then require("hot-corner-action") end

-- START
reloadAllMenubarItems() ---@diagnostic disable-line: undefined-global
systemStart() ---@diagnostic disable-line: undefined-global
notify("Config reloaded")




function mouseHighlight()
	 -- Delete an existing highlight if it exists
	 if mouseCircle then
		mouseCircle:delete()
		if mouseCircleTimer then
			mouseCircleTimer:stop()
		end
	 end
	 -- Get the current co-ordinates of the mouse pointer
	 mousepoint = hs.mouse.absolutePosition()
	 -- Prepare a big red circle around the mouse pointer
	 mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
	 mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
	 mouseCircle:setFill(false)
	 mouseCircle:setStrokeWidth(5)
	 mouseCircle:show()

	 -- Set a timer to delete the circle after 3 seconds
	 mouseCircleTimer = hs.timer.doAfter(3, function()
													 mouseCircle:delete()
													 mouseCircle = nil
												 end)
 end
