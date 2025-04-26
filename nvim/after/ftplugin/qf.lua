local bkeymap = require("config.utils").bufKeymap

bkeymap("n", "q", vim.cmd.close, { desc = " Close" })
bkeymap("n", "dd", function()
	local lnum = vim.api.nvim_win_get_cursor(0)[1]

	local qf = vim.fn.getqflist { title = true, items = true }
	table.remove(qf.items, lnum)
	vim.fn.setqflist(qf.items, "r") -- "r" = replace = overwrite
	vim.fn.setqflist({}, "a", { title = qf.title }) -- preserve title of qflist

	vim.api.nvim_win_set_cursor(0, { lnum, 0 })
end, { desc = " Remove quickfix entry" })
