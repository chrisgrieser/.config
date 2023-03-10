-- HAMMERSPOON SETTINGS
hs.consoleOnTop(false)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.application.enableSpotlightForNameSearches(false)
hs.window.animationDuration = 0

--------------------------------------------------------------------------------
print("Start Loading Config")
require("lua.meta")
require("lua.utils")

require("lua.visuals")
require("lua.window-management")
require("lua.dark-mode")
require("lua.layouts")
require("lua.splits")
require("lua.hide-cursor-in-browser")
require("lua.cronjobs")
require("lua.repo-auto-sync")
require("lua.filesystem-watchers")
require("lua.app-specific-behavior")
require("lua.twitter")
require("lua.auto-quitter")
require("lua.hardware-periphery")

if IsAtMother() then require("lua.hot-corner-action") end

print("Stop Loading Config")
SystemStart()
