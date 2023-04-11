require("lua.utils")

-- `hammerspoon://hs-reload` for reloading via Build System
local reloadIndicator = "/tmp/hs-is-reloading"
u.urischeme("hs-reload", function()
	hs.execute("touch " .. reloadIndicator)
	hs.reload()
	-- INFO will also run the systemStart function due to reload
end)

function SystemStart()
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
		HoleCover()
		PeripheryBatteryCheck("notify")
		SyncAllGitRepos("notify")
	end
end
