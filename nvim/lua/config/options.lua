--------------------------------------------------------------------------------
-- GENERAL

vim.opt.undofile = true -- enables persistent undo history
vim.opt.swapfile = false -- doesn't help and only creates useless files and notifications

vim.opt.startofline = true -- motions like "G" also move to the first char
vim.opt.virtualedit = "block" -- visual-block mode can select beyond end of line

vim.opt.spell = false
vim.opt.spellfile = vim.g.linterConfigs .. "/spellfile.add" -- needs `.add` extension
vim.opt.spelllang = "en_us" -- even with spellcheck disabled, still relevant for `z=`

vim.opt.splitright = true -- split right instead of left
vim.opt.splitbelow = true -- split down instead of up

vim.opt.cursorline = true
vim.opt.signcolumn = "yes:1"

vim.opt.textwidth = 80 -- mostly set by .editorconfig, therefore only fallback
vim.opt.colorcolumn = "+1" -- one more than textwidth
vim.opt.wrap = false
vim.opt.breakindent = true -- indent wrapped lines

vim.opt.shortmess:append("ISs") -- no intro message, no search count
vim.opt.report = 9001 -- disable "x more/fewer lines" messages

vim.opt.iskeyword:append("-") -- treat `-` as word character, same as `_`
vim.opt.nrformats = {} -- remove octal and hex from <C-a>/<C-x>

vim.opt.autowriteall = true

vim.opt.pumwidth = 15 -- min width
vim.opt.pumheight = 12 -- max height

vim.opt.sidescrolloff = 12
vim.g.baseScrolloff = 12 -- so scrolloff-changing functions can use this
vim.opt.scrolloff = vim.g.baseScrolloff

-- mostly set by .editorconfig, therefore only fallback
vim.opt.expandtab = false
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3

vim.opt.shiftround = true
vim.opt.smartindent = true

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
	filename = {
		[".ignore"] = "gitignore", -- ignore files for fd/rg
	},
	extension = {
		jxa = "javascript", -- Apple's JXA
	},
}

--------------------------------------------------------------------------------
-- DIRECTORIES

-- move to custom location where they are synced independently from the dotfiles repo
vim.opt.undodir = vim.g.syncedData .. "/undo"
vim.opt.viewdir = vim.g.syncedData .. "/view"
vim.opt.shadafile = vim.g.syncedData .. "/main.shada"

-- automatically cleanup dirs to prevent bloating.
-- once a week, on first FocusLost, delete files older than 30/60 days.
vim.api.nvim_create_autocmd("FocusLost", {
	once = true,
	callback = function()
		if os.date("%a") ~= "Mon" then return end
		vim.system { "find", vim.opt.viewdir:get(), "-mtime", "+60d", "-delete" }
		vim.system { "find", vim.opt.undodir:get()[1], "-mtime", "+30d", "-delete" }
	end,
})

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
-- deferred, since sometimes slow
vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)

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
