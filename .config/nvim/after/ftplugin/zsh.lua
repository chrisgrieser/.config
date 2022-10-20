require("utils")
--------------------------------------------------------------------------------

-- keymap('n', '<leader>h', ":Man", {buffer = true})
keymap('n', '<leader>h', vim.lsp.buf.hover, {buffer = true})
