---MY VARIABLES-----------------------------------------------------------------
vim.g.localRepos = vim.env.HOME .. "/Developer"
vim.g.notesDir = vim.env.HOME .. "/Notes"
vim.g.iCloudSync = vim.env.HOME .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/nvim-data"

--------------------------------------------------------------------------------

safeRequire("config.reopen-last-file")
safeRequire("config.options") -- before plugins, so they are available for them

do -- load plugins
	-- empty funcs to prevent errors when bisecting plugins (-> lualine / whichkey are disabled)
	vim.g.lualineAdd = function() end ---@diagnostic disable-line: duplicate-set-field
	vim.g.whichkeyAddSpec = function() end ---@diagnostic disable-line: duplicate-set-field

	safeRequire("config.load-plugins")
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
