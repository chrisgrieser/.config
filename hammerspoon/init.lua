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

if isIMacAtHome() or isAtMother() then
	require("lua.twitterrific-controls")
	require("lua.hot-corner-action")
	require("lua.usb-watchers")
end

anycomplete = hs.loadSpoon("Anycomplete")
anycomplete.engine = "duckduckgo"
hotkey({"alt"}, "space", function() anycomplete:anycomplete() end)

holeCover()
systemStart()
