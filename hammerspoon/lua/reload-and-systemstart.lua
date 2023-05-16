local M = {}

local env = require("lua.environment-vars")
local layouts = require("lua.layouts")
local periphery = require("lua.hardware-periphery")
local repos = require("lua.repo-auto-sync")
local sidenotes = require("lua.sidenotes")
local u = require("lua.utils")
local visuals = require("lua.visuals")

--------------------------------------------------------------------------------

-- `hammerspoon://hs-reload` for reloading via Build System
local reloadIndicator = "/tmp/hs-is-reloading"
u.urischeme("hs-reload", function()
	hs.execute("touch " .. reloadIndicator)
	hs.reload()
end)

-- systemStart will also run on reload, therefore extra conditional to
-- differentiate between reload and start
function M.systemStart()
	-- do not git sync on reload to prevent commit spam when updating hammerspoon
	-- config regularly
	local _, isReloading = hs.execute("[[ -e " .. reloadIndicator .. " ]]")
	if isReloading then
		print("\n--------------------------- 🔨 HAMMERSPOON RELOAD -------------------------------\n")

		os.remove(reloadIndicator)
		-- use neovim automation to display the notification in neovim
		hs.execute([[echo 'vim.notify("✅ Hammerspoon reloaded. ")' > /tmp/nvim-automation]])
	else
		u.notify("Finished loading.")
		visuals.holeCover()
		periphery.batteryCheck("SideNotes")
		repos.syncAllGitRepos(true, true)
		layouts.selectLayout()
		if env.isAtOffice then
			sidenotes.moveOfficeNotesToBase()
			-- with delay, to avoid importing duplicate reminders due to reminders
			-- not being synced yet
			u.runWithDelays(20, sidenotes.reminderToSidenotes)
		end
	end
end

--------------------------------------------------------------------------------
return M
