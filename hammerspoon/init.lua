require("meta")
require("utils")

require("scroll-and-cursor")
require("menubar")
require("visuals")
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

reloadAllMenubarItems() ---@diagnostic disable-line: undefined-global
systemStart() ---@diagnostic disable-line: undefined-global
notify("Config reloaded")


