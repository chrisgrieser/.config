local autocmd = vim.api.nvim_create_autocmd
local bo = vim.bo
local cmd = vim.cmd
local expand = vim.fn.expand
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------

-- Highlights
keymap("n", "<leader>H", function() cmd.Telescope("highlights") end, { desc = " Highlight Groups" })

-- [P]lugins
keymap("n", "<leader>pp", require("lazy").sync, { desc = " Lazy Update/Sync" })
keymap("n", "<leader>ph", require("lazy").home, { desc = " Lazy Overview" })
keymap("n", "<leader>pi", require("lazy").install, { desc = " Lazy Install" })

keymap("n", "<leader>pm", cmd.Mason, { desc = " Mason Overview" })
-- stylua: ignore
keymap("n", "<leader>pt", cmd.TSUpdate, { desc = " Treesitter Parser Update" })

-- Theme Picker
-- stylua: ignore
keymap("n", "<leader>pc", function() cmd.Telescope("colorscheme") end, { desc = "  Change Colorschemes" })
