local opt_local = vim.opt_local
local opt = vim.opt
local bo = vim.bo
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------
-- FILETYPES

-- make zsh files recognized as sh for bash-ls & treesitter
vim.filetype.add {
	extension = {
		zsh = "sh",
		sh = "sh", -- so .sh files with zsh-shebang still get sh filetype
	},
	filename = {
		[".zshrc"] = "sh",
		[".zshenv"] = "sh",
		[".ignore"] = "gitignore", -- fd ignore files
	},
}

--------------------------------------------------------------------------------

-- DIRECTORIES
-- move to custom location where they are synced independently from the dotfiles repo
opt.undodir:prepend(u.vimDataDir .. "undo//")
opt.viewdir = u.vimDataDir .. "view"
opt.shadafile = u.vimDataDir .. "main.shada"
opt.swapfile = false -- doesn't help and only creates useless files

--------------------------------------------------------------------------------
-- Undo
opt.undofile = true -- enables persistent undo history

-- extra undo-points (= more fine-grained undos)
-- WARN requires `remap = true`, since it otherwise prevents vim abbreviations
-- with those chars from working
local undopointChars = { ".", ",", ";", '"', ":", "'", "<Space>" }
for _, char in pairs(undopointChars) do
	keymap("i", char, char .. "<C-g>u", { desc = "extra undopoint for " .. char, remap = true })
end

--------------------------------------------------------------------------------

-- Set title so current file can be read from automation app via window title
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = '%{expand("%:p")}'

-- Motions & Editing
opt.startofline = true -- motions like "G" also move to the first char
opt.virtualedit = "block" -- visual-block mode can select beyond end of line
opt.mouse = "" -- disable mouse completely

-- Search
opt.ignorecase = true
opt.smartcase = true

-- when closing a bracket, briefly flash the matching one
opt.showmatch = true
opt.matchtime = 1 -- deci-seconds

-- Clipboard
opt.clipboard = "unnamedplus"

-- Spelling
opt.spell = false -- just using spellfile to quickly add words for ltex
opt.spellfile = u.linterConfigFolder .. "/spellfile-vim-ltex.add" -- has to be `.add`
opt.spelllang = "en_us" -- still relevant for `z=`

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNew" }, {
	callback = function()
		local specialBuffer = vim.bo.buftype ~= ""
		if specialBuffer then opt_local.spell = false end
	end,
})

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Workspace
opt.cursorline = true
opt.signcolumn = "yes:1"

-- Wrapping
opt.textwidth = 80 -- in some languages overridden by .editorconfig
opt.colorcolumn = { 81 } -- not relative to textwidth, as it is sometimes changed via .editorconfig
opt.wrapmargin = 3 -- extra space since using a scrollbar plugin
opt.wrap = false
opt.breakindent = false
opt.linebreak = true -- do not break up full words on wrap

-- Color Column: textwidth + guiding line for `gm`
-- BUG the "WinResized" autocmd event does not seem to work currently (nvim 0.9.1)
autocmd({ "VimEnter", "VimResized" }, {
	callback = function()
		if opt_local.wrap:get() then return end
		local gmColumn = math.floor(vim.api.nvim_win_get_width(0) / 2)
		local global = opt.colorcolumn:get()[1]
		opt.colorcolumn = { global, gmColumn }
	end,
})

-- status bar & cmdline
opt.cmdheight = 0
opt.history = 400 -- reduce noise for command history search
opt.shortmess:append("s") -- reduce info in :messages
opt.shortmess:append("S")
opt.shortmess:append("I")
opt.report = 9001 -- disable "x more/fewer lines" messages

-- Character groups
opt.iskeyword:append("-") -- don't treat "-" as word boundary, e.g., for kebab-case
opt.nrformats:append("unsigned") -- make <C-a>/<C-x> ignore negative numbers
opt.nrformats:remove { "bin", "hex" } -- remove ambiguity, since I don't use them anyway

-- Timeouts
opt.updatetime = 250 -- also affects current symbol highlight (treesitter-refactor) and current line lsp-hints
opt.timeoutlen = 666 -- also affects duration until which-key is shown

--------------------------------------------------------------------------------

-- Popups & Cmdline
opt.pumwidth = 15 -- min width
opt.pumheight = 12 -- max height

-- scrolling
opt.scrolloff = 13
opt.sidescrolloff = 13

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.smartindent = true

-- invisible chars
opt.list = true
opt.fillchars = { eob = " ", fold = " " }
opt.listchars = {
	nbsp = "󰚌",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "  ",
	lead = "·",
}

-- no list chars in special buffers
autocmd({ "BufNew", "BufReadPost" }, {
	callback = function()
		if bo.buftype ~= "" then opt_local.list = false end
	end,
})

-- Formatting `vim.opt.formatoptions:remove{"o"}` would not work, since it's
-- overwritten by the ftplugins having the `o` option. Therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
autocmd("FileType", {
	callback = function() opt_local.formatoptions:remove("o") end,
})

autocmd("BufReadPost", {
	callback = function()
		vim.defer_fn(function()
			opt_local.listchars = vim.opt.listchars:get() -- copy the global
			if bo.expandtab then
				opt_local.listchars:append { tab = "󰌒 " }
				opt_local.listchars:append { lead = " " }
			else
				opt_local.listchars:append { tab = "  " }
				opt_local.listchars:append { lead = "·" }
			end
		end, 5) -- delayed to ensure it runs after `:GuessIndent`
	end,
})

-- notify when coming back to a file that does not exist anymore
autocmd("FocusGained", {
	callback = function()
		local fileExists = vim.loop.fs_stat(vim.fn.expand("%")) ~= nil
		local specialBuffer = vim.bo.buftype ~= ""
		if not fileExists and not specialBuffer then
			u.notify("", "File does not exist anymore.", "warn")
		end
	end,
})

--------------------------------------------------------------------------------
