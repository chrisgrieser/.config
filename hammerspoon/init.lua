---HAMMERSPOON SETTINGS---------------------------------------------------------
hs.autoLaunch(true)
hs.menuIcon(false)
hs.automaticallyCheckForUpdates(true)
hs.window.animationDuration = 0

---LOAD MODULES-----------------------------------------------------------------
G = {} ---@diagnostic disable-line: global-element -- persist from garbage collector

---Try to require the module, and do not error when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, M = pcall(require, module)
	G[module:sub(5)] = M
	if not success then
		hs.alert(M, 4)
		print(M)
	end
end

safeRequire("appearance.console")
safeRequire("appearance.hole-cover")
safeRequire("appearance.dark-mode")

safeRequire("win-management.win-mover")
safeRequire("win-management.layouts")
safeRequire("win-management.sketchybar")
safeRequire("win-management.auto-tile")
safeRequire("win-management.vertical-split")
safeRequire("win-management.fallthrough")

safeRequire("system.cronjobs")
safeRequire("system.filesystem-watchers")
safeRequire("system.repo-auto-sync")
safeRequire("system.external-drives")
safeRequire("system.japanese")
safeRequire("system.weather-reminder")

safeRequire("apps.auto-quitter")
safeRequire("apps.app-specific-behavior")
safeRequire("apps.spotify")

safeRequire("meta.reload")
safeRequire("meta.update-typings")
