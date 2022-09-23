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

-- Formatting vim.opt.formatoptions:remove("o") would not work, since it's
-- overwritten by the ftplugins having the o option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
-- - "o" options adds comment syntax when using `o` or `O` https://neovim.io/doc/user/change.html#fo-table
vim.api.nvim_create_autocmd("BufEnter", { callback = function()
	vim.opt.formatoptions = vim.opt.formatoptions - {"o"}
end })

-- status bar
opt.showcmd = true
opt.showmode = true
opt.laststatus = 0

-- clipboard
opt.clipboard = 'unnamedplus'

