-- https://www.hammerspoon.org/go/

--------------------------------------------------------------------------------
-- SETTINGS
hs.window.animationDuration = 0

--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- SYSTEM STARTUP
gitDotfileSync("wake")
gitVaultBackup()
reloadAllMenubarItems() ---@diagnostic disable-line: undefined-global
killIfRunning("Finder") -- fewer items in the app switcher when Marta is used anyway

notify("Config reloaded")

--------------------------------------------------------------------------------


