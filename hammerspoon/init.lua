require("lua.meta")
require("lua.utils")
require("lua.visuals")
holeCover()

require("lua.window-management")
require("lua.dark-mode")
require("lua.layouts")
require("lua.splits")

require("lua.scroll-and-cursor")
require("lua.system-and-cron")
require("lua.filesystem-watchers")
if isIMacAtHome() then require("lua.usb-watchers") end

require("lua.app-specific-behavior")
if not (isAtOffice()) then
	require("lua.twitterrific-controls")
	require("lua.hot-corner-action")
end

systemStart()
