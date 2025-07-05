---Try to require the module, but do not throw error when one of them cannot be
---loaded. Without this, any error in one config file would result in the
---remaining config files not being loaded.
---@param module string
local function safeRequire(module)
	local success, errmsg = pcall(require, module)
	if not success then
		local msg = ("Error loading `%s`: %s"):format(module, errmsg)
		vim.schedule(function() vim.notify(msg, vim.log.levels.ERROR) end)
	end
end
--------------------------------------------------------------------------------

safeRequire("config.reopen-last-file")
safeRequire("config.options") -- first so available for plugins configs

if vim.env.NO_PLUGINS then
	safeRequire("config.lazy")
	if vim.g.setColorscheme then vim.g.setColorscheme("init") end
else
	-- mappings for when using `pass`
	vim.keymap.set("n", "ss", "VP", { desc = "Substitute line" })
	vim.keymap.set("n", "<CR>", "ZZ", { desc = "Save and exit" })
end

safeRequire("personal-plugins.ui-hack") -- requires notification plugin to be already loaded
safeRequire("config.neovide-gui-settings")
safeRequire("config.autocmds")
safeRequire("config.keybindings")

safeRequire("personal-plugins.git-conflict")
safeRequire("config.spellfixes")
