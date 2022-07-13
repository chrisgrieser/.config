-- https://www.hammerspoon.org/go/

--------------------------------------------------------------------------------

hs.window.animationDuration = 0

--------------------------------------------------------------------------------
-- Hammerspoon itself & Helper Utilities
require("meta")
require("utils")

--------------------------------------------------------------------------------

-- Base
require("scroll-and-cursor")
require("menubar")
require("system-and-cron")
require("window-management")
require("filesystem-watchers")

-- app-specific
require("watchers")
require("discord")
require("twitterrific-iina")

--------------------------------------------------------------------------------

notify("Config reloaded")

-- startup tasks
-- isRunning() conditions, so quick reloading does cause trouble
if not gitDotfileSync:isRunning() then gitDotfileSync:start() end
if not pullSync:isRunning() then
	gitDotfileSync:waitUntilExit() -- needed so sync finishes before pull
	pullSync:start()
end
if not gitVaultBackup:isRunning() then gitVaultBackup:start() end
if not gitVaultBackup:isRunning() then gitVaultBackup:start() end
