-- https://bryankegley.me/posts/nvim-getting-started/
--------------------------------------------------------------------------------

-- vim.o: global-scoped
-- vim.bo: buffer-scoped
-- vim.wo: window-scoped

--------------------------------------------------------------------------------
-- SETTINGS

-- search
vim.o.smartcase = true
vim.o.incsearch = true

-- tabs & indentation
vim.bo.autoindent = true
vim.bo.smartindent = true
vim.o.tabstop = 3
vim.o.softtabstop = 3
vim.o.shiftwidth = 3

-- gutter
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.signcolumn = 'yes'

-- status bar
vim.o.showmode = true

-- misc
vim.wo.wrap = false

--------------------------------------------------------------------------------

-- KEYBINDINGS

vim.g.mapleader = ','
