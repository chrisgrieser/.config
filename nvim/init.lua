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

-- For extra security, do not load plugins when using `pass`.
--(requires starting it via `env="USING_PASS=true" pass`)
if vim.env.USING_PASS then
	vim.keymap.set("n", "ss", "VP", { desc = "Substitute line", buffer = true })
	vim.keymap.set("n", "S", "v$P", { desc = "Substitute to EoL", buffer = true })
	vim.keymap.set("n", "<CR>", "ZZ", { desc = "Save and exit", buffer = true })
else
	safeRequire("config.lazy")
	if vim.g.setColorscheme then vim.g.setColorscheme("init") end
end
safeRequire("config.neovide-gui-settings")
safeRequire("config.autocmds")
safeRequire("config.keybindings")

safeRequire("personal-plugins.git-conflict")
safeRequire("config.spellfixes")
vim.schedule(function() safeRequire("personal-plugins.ui-hack") end) -- wair for loading notification plugin
