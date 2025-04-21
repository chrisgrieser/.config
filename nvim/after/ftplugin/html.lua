local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

bkeymap("n", "<leader>ep", function()
	vim.cmd("silent update")
	vim.ui.open(vim.api.nvim_buf_get_name(0))
end, { desc = " Preview" })
