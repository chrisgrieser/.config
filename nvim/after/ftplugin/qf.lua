local bkeymap = require("config.utils").bufKeymap

bkeymap("n", "q", vim.cmd.close, { desc = " Close" })
bkeymap("n", "dd", function()
	local qfItems = vim.fn.getqflist()
	local lnum = vim.api.nvim_win_get_cursor(0)[1]
	table.remove(qfItems, lnum)
	vim.fn.setqflist(qfItems, "r") -- "r" = replace = overwrite
	vim.api.nvim_win_set_cursor(0, { lnum, 0 })
end, { desc = " Remove quickfix entry" })
