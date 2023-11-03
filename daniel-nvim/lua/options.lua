-- set relative line numbers, but keep current line as absolute
vim.wo.relativenumber = true
vim.wo.number = true

-- yank to clipboard
vim.o.clipboard="unnamed,unnamedplus"

-- save undo history
vim.o.undofile = true

-- set some tab behaviour
vim.o.sw = 2    -- shiftwidth: if I press tab, put this many spaces
vim.o.et = true -- expand tabs to spaces
vim.o.ts = 8    -- compatibility with garbage code in GNU C and old Haskell :^)

vim.o.tw = 80
vim.o.cc = '+1'
