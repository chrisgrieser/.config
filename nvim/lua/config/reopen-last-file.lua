-- When opening a file with neovide and lazy.nvim opens the startup install
-- window, this is needed to prevent an error, not exactly sure why it works
-- though
if vim.g.neovide then
	vim.api.nvim_create_autocmd("FileType", {
		desc = "User: winfixbuf for lazy window",
		pattern = "lazy",
		callback = function() vim.wo.winfixbuf = true end,
	})
end

vim.api.nvim_create_autocmd("VimEnter", { -- triggers only after `Lazy` startup installs
	desc = "User: Reopen last file",
	callback = vim.schedule_wrap(function() -- schedule ensures not breaking file loading
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
	end),
})
