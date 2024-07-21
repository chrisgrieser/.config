local opt = vim.opt

--------------------------------------------------------------------------------
-- GENERAL

opt.undofile = true -- enables persistent undo history

opt.startofline = true -- motions like "G" also move to the first char
opt.virtualedit = "block" -- visual-block mode can select beyond end of line

opt.showmatch = true -- when closing a bracket, briefly flash the matching one
opt.matchtime = 1 -- duration of that flashing n deci-seconds

opt.spell = false
opt.spellfile = vim.g.linterConfigs .. "/spellfile.add" -- needs `.add` extension
opt.spelllang = "en_us" -- even with spellcheck disabled, still relevant for `z=`

opt.splitright = true -- split right instead of left
opt.splitbelow = true -- split down instead of up

opt.cursorline = true
opt.signcolumn = "yes:1"

opt.textwidth = 80 -- mostly set by .editorconfig, therefore only fallback
opt.colorcolumn = "+1" -- one more than textwidth
opt.wrap = false
opt.breakindent = true -- indent wrapped lines

opt.shortmess:append("I") -- no intro message
opt.report = 9001 -- disable "x more/fewer lines" messages

opt.iskeyword:append("-") -- treat `-` as word character, same as `_`
opt.nrformats = {} -- remove octal and hex from <C-a>/<C-x>

opt.autowriteall = true

opt.pumwidth = 15 -- min width
opt.pumheight = 12 -- max height

opt.sidescrolloff = 12
vim.g.baseScrolloff = 12 -- so scrolloff-changing functions can use this
opt.scrolloff = vim.g.baseScrolloff

-- mostly set by .editorconfig, therefore only fallback
opt.expandtab = false
opt.tabstop = 3
opt.shiftwidth = 3

opt.shiftround = true
opt.smartindent = true

-- Formatting `vim.opt.formatoptions:remove("o")` would not work, since it's overwritten by ftplugins having the `o` option (which many do). Therefore needs to be set via autocommand.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(ctx)
		if ctx.match ~= "markdown" then
			vim.opt_local.formatoptions:remove("o")
			vim.opt_local.formatoptions:remove("t")
		end
	end,
})

--------------------------------------------------------------------------------
-- FILETYPES

vim.filetype.add {
	-- ignore files for fd/rg
	filename = { [".ignore"] = "gitignore" },
}

--------------------------------------------------------------------------------
-- DIRECTORIES

-- move to custom location where they are synced independently from the dotfiles repo
opt.undodir = vim.g.syncedData .. "/undo"
opt.viewdir = vim.g.syncedData .. "/view"
opt.shadafile = vim.g.syncedData .. "/main.shada"
opt.swapfile = false -- doesn't help and only creates useless files and notifications

-- automatically cleanup dirs to prevent bloating.
-- once a week, on first FocusLost, delete files older than 30/60 days.
vim.api.nvim_create_autocmd("FocusLost", {
	once = true,
	callback = function()
		if os.date("%a") ~= "Mon" then return end
		vim.system { "find", opt.viewdir:get(), "-mtime", "+60d", "-delete" }
		vim.system { "find", opt.undodir:get()[1], "-mtime", "+30d", "-delete" }
	end,
})

--------------------------------------------------------------------------------
-- AUTOMATION (external control)

-- enable reading cwd via window title
opt.title = true
opt.titlelen = 0 -- 0 = do not shorten title
opt.titlestring = "%{getcwd()}"

-- issue commands via nvim server
if vim.g.neovide then
	pcall(os.remove, "/tmp/nvim_server.pipe") -- in case of crash, the server is still there
	vim.fn.serverstart("/tmp/nvim_server.pipe")
end

--------------------------------------------------------------------------------
-- CLIPBOARD
opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.highlight.on_yank { timeout = 1000 } end,
})

--------------------------------------------------------------------------------
-- SEARCH & CMDLINE

opt.ignorecase = true
opt.smartcase = true
opt.cmdheight = 0 -- also auto-set by noice
opt.history = 400 -- reduce noise for command history search

--------------------------------------------------------------------------------
-- INVISIBLE CHARS

opt.list = true
opt.conceallevel = 3

opt.fillchars:append {
	eob = " ",
	fold = " ",
	-- thick window separators
	horiz = "▄",
	vert = "█",
	horizup = "█",
	horizdown = "█",
	vertleft = "█",
	vertright = "█",
	verthoriz = "█",
}
opt.listchars = {
	nbsp = "󰚌",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "│ ", -- mostly overridden by indent-blankline
	lead = " ",
	trail = " ",
}

