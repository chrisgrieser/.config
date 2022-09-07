require("meta")
require("utils")
require("visuals")

require("window-management")
require("dark-mode")
require("layouts")
require("splits")

require("scroll-and-cursor")
require("menubar")
require("system-and-cron")
require("filesystem-watchers")
if isIMacAtHome() then require("usb-watchers") end

require("app-specific-behavior")
require("twitterrific-controls")
if isAtMother() then require("hot-corner-action") end

menubarLine() ---@diagnostic disable-line: undefined-global
reloadAllMenubarItems() ---@diagnostic disable-line: undefined-global
killIfRunning("Finder")

notify("Config reloaded")

systemStart() ---@diagnostic disable-line: undefined-global
