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
-- require("hot-corner-action")
require("usb-watchers")

-- app-specific
require("app-watchers")
require("discord")
require("twitterrific-iina")

--------------------------------------------------------------------------------
-- Startup
notify("Config reloaded")
reloadAllMenubarItems()
gitDotfileSync("wake")
if isAtOffice() then systemWake() end



dotfileSyncMenuBar:setClickCallback(function ()
	local lastCommit = hs.execute('git log -1 --format=%ar')
	lastCommit = trim(lastCommit)
	dotfileSyncMenuBar:setTooltip(lastCommit)
	local minTillSync = math.floor(repoSyncTimer:nextTrigger() / 60)
	notify("last commit "..lastCommit.."\r\rnext sync in "..tostring(minTillSync).." min")
end)
