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
require("filesystem-watchers")
require("usb-watchers")
require("dark-mode")
-- require("app-switcher")
-- require("hot-corner-action")

-- app-specific
require("app-watchers")
require("discord")
require("twitterrific-iina")

--------------------------------------------------------------------------------
-- System Startup
gitDotfileSync("wake")
reloadAllMenubarItems()
killIfRunning("Finder") -- fewer items in the app switcher when Marta is used anyway

notify("Config reloaded")

--------------------------------------------------------------------------------


