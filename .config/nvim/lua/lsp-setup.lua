require("utils")
--------------------------------------------------------------------------------



-- Keymaps
-- https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L1408
keymap("n", "gd", telescope("lsp_definitions{prompt_prefix='💡'}"))
keymap("n", "gD", telescope("lsp_references{prompt_prefix='💡'}"))

