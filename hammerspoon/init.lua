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
safeRequire("modules.console")
safeRequire("modules.visuals")
safeRequire("modules.dark-mode")

-- window management
safeRequire("modules.window-utils")
safeRequire("modules.layouts")
safeRequire("modules.app-hider")
safeRequire("modules.auto-quitter")

-- system
safeRequire("modules.cronjobs")
safeRequire("modules.filesystem-watchers")
safeRequire("modules.repo-auto-sync")
safeRequire("modules.hardware-periphery")
safeRequire("modules.pageup-pagedown-scroll")
safeRequire("modules.vertical-split")
safeRequire("modules.weather-reminder")

-- app-specific
safeRequire("modules.app-specific-behavior")
safeRequire("modules.browser")
safeRequire("modules.spotify")
safeRequire("modules.mastodon")

-- reload function (should come last)
safeRequire("modules.reload")
