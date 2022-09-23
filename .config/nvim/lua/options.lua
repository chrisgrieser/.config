local opt = vim.opt

-- search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true

-- tabs & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3

-- gutter
opt.relativenumber = false
opt.signcolumn = 'no'
opt.fillchars = 'eob: ' -- hide the "~" marking non-existend lines

-- ruler
opt.textwidth = 80 -- used by `gq`
opt.colorcolumn = '+1' -- column next to text-line
vim.cmd[[highlight ColorColumn ctermbg=0 guibg=black]] -- https://www.reddit.com/r/neovim/comments/me35u9/lua_config_to_set_highlight/

-- editor
-- opt.cursorline = true -- doesn't look good, investigate later
opt.autowrite = true
opt.scrolloff = 10
opt.wrap = false

-- status bar
opt.showcmd = true
opt.showmode = true
opt.laststatus = 0

-- clipboard
opt.clipboard = 'unnamedplus'
