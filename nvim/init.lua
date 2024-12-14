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
vim.g.maplocalleader = "<Nop>" -- disable `\` being default local leader
vim.g.borderStyle = "single" ---@type "single"|"double"|"rounded"
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

safeRequire("config.options") -- before lazy, so opts are active during plugin install

if not vim.env.NO_PLUGINS then
	-- INFO only load plugins when `NO_PLUGINS` is not set.
	-- This is for security reasons, e.g., when editing a password with `pass`.
	safeRequire("config.lazy")
	vim.g.setColorscheme("init")
end

safeRequire("config.neovide-gui-settings")
safeRequire("config.autocmds")
safeRequire("config.lsp-and-diagnostics")

safeRequire("config.keybindings")
safeRequire("config.quickfix")
safeRequire("config.yanking-and-pasting")

safeRequire("config.backdrop-underline-fix")
safeRequire("personal-plugins.selector")
safeRequire("personal-plugins.git-conflict")

-- lazy-load spellfixes
vim.api.nvim_create_autocmd("InsertEnter", {
	desc = "User(once): Load spellfixes",
	once = true,
	callback = function() safeRequire("config.spellfixes") end,
})
