-- https://www.hammerspoon.org/go/

--------------------------------------------------------------------------------

hs.window.animationDuration = 0

--------------------------------------------------------------------------------
-- Hammerspoon itself & Helper Utilities
require("meta")
require("utils")

--------------------------------------------------------------------------------

-- Base
require("scroll-and-cursor")
require("menubar")
require("system-and-cron")
require("window-management")
require("layout")
require("filesystem-watchers")
require("usb-watchers")
require("dark-mode")

-- app-specific
require("app-specific-behavior")
require("twitterrific-iina")

-- unused
-- require("app-switcher")
-- require("hot-corner-action")

--------------------------------------------------------------------------------
-- System Startup
gitDotfileSync("wake")
reloadAllMenubarItems()
killIfRunning("Finder") -- fewer items in the app switcher when Marta is used anyway

notify("Config reloaded")

--------------------------------------------------------------------------------


