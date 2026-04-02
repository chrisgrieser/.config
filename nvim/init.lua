---Try to require the module, but do not throw an error when one of them cannot
---be loaded. Without this, any error in one config file would result in the
---remaining config files not being loaded.
---@param module string
local function safeRequire(module)
	local success, errmsg = pcall(require, module)
	if not success then
		local msg = ("Error loading `%s`: %s"):format(module, errmsg)
		vim.schedule(function() vim.notify(msg, vim.log.levels.ERROR) end)
	end
end

---MY VARIABLES-----------------------------------------------------------------
vim.g.localRepos = vim.env.HOME .. "/Developer"
vim.g.notesDir = vim.env.HOME .. "/Notes"
vim.g.iCloudSync = vim.env.HOME .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/nvim-data"

--------------------------------------------------------------------------------

safeRequire("config.reopen-last-file")
safeRequire("config.options") -- before plugins, so they are available for them

-- For extra security, do not load plugins when using `pass`.
-- (requires starting it via `env="USING_PASS=true" pass`)
if vim.env.USING_PASS then
	vim.keymap.set("n", "L", "$")
	vim.keymap.set("n", "H", "0^")
	vim.keymap.set("n", "ss", "VP", { desc = "Substitute line" })
	vim.keymap.set("n", "S", "v$hP", { desc = "Substitute to EoL" })
	vim.keymap.set("n", "<CR>", "ZZ", { desc = "Save and exit", buffer = true })
else
	-- empty funcs to prevent errors when bisecting plugins (-> lualine / whichkey are disabled)
	vim.g.lualineAdd = function() end ---@diagnostic disable-line: duplicate-set-field
	vim.g.whichkeyAddSpec = function() end ---@diagnostic disable-line: duplicate-set-field

	safeRequire("config.lazy") -- load plugins
	safeRequire("config.colorscheme")
end

safeRequire("config.neovide-gui-settings")
safeRequire("config.autocmds")
safeRequire("config.keybindings")

safeRequire("personal-plugins.git-conflict")
safeRequire("config.spellfixes")
vim.schedule(function() safeRequire("personal-plugins.messages-to-notify") end) -- wait for loading notification plugin

-- PENDING neovide not setting filetype https://github.com/neovide/neovide/issues/3444
if vim.bo.ft == "" and vim.g.neovide then pcall(vim.cmd.edit) end
