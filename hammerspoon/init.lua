-- HAMMERPOON SETTINGS
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.window.animationDuration = 0 -- quicker animations
hs.allowAppleScript(true) -- allow external control

hs.hotkey.setLogLevel(0) ---@diagnostic disable-line: undefined-field – suppress log https://github.com/Hammerspoon/hammerspoon/issues/3491
hs.application.enableSpotlightForNameSearches(false) -- suppress log messages

--------------------------------------------------------------------------------

-- appearance
require("lua.visuals")
require("lua.dark-mode")

-- window management
require("lua.window-utils")
require("lua.layouts")
require("lua.app-hider")
require("lua.vertical-split")

-- system
require("lua.console") 
require("lua.cronjobs")
require("lua.filesystem-watchers")
require("lua.repo-auto-sync")
require("lua.auto-quitter")
require("lua.hardware-periphery")

-- app-specific
require("lua.hide-cursor-in-browser")
require("lua.app-specific-behavior")
require("lua.twitter")
require("lua.sidenotes")

-- reload function, should come last
require("lua.reload")
