-- HAMMERPOON SETTINGS
hs.autoLaunch(true)
hs.menuIcon(false)
hs.allowAppleScript(true) -- allow external control
hs.automaticallyCheckForUpdates(true)
hs.window.animationDuration = 0 -- quicker animations

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

-- system
require("lua.console")
require("lua.cronjobs")
require("lua.filesystem-watchers")
require("lua.repo-auto-sync")
require("lua.auto-quitter")
require("lua.hardware-periphery")
require("lua.pageup-pagedown-scroll")

-- app-specific
require("lua.app-specific-behavior")
require("lua.browser")
require("lua.twitter")
require("lua.neovim")
require("lua.sidenotes")

-- other
local month = tostring(os.date()):sub(5, 8)
if month == "Jun" or month == "Jul" or month == "Aug" or month == "Sep" then
	require("lua.weather-reminder")
end

-- reload function (should come last)
require("lua.reload")
