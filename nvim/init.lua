-- If nvim was opened w/o argument, re-open the first oldfile that exists
vim.defer_fn(function()
	if vim.fn.argc() > 0 then return end
	for _, file in ipairs(vim.v.oldfiles) do
		if vim.loop.fs_stat(file) and not file:find("/COMMIT_EDITMSG$") then
			vim.cmd.edit(file)
			return
		end
	end
end, 1)

--------------------------------------------------------------------------------

vim.g.mapleader = ","
vim.g.maplocalleader = ";"
vim.g.borderStyle = "single" ---@type "single"|"double"|"rounded"|"solid"|"none"

vim.g.linterConfigs = os.getenv("HOME") .. "/.config/+ linter-configs/"
vim.g.syncedData = vim.env.DATA_DIR .. "/vim-data/"

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
