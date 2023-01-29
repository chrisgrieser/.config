require("lua.meta")
require("lua.utils")

require("lua.visuals")
require("lua.window-management")
require("lua.dark-mode")
require("lua.layouts")
require("lua.splits")

require("lua.scroll-and-cursor")
require("lua.system-and-cron")
require("lua.filesystem-watchers")
require("lua.app-specific-behavior")
require("lua.twitter")
require("lua.notification-watcher")

if isIMacAtHome() or isAtMother() then
	require("lua.hot-corner-action")
	require("lua.usb-watchers")
end

holeCover()
systemStart()
