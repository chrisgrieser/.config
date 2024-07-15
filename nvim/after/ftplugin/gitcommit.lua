local keymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

-- options
vim.opt_local.listchars:remove("multispace") -- spacing in comments

-- spelling
vim.opt_local.spell = true
vim.opt_local.spelloptions = "camel"
keymap("n", "ge", "]s")
keymap("n", "gE", "[s")

-- utility keymap
keymap("i", "<Tab>", "<End>")
keymap("n", "<Tab>", "A")

-- condition prevents mapping `DressingInput`, which already has its own mappings
if vim.bo.buftype ~= "nofile" then
	keymap("n", "<CR>", "ZZ", { desc = "Confirm" }) -- quitting with saving = committing
	keymap("n", "q", vim.cmd.cquit, { desc = "Abort" }) -- quitting with error = aborting commit
end
