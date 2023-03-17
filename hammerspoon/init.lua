-- SETTINGS
hs.consoleOnTop(false)
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.application.enableSpotlightForNameSearches(false) -- suppress useless console msgs
hs.window.animationDuration = 0 -- quicker animations
hs.allowAppleScript(true) -- allow external control

--------------------------------------------------------------------------------
-- self
require("lua.console")
require("lua.reload-and-systemstart")
require("lua.utils")

-- appearance
require("lua.visuals")
require("lua.dark-mode")

-- window management
require("lua.window-utils")
require("lua.layouts")
require("lua.app-hider")
require("lua.splits")

-- system
require("lua.cronjobs")
require("lua.filesystem-watchers")
require("lua.repo-auto-sync")
require("lua.auto-quitter")
require("lua.hardware-periphery")

-- app-specific
require("lua.hide-cursor-in-browser")
require("lua.app-specific-behavior")
require("lua.twitter")

SystemStart()
