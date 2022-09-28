require("meta")
require("utils")
require("visuals")
holeCover() ---@diagnostic disable-line: undefined-global

require("window-management")
require("dark-mode")
require("layouts")
require("splits")

require("scroll-and-cursor")
require("system-and-cron")
require("filesystem-watchers")
if isIMacAtHome() then require("usb-watchers") end

require("app-specific-behavior")
require("twitterrific-controls")
require("hot-corner-action")

systemStart() ---@diagnostic disable-line: undefined-global
