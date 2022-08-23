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
-- require("app-switcher")

-- START
systemStart()
reloadAllMenubarItems()
notify("Config reloaded")


