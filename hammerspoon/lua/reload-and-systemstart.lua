local env = require("lua.environment-vars")
local layouts = require("lua.layouts")
local periphery = require("lua.hardware-periphery")
local repos = require("lua.repo-auto-sync")
local sidenotes = require("lua.sidenotes")
local u = require("lua.utils")
local visuals = require("lua.visuals")

--------------------------------------------------------------------------------

-- trigger `hammerspoon://hs-reload` for reloading via nvim (filetype-config: lua.lua)
local reloadIndicator = "/tmp/hs-is-reloading"
u.urischeme("hs-reload", function()
	hs.execute("touch " .. reloadIndicator)
	hs.reload()
end)

local _, isReloading = hs.execute("[[ -e " .. reloadIndicator .. " ]]")

-- DO ON RELOAD
if isReloading then
	print("\n--------------------------- 🔨 HAMMERSPOON RELOAD -------------------------------\n")
	os.remove(reloadIndicator)
	return
end

-- DO ON SYSTEM STARTUP
visuals.holeCover()
periphery.batteryCheck("SideNotes")
layouts.selectLayout()

-- with delay, to avoid importing duplicate reminders due to reminders
-- not being synced yet
if env.isAtOffice then
	u.runWithDelays(15, function()
		sidenotes.moveOfficeNotesToBase()
		sidenotes.reminderToSidenotes()
	end)
end

u.notify("🔨 Finished loading")
repos.syncAllGitRepos(true)
