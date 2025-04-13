-- re-open last file, if nvim was opened without arguments
vim.defer_fn(function()
	if vim.fn.argc() > 0 then return end
	local lastFile = vim.iter(vim.v.oldfiles):find(function(file)
		local notGitCommit = vim.fs.basename(file) ~= "COMMIT_EDITMSG"
		local exists = vim.uv.fs_stat(file)
		return exists and notGitCommit
	end)
	if lastFile then vim.cmd.edit(lastFile) end
end, 1)

--------------------------------------------------------------------------------

---Try to require the module, but do not throw error when one of them cannot be
---loaded. This prevents the entire remaining config from not being loaded if
---just one module has an error.
---@param module string
local function safeRequire(module)
	local success, errmsg = pcall(require, module)
	if success then return end

	local msg = ("Error loading `%s`: %s"):format(module, errmsg)
	vim.defer_fn(function() vim.notify(msg, vim.log.levels.ERROR) end, 500)
end

-- before `lazy`, so the options are active during plugin install, and available
-- for plugin configs
safeRequire("config.options")

-- only load plugins & LSPs when `NO_PLUGINS` is not set.
-- (This is for security reasons, e.g., when editing a password with `pass`.)
if not vim.env.NO_PLUGINS then
	safeRequire("config.lazy")
	safeRequire("config.lsp-servers") -- after lazy, so mason/blink/lspconfig are available
	if vim.g.setColorscheme then vim.g.setColorscheme("init") end
end

safeRequire("config.neovide-gui-settings")
safeRequire("config.autocmds")
safeRequire("config.keybindings")

--------------------------------------------------------------------------------

safeRequire("personal-plugins.git-conflict")
safeRequire("config.backdrop-underline-fix")

vim.api.nvim_create_autocmd("InsertEnter", {
	desc = "User(once): Lazyload spellfixes",
	once = true,
	callback = function() safeRequire("config.spellfixes") end,
})
