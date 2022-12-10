require("utils")
--------------------------------------------------------------------------------

-- timeouts
opt.timeoutlen = 1200 -- for awaiting keystrokes when there is no `nowait`
opt.updatetime = 250 -- affects current symbol highlight (treesitter-refactor) and currentline lsp-hints

-- Search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true

-- Popups / Floating Windows
opt.pumheight = 15 -- max number of items in popup menu
opt.pumwidth = 10 -- min width popup menu
opt.winblend = 2 -- % transparency

-- Spelling
opt.spell = false
opt.spelllang = "en_us"

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.smartindent = true
opt.list = true
opt.virtualedit = "block" -- select whitespace for proper rectangles in visual block mode

-- invisible chars
opt.listchars = {
	tab = "  ",
	multispace = "·",
	nbsp = "ﮊ",
	lead = "·",
	leadmultispace = "·",
	trail = "·",
	precedes = "",
}
opt.fillchars = {
	eob = " ", -- no ~ for the eof, no dots for folds
	fold = " ", -- no dots for folds
}

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Window Managers/espanso: set title
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = "%{expand(\"%:p\")} [%{mode()}]"

-- Editor
opt.cursorline = true
opt.scrolloff = 12
opt.sidescrolloff = 20
opt.textwidth = 80
opt.wrap = false
opt.colorcolumn = {"+1", "+20"} -- relative to textwidth
opt.signcolumn = "yes:1" -- = gutter
opt.backspace = {"start", "eol"} -- restrict insert mode backspace behavior

-- Formatting vim.opt.formatoptions:remove("o") would not work, since it's
-- overwritten by the ftplugins having the o option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
augroup("formatopts", {})
autocmd("FileType", {
	group = "formatopts",
	callback = function()
		if not (bo.filetype == "markdown") then -- not for markdown, for autolist hack (see markdown.lua)
			bo.formatoptions = bo.formatoptions:gsub("o", "")
		end
	end
})

-- Remember Cursor Position
augroup("rememberCursorPosition", {})
autocmd("BufReadPost", {
	group = "rememberCursorPosition",
	callback = function()
		local jumpcmd
		if bo.filetype == "commit" then
			return
		elseif bo.filetype == "log" or bo.filetype == "" then -- for log files jump to the bottom
			jumpcmd = "G"
		elseif fn.line [['"]] >= fn.line [[$]] then -- in case file has been shortened outside of vim
			-- selene: allow(if_same_then_else)
			jumpcmd = "G"
		elseif fn.line [['"]] >= 1 then -- check file has been entered already
			jumpcmd = [['"]]
		end
		cmd("keepjumps normal! " .. jumpcmd)
	end,
})

-- clipboard & yanking
opt.clipboard = "unnamedplus"
augroup("highlightedYank", {})
autocmd("TextYankPost", {
	group = "highlightedYank",
	callback = function() vim.highlight.on_yank {timeout = 2000} end
})

-- Character groups
opt.iskeyword:append("-") -- don't treat "-" as word boundary, useful e.g. for kebab-case-variables
opt.nrformats = "alpha" -- <C-a> and <C-x> also work on letters

--------------------------------------------------------------------------------

-- UNDO & SWAP
opt.undofile = true -- enable persistent undo history

-- save swap, undo, view, and shada files in cloud for syncing with other devices
opt.directory:prepend(vimDataDir .. "swap//")
opt.undodir:prepend(vimDataDir .. "undo//")
opt.viewdir = vimDataDir .. "view"
opt.shadafile = vimDataDir .. "main.shada"

--------------------------------------------------------------------------------

-- FILES & SAVING
opt.autochdir = true -- always current directory
opt.confirm = true -- ask instead of aborting

augroup("autosave", {})
autocmd({"BufWinLeave", "QuitPre", "FocusLost", "InsertLeave"}, {
	group = "autosave",
	pattern = "?*",
	callback = function()
		-- safety net to not save file in wrong folder when autochdir is not being reliable
		local curFile = fn.expand("%:p")
		cmd.update(curFile)
	end
})

augroup("Mini-Lint", {})
autocmd("BufWritePre", {
	group = "Mini-Lint",
	callback = function()
		local save_view = fn.winsaveview() -- save cursor position
		if bo.filetype ~= "markdown" then -- to preserve spaces from the two-space-rule, and trailing spaces on sentences
			cmd [[%s/\s\+$//e]] -- trim trailing whitespaces
		end
		cmd [[silent! %s#\($\n\s*\)\+\%$##]] -- trim extra blanks at eof https://stackoverflow.com/a/7496112
		fn.winrestview(save_view)
	end
})

--------------------------------------------------------------------------------

-- status bar & cmdline
opt.history = 250 -- reduce noise for command history search
opt.cmdheight = 0

--------------------------------------------------------------------------------
-- FOLDING

-- use treesitter folding
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldmethod = "expr"
-- opt.foldmethod = "indent"

-- fold settings
opt.foldenable = false -- do not fold at start
opt.foldminlines = 2
opt.foldnestmax = 2
opt.foldlevel = 99

-- keep folds on save https://stackoverflow.com/questions/37552913/vim-how-to-keep-folds-on-save
augroup("rememberFolds", {})
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

-- Skeletons (Templates)
-- apply templates for any filetype named `.config/nvim/templates/skeletion.{ft}`
augroup("Templates", {})
local skeletionPath = fn.stdpath("config") .. "/templates"
local filetypeList = fn.system([[ls "]] .. skeletionPath .. [[/skeleton."* | xargs basename | cut -d. -f2]])
local ftWithSkeletons = split(filetypeList, "\n")
for _, ft in pairs(ftWithSkeletons) do
	if ft == "" then break end
	local readCmd = "keepalt 0r $HOME/.config/nvim/templates/skeleton." .. ft .. " | normal! G"

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
			if fileIsEmpty then cmd(readCmd) end
		end
	})
end
