local M = {}

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
	-- INFO will also run the systemStart function due to reload
end)

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
		if u.isAtOffice then
			sidenotes.MoveOfficeNotesToBase()

		end
		u.notify("Finished loading.")
		visuals.holeCover()
		periphery.batteryCheck("SideNotes")
		repos.syncAllGitRepos("notify")
	end
end

--------------------------------------------------------------------------------
return M
