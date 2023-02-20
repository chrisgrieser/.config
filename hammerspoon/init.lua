require("lua.meta")
require("lua.utils")

require("lua.visuals")
require("lua.window-management")
require("lua.dark-mode")
require("lua.layouts")
require("lua.splits")

require("lua.scroll-and-cursor")
require("lua.cronjobs")
require("lua.filesystem-watchers")
require("lua.app-specific-behavior")
require("lua.twitter")
require("lua.hardware-periphery")

if IsIMacAtHome() or IsAtMother() then
	require("lua.hot-corner-action")
end

HoleCover()
SystemStart()
