-- GENERAL

vim.opt.undofile = true -- enables persistent undo history
vim.opt.swapfile = false -- doesn't help and only creates useless files and notifications

vim.opt.startofline = true -- motions like "G" also move to the first char
vim.opt.virtualedit = "block" -- visual-block mode can select beyond end of line

vim.opt.spell = false
vim.opt.spellfile = vim.fs.normalize("~/.config/+ linter-configs/spellfile.add") -- needs `.add` ext
vim.opt.spelllang = "en_us" -- even with spellcheck disabled, still relevant for `z=`

vim.opt.splitright = true -- split right instead of left
vim.opt.splitbelow = true -- split down instead of up

vim.opt.cursorline = true
vim.opt.colorcolumn = "+1" -- one more than textwidth
vim.opt.signcolumn = "yes:1"

vim.opt.wrap = false
vim.opt.breakindent = true -- indent wrapped lines

vim.opt.shortmess:append("ISs") -- no intro message, no search count
vim.opt.report = 9001 -- disable "x more/fewer lines" messages

vim.opt.iskeyword:append("-") -- treat `-` as word character, same as `_`
vim.opt.nrformats = {} -- remove octal and hex from <C-a>/<C-x>

vim.opt.autowriteall = true

vim.opt.pumwidth = 15 -- min width
vim.opt.pumheight = 12 -- max height

vim.opt.jumpoptions = { "stack" } -- https://www.reddit.com/r/neovim/comments/16nead7/comment/k1e1nj5/?context=3

vim.opt.sidescrolloff = 12
vim.g.baseScrolloff = 12 -- so scrolloff-changing functions can use this
vim.opt.scrolloff = vim.g.baseScrolloff

-- Formatting `vim.opt.formatoptions:remove("o")` would not work, since it's
-- overwritten by ftplugins having the `o` option (which many do). Therefore
-- needs to be set via autocommand.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(ctx)
		if ctx.match ~= "markdown" then
			vim.opt_local.formatoptions:remove("o")
			vim.opt_local.formatoptions:remove("t")
		end
	end,
})

--------------------------------------------------------------------------------
-- EDITORCONFIG

-- By default, vim automatically sets `textwidth` to follow the
-- `max_line_length` value of `editorconfig`. However, I prefer to keep have
-- different values for `textwidth` and `max_line_length`, so vim behavior like
-- `gww` or auto-breaking comment still follows `textwidth`, while using a wider
-- line length setting for formatters. Setting those values independently is not
-- possible normally, so we disable the respective in the `editorconfig` module
-- instead as a workaround.
require("editorconfig").properties.max_line_length = nil
vim.opt.textwidth = 80

-- mostly set by `editorconfig`, therefore only fallback
vim.opt.expandtab = false
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3

vim.opt.shiftround = true
vim.opt.smartindent = true

--------------------------------------------------------------------------------
-- FILETYPES

vim.filetype.add {
	filename = {
		[".ignore"] = "gitignore", -- ignore files for fd/rg
	},
}

--------------------------------------------------------------------------------
-- DIRECTORIES

-- move to custom location where they are synced independently from the dotfiles
local dir = vim.fs.normalize("~/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/vim-data")
vim.opt.undodir = dir .. "/undo"
vim.opt.viewdir = dir .. "/view"
vim.opt.shadafile = dir .. "/main.shada"

--------------------------------------------------------------------------------
-- AUTOMATION (external control)

-- enable reading cwd via window title
vim.opt.title = true
vim.opt.titlelen = 0 -- 0 = do not shorten title
vim.opt.titlestring = "%{getcwd()}"

-- issue commands via nvim server
if vim.g.neovide then
	pcall(os.remove, "/tmp/nvim_server.pipe") -- in case of crash, the server is still there
	vim.fn.serverstart("/tmp/nvim_server.pipe")
end

--------------------------------------------------------------------------------
-- CLIPBOARD
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.highlight.on_yank { timeout = 1000 } end,
})

--------------------------------------------------------------------------------
-- SEARCH & CMDLINE

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cmdheight = 0 -- also auto-set by noice

--------------------------------------------------------------------------------
-- INVISIBLE CHARS

vim.opt.list = true
vim.opt.conceallevel = 3
vim.opt.fillchars:append {
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
vim.opt.listchars = {
	nbsp = "󰚌",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "│ ", -- mostly overridden by indent-blankline
	lead = " ",
	trail = " ",
}
