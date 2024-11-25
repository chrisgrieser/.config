local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

-- options
vim.opt_local.listchars:remove("multispace") -- spacing in comments

-- spelling
vim.opt_local.spell = true
vim.opt_local.spelloptions = "camel"

--------------------------------------------------------------------------------

bkeymap("n", "ge", "]s")
bkeymap("n", "gE", "[s")

-- utility keymap
bkeymap("i", "<Tab>", "<End>")
bkeymap("n", "<Tab>", "A")

-- condition prevents mapping `DressingInput`, which already has its own mappings
if vim.bo.buftype ~= "nofile" then
	bkeymap("n", "<CR>", "ZZ", { desc = "Confirm" }) -- quitting with saving = committing
	bkeymap("n", "q", vim.cmd.cquit, { desc = "Abort" }) -- quitting with error = aborting commit
	vim.opt_local.colorcolumn = "73"
end

--------------------------------------------------------------------------------

local firstLine = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
if firstLine == "# *** SAY WHY WE ARE REVERTING ON THE TITLE LINE ***" then
	local newLine = "revert: "
	vim.api.nvim_buf_set_lines(0, 0, 1, false, { "" })
	vim.api.nvim_win_set_cursor(0, { 1, #newLine })
	vim
end
