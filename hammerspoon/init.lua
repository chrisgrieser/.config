G = {} -- persist from garbage collector

---Try to require the module, and do not error when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, M = pcall(require, module)
	G[module:sub(5)] = M
	if not success then
		hs.alert.show(M, 5)
		print(M)
	end
end

--------------------------------------------------------------------------------
-- HAMMERSPOON SETTINGS

hs.autoLaunch(true)
hs.menuIcon(false)
hs.automaticallyCheckForUpdates(true)
hs.window.animationDuration = 0 -- quicker animations

--------------------------------------------------------------------------------
-- LOAD MODULES

-- appearance
safeRequire("lua.console")
safeRequire("lua.visuals")
safeRequire("lua.dark-mode")

-- window management
safeRequire("lua.window-utils")
safeRequire("lua.layouts")
safeRequire("lua.app-hider")
safeRequire("lua.auto-quitter")

-- system
safeRequire("lua.cronjobs")
safeRequire("lua.filesystem-watchers")
safeRequire("lua.repo-auto-sync")
safeRequire("lua.hardware-periphery")
safeRequire("lua.pageup-pagedown-scroll")
safeRequire("lua.vertical-split")
safeRequire("lua.weather-reminder")

-- app-specific
safeRequire("lua.app-specific-behavior")
safeRequire("lua.browser")
safeRequire("lua.mastodon")

-- reload function (should come last)
safeRequire("lua.reload")
