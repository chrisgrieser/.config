-- Default vim settings: https://neovim.io/doc/user/vim_diff.html
require("utils")
-------------------------------------------------------------------------------

-- Search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true
opt.wildmenu = true -- display all matching files when tab completing

-- Split
opt.splitright = true -- vsplit to the right instead of to the left
opt.splitbelow = true -- split down instead of up

-- tabs & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true

-- gutter
opt.relativenumber = false
opt.fillchars = 'eob: ' -- hide the ugly "~" marking the end of the buffer

-- ruler
opt.textwidth = 80 -- used by `gq` and wrap
opt.colorcolumn = '+1' -- column next to textwidth option length

-- files
opt.hidden = true -- inactive buffers are only hidden, not unloaded
opt.autochdir = true -- always current directory
opt.autowrite = true -- automatically saves
opt.autowriteall = true
opt.undofile = true -- persistent undo history

-- editor
opt.cursorline = true -- by default underline, look changed in appearnce
opt.wrap = false
opt.scrolloff = 11
opt.sidescrolloff = 15

-- Formatting vim.opt.formatoptions:remove("o") would not work, since it's
-- overwritten by the ftplugins having the o option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
autocmd("BufEnter", {
	callback = function ()
		opt.formatoptions = opt.formatoptions - {"o", "r"}
	end
})

-- Remember Cursor Position
autocmd ("BufReadPost", {
	command = [[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' |  exe "normal! g`\"" | endif]]
})

-- clipboard & yanking
opt.clipboard = 'unnamedplus'
autocmd("TextYankPost", { command = "silent! lua vim.highlight.on_yank{timeout = 2500}", }) -- = highlighted yank

-- Mini-Linting on save
autocmd("BufWritePre", {
	callback = function()
		cmd[[%s/\s\+$//e]] -- remove trailing whitespaces
		cmd[[$s/\(.\)$/\1\r/e]] -- add line breaks at end if there is-none, needs \r: https://stackoverflow.com/questions/71323/how-to-replace-a-character-by-a-newline-in-vim
	end
})

-- don't treat "-" as word boundary for kebab-case variables – https://superuser.com/a/244070
-- (see also the respective "change small word" keybinding <leader><space>)
opt.iskeyword = opt.iskeyword + {"-"}

-- status bar
opt.showcmd = true -- keychords pressed
opt.showmode = false -- don't show "-- Insert --"
opt.laststatus = 2
-- opt.cmdheight = 0 -- hide message line if there is no content (requires nvim 0.8)
-- glitches: https://github.com/nvim-lualine/lualine.nvim/issues/853

-- folding
opt.foldmethod = "indent"
opt.foldenable = false -- do not fold on start

-- title (for Window Managers and espanso)
opt.title = true

-- Mini-Terminal with `:!`
-- loads it as interactive session, so that zshrc is loaded https://stackoverflow.com/a/4642855
opt.shellcmdflag="-ic"




