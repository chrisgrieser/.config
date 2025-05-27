vim.api.nvim_create_autocmd("VimEnter", { -- `VimEnter` triggers only after `Lazy` startup installs
	desc = "User: Reopen last file if neovim has no args",
	callback = function()
		if vim.fn.argc(-1) > 0 then return end
		vim.schedule(function() -- `vim.schedule` ensures not breaking file loading
			local lastExistingFile = vim.iter(vim.v.oldfiles):find(vim.uv.fs_stat)
			if not lastExistingFile then return end
			local initialWinId = 1000 -- ensures not triggering on `Lazy` startup installs
			vim.api.nvim_win_call(initialWinId, function() vim.cmd.edit(lastExistingFile) end)
		end)
	end,
})

--------------------------------------------------------------------------------

---Try to require the module, but do not throw error when one of them cannot be
---loaded. Without this, any error in one config file will result in the
---remaining config not being loaded.
---@param module string
local function safeRequire(module)
	local success, errmsg = pcall(require, module)
	if not success then
		local msg = ("Error loading `%s`: %s"):format(module, errmsg)
		vim.defer_fn(function() vim.notify(msg, vim.log.levels.ERROR) end, 500)
	end
end

safeRequire("config.options") -- first so available for plugins configs

if not vim.env.NO_PLUGINS then -- for security, such as when editing a password with `pass`
	safeRequire("config.lazy")
	if vim.g.setColorscheme then vim.g.setColorscheme("init") end
end

safeRequire("personal-plugins.ui-hack") -- requires notification plugin to be already loaded
safeRequire("config.neovide-gui-settings")
safeRequire("config.autocmds")
safeRequire("config.keybindings")

safeRequire("personal-plugins.git-conflict")
safeRequire("config.backdrop-underline-fix")
safeRequire("config.spellfixes")

vim.api.nvim_create_autocmd("InsertEnter", {
	desc = "User(once): Lazyload spellfixes",
	once = true,
	callback = function()
		local timelogStart1 = os.clock() -- 🪚
		safeRequire("config.spellfixes")
		vim.notify(("#1 🪚: %.3fs"):format(os.clock() - timelogStart1))
	end,
})
