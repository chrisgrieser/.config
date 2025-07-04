vim.opt.foldlevel = 3

--------------------------------------------------------------------------------

local bkeymap = require("config.utils").bufKeymap

bkeymap("n", "<leader>rp", "<cmd>%! jq .<CR>", { desc = " Prettify Buffer" })
bkeymap("n", "<leader>rm", "<cmd>%! jq --compact-output .<CR>", { desc = " Minify Buffer" })
bkeymap("n", "o", function()
	local line = vim.api.nvim_get_current_line()
	if line:find("[^,{[]$") then return "A,<cr>" end
	return "o"
end, { expr = true, desc = " Auto-add comma on `o`" })
