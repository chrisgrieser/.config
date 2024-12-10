local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

-- `:bwipeout` so it isn't saved in oldfiles
bkeymap("n", "q", vim.cmd.bwipeout, { desc = "Quit" })

bkeymap("n", "gs", "gO", { remap = true }) -- `gO` opens the heading-selection in vim help files

vim.diagnostic.enable(false, { bufnr = 0 })
