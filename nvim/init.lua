vim.opt.showtabline = 0 -- prevent tabline from flashing on startup

-- If nvim was opened w/o argument, re-open the first oldfile that exists
vim.defer_fn(function()
	-- BUG https://github.com/neovide/neovide/issues/2629
	if vim.fn.argc() > 0 then return end
	for _, file in ipairs(vim.v.oldfiles) do
		if vim.uv.fs_stat(file) and vim.fs.basename(file) ~= "COMMIT_EDITMSG" then
			vim.cmd.edit(file)
			return
		end
	end
end, 1)
--------------------------------------------------------------------------------

-- CONFIG
vim.g.mapleader = ","
vim.g.borderStyle = "rounded" ---@type "single"|"double"|"rounded"|"solid"

vim.g.linterConfigs = vim.fs.normalize("~/.config/+ linter-configs/")
vim.g.syncedData = vim.env.DATA_DIR .. "/vim-data/"
vim.g.localRepos = vim.fs.normalize("~/Developer")

--------------------------------------------------------------------------------

---Try to require the module, and do not error out when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string
local function safeRequire(module)
	local success, errMsg = pcall(require, module)
	if not success then
		local msg = ("Error loading %q: %s"):format(module, errMsg)
		vim.defer_fn(function() vim.notify(msg, vim.log.levels.ERROR) end, 1000)
	end
end

safeRequire("config.options") -- before lazy, so opts still work on plugin install

-- INFO only load plugins when `NO_PLUGINS` is not set. This is for security reasons,
-- e.g. when editing a password with `pass`.
if vim.env.NO_PLUGINS then
	vim.keymap.set("n", "ss", "VP", { desc = "Substitute line" })
	vim.keymap.set("n", "<CR>", "ZZ", { desc = "Save and exit" })
else
	safeRequire("config.lazy")
end

safeRequire("config.theme-customization")
safeRequire("config.neovide-gui-settings")
safeRequire("config.keybindings")
safeRequire("config.leader-keybindings")
safeRequire("config.lsp-and-diagnostics")
safeRequire("config.autocmds")

-- lazy-load spellfixes
vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	callback = function() safeRequire("config.spellfixes") end,
})
