if not vim.g.neovide then return end
--------------------------------------------------------------------------------
local restartSession = "/tmp/restart.vim"
--------------------------------------------------------------------------------

Keymap {
	"<D-C-r>",
	function()
		vim.cmd("silent! update")
		vim.cmd.mksession { restartSession, bang = true }
		vim.cmd.restart()
	end,
	desc = " Save & restart",
	mode = { "n", "x", "i" },
}

vim.api.nvim_create_autocmd("VimEnter", {
	callback = vim.schedule_wrap(function()
		local isRestarting = vim.uv.fs_stat(restartSession) ~= nil
		local notOpenedWithArgs = vim.fn.argc(-1) == 0

		if isRestarting then
			vim.cmd.source(restartSession)
			pcall(os.remove, restartSession)
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
