if not vim.g.neovide then return end
--------------------------------------------------------------------------------
local restartSessionFile = "/tmp/restart.vim"
--------------------------------------------------------------------------------

Keymap {
	"<D-C-r>",
	function()
		vim.cmd("silent! update")
		vim.cmd.mksession { restartSessionFile, bang = true }
		vim.cmd.restart()
	end,
	desc = " Save & restart",
	mode = { "n", "x", "i" },
}

vim.api.nvim_create_autocmd("VimEnter", {
	callback = vim.schedule_wrap(function()
		local isRestarting = vim.uv.fs_stat(restartSessionFile) ~= nil
		local notOpenedWithArgs = vim.fn.argc(-1) == 0

		if isRestarting then
			vim.cmd.source(restartSessionFile)
			pcall(os.remove, restartSessionFile)
		elseif notOpenedWithArgs then
			local lastFile = vim.iter(vim.v.oldfiles):find(function(file)
				local notGitCommitMsg = vim.fs.basename(file) ~= "COMMIT_EDITMSG"
				local exists = vim.uv.fs_stat(file) ~= nil
				return exists and notGitCommitMsg
			end)
			if lastFile then vim.cmd.edit(lastFile) end
		end
	end),
})
