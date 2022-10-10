-- Default vim settings: https://neovim.io/doc/user/vim_diff.html
require("utils")
-------------------------------------------------------------------------------

-- Search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true
opt.wildmenu = true -- display all matching files when tab completing

-- Spelling
opt.spell = false
opt.spelllang = "en_us"

cmd[[syntax match UrlNoSpell '\w\+:\/\/[:alnum:]\+' contains=@NoSpell")

-- Gutter
opt.number = true
opt.numberwidth = 3 -- minimum width, save some space for shorter files
opt.relativenumber = true
opt.fillchars = 'eob: ' -- hide the ugly "~" marking the end of the buffer

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.list = true
opt.listchars = "multispace:··,tab:  "

-- remove trailing whitespaces on save
augroup("Mini-Lint",{})
autocmd("BufWritePre", {
	group = "Mini-Lint",
	callback = function ()
		local save_view = fn.winsaveview() -- save cursor positon
		cmd[[%s/\s\+$//e]]
		fn.winrestview(save_view)
	end
})

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- hide line numbers on window split
augroup("linenumberSplit", {})
autocmd({"WinLeave", "WinEnter", "WinClosed"},{
	group = "linenumberSplit",
	callback = function ()
		local isVsplit = fn.winlayout()[1] == "row"
		if isVsplit then
			opt.number = false
			opt.relativenumber = false
		else
			opt.number = true
			opt.relativenumber = true
		end
	end
})

-- Command line
opt.history = 777 -- do not save too much history to reduce noise for command line history search

-- Mouse
opt.mousemodel="extend" -- deacvitate context menu, right mouse instead expands selection

-- ruler
opt.textwidth = 80 -- used by `gq` and wrap
opt.colorcolumn = '+1' -- column next to textwidth option length
opt.wrap = false

-- files
opt.hidden = true -- inactive buffers are only hidden, not unloaded
opt.undofile = true -- persistent undo history
opt.confirm = true -- unsaved bufers trigger confirmation prompt instead of failing
opt.autochdir = true -- always current directory
autocmd({"BufWinEnter"}, { -- since autochdir is not always reliable...?
	command = "cd %:p:h"
})

-- auto-save
autocmd({"BufWinLeave", "BufLeave", "QuitPre", "FocusLost", "InsertLeave"}, {
	pattern = "?*",
	command = "silent! update"
})

-- editor
opt.cursorline = true -- by default underline, look changed in appearnce
opt.scrolloff = 12
opt.sidescrolloff = 21

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
autocmd("TextYankPost", { command = "silent! lua vim.highlight.on_yank{timeout = 2500}" })

-- don't treat "-" as word boundary for kebab-case variables – https://superuser.com/a/244070
-- (see also the respective "change small word" keybinding <leader><space>)
opt.iskeyword = opt.iskeyword + {"-", "_"}

-- status bar
opt.showcmd = true -- keychords pressed
opt.showmode = false -- don't show "-- Insert --"
opt.laststatus = 3 -- show one status line for all splits

-- folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()" -- use treesitter for folding https://github.com/nvim-treesitter/nvim-treesitter
opt.foldenable = false -- do not fold on start
opt.foldminlines = 2
augroup("rememberFolds", {}) -- keep folds on save https://stackoverflow.com/questions/37552913/vim-how-to-keep-folds-on-save
autocmd("BufWinLeave", {
	pattern = "?*",
	group = "rememberFolds",
	command = "silent! mkview"
})
autocmd("BufWinEnter", {
	pattern = "?*",
	group = "rememberFolds",
	command = "silent! loadview"
})

-- Window Managers
opt.title = true -- title (for Window Managers and espanso)
opt.titlestring='%{expand(\"%:p\")} [%{mode()}]'


