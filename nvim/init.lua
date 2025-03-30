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

vim.g.mapleader = ","
vim.g.maplocalleader = "<Nop>"
vim.g.localRepos = vim.fs.normalize("~/Developer")

--------------------------------------------------------------------------------

---Try to require the module, but do not throw error when one of them cannot be
---loaded. This prevents the entire remaining config from not being loaded if
---just one module has an error.
---@param module string
local function safeRequire(module)
	local success, errmsg = pcall(require, module)
	if not success then
		local msg = ("Error loading `%s`: %s"):format(module, errmsg)
		vim.defer_fn(function() vim.notify(msg, vim.log.levels.ERROR) end, 1000)
	end
end

-- before lazy, so they are active during plugin install and available for plugin configs
safeRequire("config.options")

-- only load plugins when `NO_PLUGINS` is not set.
-- (This is for security reasons, e.g., when editing a password with `pass`.)
if not vim.env.NO_PLUGINS then
	safeRequire("config.lazy")
	if vim.g.setColorscheme then vim.g.setColorscheme("init") end
end

safeRequire("config.neovide-gui-settings")
safeRequire("config.autocmds")

safeRequire("config.keybindings")
safeRequire("personal-plugins.quickfix")

safeRequire("personal-plugins.selector")
safeRequire("personal-plugins.git-conflict")
safeRequire("config.backdrop-underline-fix")

vim.api.nvim_create_autocmd("InsertEnter", {
	desc = "User(once): Lazyload spellfixes",
	once = true,
	callback = function() safeRequire("config.spellfixes") end,
})
