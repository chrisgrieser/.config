-- Default vim settings: https://neovim.io/doc/user/vim_diff.html
require("utils")
-------------------------------------------------------------------------------

-- search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true

-- tabs & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true

-- gutter
opt.relativenumber = false
opt.signcolumn = 'no'
opt.fillchars = 'eob: ' -- hide the "~" marking non-existent lines

-- ruler
opt.textwidth = 80 -- used by `gq`
opt.colorcolumn = '+1' -- column next to textwidth option length

-- files
opt.hidden = true -- inactive buffers are only hidden, not unloaded
-- opt.autochdir = true -- makes telescope more usable

opt.autowrite = true -- automatically saves on switching buffer
opt.updatetime = 5000 -- ms
autocmd({"CursorHold"}, function () -- autosave files
	cmd("update")
end)

-- editor
opt.cursorline = true -- by default underline
opt.wrap = false
opt.scrolloff = 11
opt.sidescrolloff = 5

-- Formatting vim.opt.formatoptions:remove("o") would not work, since it's
-- overwritten by the ftplugins having the o option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
autocmd("BufEnter", function ()
	-- "o" adds comment syntax when using `o` or `O` https://neovim.io/doc/user/change.html#fo-table
	opt.formatoptions = opt.formatoptions - {"o", "r"}
end)

-- status bar
opt.showcmd = true -- keychords pressed
opt.showmode = false -- don't show "-- Insert --"
opt.laststatus = 2 -- show always
-- opt.cmdheight = 0 -- TODO: uncomment with neovim 0.8 adding support for it

-- clipboard & yanking
opt.clipboard = 'unnamedplus'
cmd[[au TextYankPost * silent! lua vim.highlight.on_yank{timeout = 3000} ]] -- highlighted yank

-- Mini-Linting on save
autocmd("BufWritePre",  function()
	cmd[[%s/\s\+$//e]] -- remove trailing whitespaces
	cmd[[$s/\(.\)$/\1\r/e]] -- add line breaks at end if there is-none, needs \r: https://stackoverflow.com/questions/71323/how-to-replace-a-character-by-a-newline-in-vim
end )

-- don't treat "-" as word boundary for kebab-case variables – https://superuser.com/a/244070
opt.iskeyword = opt.iskeyword + {"-"}

-- folding
opt.foldmethod = "indent"
opt.foldenable = false

-- title (for Window Managers and Espanso)
opt.title = true



