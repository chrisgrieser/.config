vim.api.nvim_create_autocmd("VimEnter", { -- triggers only after `Lazy` startup installs
	desc = "User: Reopen last file",
	callback = function()
		vim.schedule(function() -- `vim.schedule` ensures not breaking file loading
			local toOpen

			-- reopen last file if neovim was opened without arguments
			if vim.fn.argc(-1) == 0 then
				toOpen = vim.iter(vim.v.oldfiles):find(function(file)
					local notGitCommitMsg = vim.fs.basename(file) ~= "COMMIT_EDITMSG"
					local exists = vim.uv.fs_stat(file) ~= nil
					return exists and notGitCommitMsg
				end)
			end

			-- neovide: fix for not opening the file when lazy.nvim does installs on startup
			if vim.fn.argc(-1) > 0 and vim.g.neovide and vim.bo.ft == "lazy" then
				local arg = vim.fn.argv(0) --[[@as string]]
				toOpen = vim.startswith(arg, "/") and arg or vim.env.HOME .. "/" .. arg
			end

			-- lazy.nvim: ensures not triggering on startup win
			if not toOpen then return end
			if vim.bo.ft == "lazy" then
				local initialWinId = 1000
				vim.api.nvim_win_call(initialWinId, function() vim.cmd.edit(toOpen) end)
			else
				vim.cmd.edit(toOpen)
			end
		end)
	end,
})

--------------------------------------------------------------------------------

---Try to require the module, but do not throw error when one of them cannot be
---loaded. Without this, any error in one config file will result in the
---remaining config not being loaded.
---@param module string
local function safeRequire(module)
	local success, errmsg = pcall(require, module)
	if not success then
		local msg = ("Error loading `%s`: %s"):format(module, errmsg)
		vim.schedule(function() vim.notify(msg, vim.log.levels.ERROR) end)
	end
end

safeRequire("config.options") -- first so available for plugins configs

if not vim.env.NO_PLUGINS then -- for security, such as when editing a password with `pass`
	safeRequire("config.lazy")
	if vim.g.setColorscheme then vim.g.setColorscheme("init") end
end

safeRequire("personal-plugins.ui-hack") -- requires notification plugin to be already loaded
safeRequire("config.neovide-gui-settings")
safeRequire("config.autocmds")
safeRequire("config.keybindings")

safeRequire("personal-plugins.git-conflict")
safeRequire("config.backdrop-underline-fix")
safeRequire("config.spellfixes")
