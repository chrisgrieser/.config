---Try to require the module, and do not error when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, _ = pcall(require, module)
	if not success then hs.alert("⚠️ Error loading " .. module) end
end

--------------------------------------------------------------------------------
-- HAMMERSPOON SETTINGS

hs.autoLaunch(true)
hs.menuIcon(false)
hs.allowAppleScript(true) -- allow external control
hs.automaticallyCheckForUpdates(true)
hs.window.animationDuration = 0 -- quicker animations

-- suppress unnecessary log messages
hs.hotkey.setLogLevel(0) ---@diagnostic disable-line: undefined-field https://github.com/Hammerspoon/hammerspoon/issues/3491
hs.application.enableSpotlightForNameSearches(false)

--------------------------------------------------------------------------------
-- LOAD MODULES

-- appearance
safeRequire("lua.visuals")
safeRequire("lua.dark-mode")

-- window management
safeRequire("lua.window-utils")
safeRequire("lua.layouts")
safeRequire("lua.app-hider")

-- system
safeRequire("lua.console")
safeRequire("lua.cronjobs")
safeRequire("lua.filesystem-watchers")
safeRequire("lua.repo-auto-sync")
safeRequire("lua.auto-quitter")
safeRequire("lua.hardware-periphery")
safeRequire("lua.pageup-pagedown-scroll")
safeRequire("lua.weather-reminder")

-- app-specific
safeRequire("lua.app-specific-behavior")
safeRequire("lua.browser")
safeRequire("lua.twitter-mastodon")
safeRequire("lua.neovim")
safeRequire("lua.tot")

-- reload function (should come last)
safeRequire("lua.reload")
