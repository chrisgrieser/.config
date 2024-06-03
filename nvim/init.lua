-- If nvim was opened w/o argument, re-open the first oldfile that exists
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(ctx)
		for _, file in ipairs(vim.v.oldfiles) do
			if vim.uv.fs_stat(file) and vim.fs.basename(file) ~= "COMMIT_EDITMSG" then
				vim.cmd.edit(file)
				return
			end
		end
	end,
})

--------------------------------------------------------------------------------

-- CONFIG
vim.g.mapleader = ","
vim.g.borderStyle = "single" ---@type "single"|"double"|"rounded"|"solid"|"none"

vim.g.linterConfigs = vim.fs.normalize("~/.config/+ linter-configs/")
vim.g.dictionaryFile = vim.g.linterConfigs .. "/spellfile-vim-ltex.add"
vim.g.syncedData = vim.env.DATA_DIR .. "/vim-data/"
vim.g.localRepos = vim.fs.normalize("~/repos")

--------------------------------------------------------------------------------

---Try to require the module, and do not error out when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string
local function safeRequire(module)
	local success, errMsg = pcall(require, module)
	if not success then
		local msg = ("Error loading %s\n%s"):format(module, errMsg)
		vim.defer_fn(function() vim.notify(msg, vim.log.levels.ERROR) end, 1000)
	end
end

safeRequire("config.lazy")
safeRequire("config.neovide-gui-settings")
safeRequire("config.theme-customization")
safeRequire("config.options-and-autocmds")
safeRequire("config.keybindings")
safeRequire("config.leader-keybindings")
safeRequire("config.lsp-and-diagnostics")

-- lazy-load spellfixes
vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	callback = function() safeRequire("config.spellfixes") end,
})
