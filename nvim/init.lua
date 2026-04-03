---MY VARIABLES-----------------------------------------------------------------
vim.g.localRepos = vim.env.HOME .. "/Developer"
vim.g.notesDir = vim.env.HOME .. "/Notes"
vim.g.iCloudSync = vim.env.HOME .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/nvim-data"

---REOPEN LAST FILE IF NO FILE TO OPEN------------------------------------------
vim.api.nvim_create_autocmd("VimEnter", {
	desc = "User: re-open last file",
	callback = function()
		if vim.fn.argc(-1) > 0 then return end -- was opened with args
		local toOpen = vim.iter(vim.v.oldfiles):find(function(file)
			local notGitCommitMsg = vim.fs.basename(file) ~= "COMMIT_EDITMSG"
			local exists = vim.uv.fs_stat(file) ~= nil
			return exists and notGitCommitMsg
		end)
		if toOpen then vim.cmd.edit(toOpen) end
	end,
})

---LOAD MODULES-----------------------------------------------------------------
local sRequire = require("config.utils").safeRequire

sRequire("config.options") -- before plugins, so they are available for them
sRequire("config.neovide-gui-settings")

sRequire("config.nvim-pack")
sRequire("config.colorscheme")

sRequire("config.autocmds")
sRequire("config.keybindings")

sRequire("personal-plugins.git-conflict")
sRequire("config.spellfixes")
sRequire("personal-plugins.messages-to-notify")

-- PENDING neovide not setting filetype https://github.com/neovide/neovide/issues/3444
vim.schedule(function()
	if vim.bo.ft == "" and vim.g.neovide then pcall(vim.cmd.edit) end
end)
