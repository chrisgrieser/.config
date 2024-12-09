local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

bkeymap("n", "q", vim.cmd.bdelete, { desc = "Quit" })
bkeymap("n", "gs", "gO", { remap = true }) -- `gO` opens the heading-selection in vim help files
