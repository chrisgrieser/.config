local tempfile = "/tmp/neovide-restart"
--------------------------------------------------------------------------------

require("config.utils").uniqueKeymap({ "n", "x", "i" }, "<D-C-r>", function()
	-- FIX
	-- 1. `vim.g.neovide` not set initially during `:restart`
	-- 2. wrong position loading after restart
	-- 3. wrong background
	if vim.g.neovide then
		local file, errmsg = io.open(tempfile, "w")
		assert(file, errmsg)
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local filepath = vim.api.nvim_buf_get_name(0)
		file:write(table.concat({ filepath, row, col, vim.o.background }, ":"))
		file:close()
	end

	vim.cmd("silent! update")
	vim.cmd.restart()
end, { desc = " Save & restart" })

--------------------------------------------------------------------------------

local restoreFunc
local isRestarting = vim.uv.fs_stat(tempfile) ~= nil

if isRestarting then
	-- FIX #1 `vim.g.neovide` not set initially
	vim.g.neovide = true

	-- FIX #2 wrong position & background
	local file, errmsg = io.open(tempfile, "r")
	assert(file, errmsg)
	local content = file:read("*a")
	local prevFile, row, col, background = unpack(vim.split(content, ":"))
	vim.o.background = background
	file:close()
	local reopenPrevPosition = function()
		vim.cmd.edit(prevFile)
		vim.api.nvim_win_set_cursor(0, { tonumber(row), tonumber(col) })
	end
	restoreFunc = reopenPrevPosition

	pcall(os.remove, tempfile)
else
	local reopenLastFile = function()
		local wasOpenedWithArgs = vim.fn.argc(-1) > 0
		if wasOpenedWithArgs then return end
		local toOpen = vim.iter(vim.v.oldfiles):find(function(file)
			local notGitCommitMsg = vim.fs.basename(file) ~= "COMMIT_EDITMSG"
			local exists = vim.uv.fs_stat(file) ~= nil
			return exists and notGitCommitMsg
		end)
		if toOpen then vim.cmd.edit(toOpen) end
	end
	restoreFunc = reopenLastFile
end

--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("VimEnter", {
	desc = "User: re-open last file",
	callback = vim.schedule_wrap(restoreFunc),
})
