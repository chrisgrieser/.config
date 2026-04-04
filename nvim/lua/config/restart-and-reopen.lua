local tempfile = "/tmp/neovide-restart"
--------------------------------------------------------------------------------

require("config.utils").uniqueKeymap({ "n", "x", "i" }, "<D-C-r>", function()
	-- FIX
	-- 1. `vim.g.neovide` not set initially during `:restart`
	-- 2. wrong position loading after restart
	if vim.g.neovide then
		local file, errmsg = io.open(tempfile, "w")
		assert(file, errmsg)
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local filepath = vim.api.nvim_buf_get_name(0)
		file:write(table.concat({ filepath, row, col }, ":"))
		file:close()
	end

	vim.cmd("silent! update")
	vim.cmd.restart()
end, { desc = " Save & restart" })

--------------------------------------------------------------------------------

local restoreFunc
local isRestarting = vim.uv.fs_stat(tempfile) ~= nil

return
			local toOpen = vim.iter(vim.v.oldfiles):find(function(file)
				local notGitCommitMsg = vim.fs.basename(file) ~= "COMMIT_EDITMSG"
				local exists = vim.uv.fs_stat(file) ~= nil
				return exists and notGitCommitMsg
			end)
			if toOpen then vim.cmd.edit(toOpen) end
		end),
	})
end
