-- SETTINGS
hs.consoleOnTop(false)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.application.enableSpotlightForNameSearches(false)
hs.window.animationDuration = 0

--------------------------------------------------------------------------------
require("lua.meta")
require("lua.utils")

require("lua.visuals")
require("lua.dark-mode")

require("lua.window-management")
require("lua.layouts")
require("lua.app-hiding")
require("lua.splits")

require("lua.cronjobs")
require("lua.filesystem-watchers")
require("lua.repo-auto-sync")
require("lua.auto-quitter")
require("lua.hardware-periphery")

require("lua.hide-cursor-in-browser")
require("lua.app-specific-behavior")
require("lua.twitter")

SystemStart()
