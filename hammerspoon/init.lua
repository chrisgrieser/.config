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


menubarSubline = hs.drawing.rectangle({x=0, y=24, w=1920, h=1})
menubarSubline:setStrokeColor(hs.drawing.color.black)
menubarSubline:setFill(true)
menubarSubline:setStrokeWidth(2)
menubarSubline:show()
-- menubarSubline:delete()
menubarSubline = nill
