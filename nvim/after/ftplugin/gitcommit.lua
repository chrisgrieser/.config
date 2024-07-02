local keymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

-- options
vim.opt_local.listchars:remove("multispace")

-- spelling
vim.opt_local.spell = true
vim.opt_local.spelloptions = "camel"
keymap("n", "ge", "]s")
keymap("n", "gE", "[s")

-- utility keymap
keymap("i", "<Tab>", "<End>")
keymap("n", "<CR>", "ZZ", { desc = "Confirm" })
keymap("n", "q", vim.cmd.cquit, { desc = "Abort" }) -- quitting with error = aborting commit
