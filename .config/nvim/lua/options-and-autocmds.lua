require("utils")
-- Default vim settings: https://neovim.io/doc/user/vim_diff.html
--------------------------------------------------------------------------------

-- timeout for awaiting keystrokes
opt.timeoutlen = 2000 -- because I'm slow lol

-- Search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true

-- Popup
opt.pumheight = 15 -- max number of items in popup menu
opt.pumwidth = 10 -- min width popup menu

-- Spelling
opt.spell = false
opt.spelllang = "en_us"

-- Gutter
opt.fillchars = "eob: " -- hide the ugly "~" marking the end of the buffer
opt.numberwidth = 3 -- minimum width, save some space for shorter files
opt.number = false
opt.relativenumber = false

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.smartindent = true
opt.list = true
opt.listchars = "multispace:··,tab:  ,nbsp:ﮊ"
opt.virtualedit = "block" -- select whitespace for proper rectangles in visual block mode

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Mouse
opt.mousemodel = "extend" -- deacvitate context menu, right mouse instead expands selection

-- Window Managers/espanso: set title
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = "%{expand(\"%:p\")} [%{mode()}]"

-- Editor
opt.cursorline = true
opt.scrolloff = 12
opt.sidescrolloff = 24
opt.textwidth = 80 -- used by `gq` wrap, etc.
opt.wrap = false
opt.colorcolumn = "+1" -- relative to textwidth
opt.signcolumn = "yes:1" -- = gutter

-- Formatting vim.opt.formatoptions:remove("o") would not work, since it's
-- overwritten by the ftplugins having the o option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
augroup("formatopts", {})
autocmd("BufEnter", {
	group = "formatopts",
	callback = function()
		if not (bo.filetype == "markdown") then -- not for markdown, for autolist hack (see markdown.lua)
			bo.formatoptions = bo.formatoptions:gsub("r", ""):gsub("o", "")
		end
	end
})

-- Remember Cursor Position
augroup("rememberCursorPosition", {})
autocmd("BufReadPost", {
	group = "rememberCursorPosition",
	command = [[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' |  exe "normal! g`\"" | endif]]
})

-- clipboard & yanking
opt.clipboard = "unnamedplus"
augroup("highlightedYank", {})
autocmd("TextYankPost", {
	group = "highlightedYank",
	callback = function() vim.highlight.on_yank {timeout = 2000} end
})

-- don't treat "-" as word boundary
opt.iskeyword:append("-")

--------------------------------------------------------------------------------

-- FILES & SAVING
opt.hidden = true -- inactive buffers are only hidden, not unloaded
opt.undofile = true -- persistent undo history
opt.confirm = true -- unsaved bufers trigger confirmation prompt instead of failing
opt.updatetime = 50 -- affects current symbol highlight from treesitter-refactor and currentline hints
opt.autochdir = true -- always current directory
augroup("autocd", {})
autocmd("BufWinEnter", {-- since autochdir is not always reliable…?
	group = "autocd",
	command = "cd %:p:h",
})

augroup("autosave", {})
autocmd({"BufWinLeave", "BufLeave", "QuitPre", "FocusLost", "InsertLeave"}, {
	group = "autosave",
	pattern = "?*",
	command = "silent! update"
})

augroup("Mini-Lint", {}) -- trim trailing whitespaces & extra blanks at eof on save
autocmd("BufWritePre", {
	group = "Mini-Lint",
	callback = function()
		if bo.filetype == "markdown" then return end -- to preserve spaces from the two-space-rule, and trailing spaces on sentences
		local save_view = fn.winsaveview() -- save cursor positon
		cmd [[%s/\s\+$//e]]
		cmd [[silent! %s#\($\n\s*\)\+\%$##]] -- https://stackoverflow.com/a/7496112
		fn.winrestview(save_view)
	end
})

--------------------------------------------------------------------------------

-- status bar & cmdline
opt.showcmd = true -- keychords pressed
opt.showmode = false -- don't show "-- Insert --"
opt.shortmess:append("S") -- do not show search count, since lualine does it already
opt.cmdheight = 0 -- effectively also redundant with all of the above
opt.laststatus = 3 -- = global status line
opt.history = 250 -- do not save too much history to reduce noise for command line history search

augroup("clearCmdline", {})
autocmd("BufEnter", {
	group = "clearCmdline",
	command = "echo", -- clear cmdline on entering buffer
})

--------------------------------------------------------------------------------

-- folding
opt.foldmethod = "indent"
opt.foldenable = false -- do not fold on start
opt.foldminlines = 2
augroup("rememberFolds", {}) -- keep folds on save https://stackoverflow.com/questions/37552913/vim-how-to-keep-folds-on-save
autocmd("BufWinLeave", {
	group = "rememberFolds",
	pattern = "?*",
	command = "silent! mkview"
})
autocmd("BufWinEnter", {
	group = "rememberFolds",
	pattern = "?*",
	command = "silent! loadview"
})

--------------------------------------------------------------------------------

-- Terminal Mode
augroup("Terminal", {})
autocmd("TermOpen", {
	group = "Terminal",
	pattern = "*",
	command = "startinsert",
})
autocmd("TermClose", {
	group = "Terminal",
	pattern = "*",
	command = "bd",
})

--------------------------------------------------------------------------------

-- Skeletons (Templates)
-- apply templates for any filetype named `.config/nvim/templates/skeletion.{ft}`
augroup("Templates", {})
local filetypeList = fn.system('ls "$HOME/.config/nvim/templates/skeleton."* | xargs basename | cut -d. -f2')
local ftWithSkeletons = split(filetypeList, "\n")
for _, ft in ipairs(ftWithSkeletons) do
	if ft == "" then break end
	local readCmd = "0r $HOME/.config/nvim/templates/skeleton." .. ft .. " | normal! G"
	autocmd("BufNewFile", {
		group = "Templates",
		pattern = "*." .. ft,
		command = readCmd,
	})
	-- BufReadPost + empty file as additional condition to also auto-insert
	-- skeletons when empty files were created by other apps
	autocmd("BufReadPost", {
		group = "Templates",
		pattern = "*." .. ft,
		callback = function()
			local curFile = fn.expand("%")
			local fileIsEmpty = fn.getfsize(curFile) < 2 -- 2 to account for linebreak
			if fileIsEmpty then
				cmd(readCmd)
			end
		end
	})
end
