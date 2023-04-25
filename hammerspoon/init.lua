local u = require("lua.utils")
local system = require("lua.reload-and-systemstart")
--------------------------------------------------------------------------------

-- SETTINGS
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.application.enableSpotlightForNameSearches(false) -- suppress useless console msgs
hs.window.animationDuration = 0 -- quicker animations
hs.allowAppleScript(true) -- allow external control

--------------------------------------------------------------------------------
-- ENVIRONMENT
-- retrieve configs from zshenv; looped since sometimes not loading properly
local i = 0
while true do
	DotfilesFolder = os.getenv("DOTFILE_FOLDER")
	PasswordStore = os.getenv("PASSWORD_STORE_DIR")
	VaultLocation = os.getenv("VAULT_PATH")
	FileHub = os.getenv("WD")
	if DotfilesFolder then break end
	hs.timer.usleep(1000000) -- = one second (Blocking!)
	i = i + 1
	if i > 30 then
		u.notify("⚠️ Could not retrieve .zshenv")
		return
	end
end

--------------------------------------------------------------------------------
-- meta
require("lua.console")

-- appearance
require("lua.visuals")
require("lua.dark-mode")

-- window management
require("lua.window-utils")
require("lua.layouts")
require("lua.app-hider")
require("lua.vertical-split")

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
require("lua.sidenotes")

system.systemStart()
