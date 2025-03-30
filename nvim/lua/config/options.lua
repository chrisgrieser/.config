-- GENERAL

vim.opt.undofile = true -- enables persistent undo history
vim.opt.undolevels = 1337 -- too high results in increased buffer loading time
vim.opt.swapfile = false -- doesn't help and only creates useless files and notifications

vim.opt.spell = false
vim.opt.spellfile = vim.fs.normalize("~/.config/+ linter-configs/spellfile.add") -- needs `.add` ext
vim.opt.spelllang = "en_us" -- even with spellcheck disabled, still relevant for `z=`
vim.opt.spelloptions = "camel"

vim.opt.splitright = true -- split right instead of left
vim.opt.splitbelow = true -- split down instead of up

vim.opt.cursorline = true
vim.opt.colorcolumn = "+1" -- = one more than textwidth
vim.opt.signcolumn = "yes:2" -- too many potential signs for just `1`

vim.opt.wrap = false

vim.opt.shortmess:append("ISs") -- no intro message, disable search count
vim.opt.report = 9001 -- disable most "x more/fewer lines" messages

vim.opt.iskeyword:append("-") -- treat `-` as word character, same as `_`

-- treat all numbers as positive, ignoring dashes
-- this also makes `<C-x>` stop at `0`
vim.opt.nrformats = { "unsigned" }

vim.opt.autowriteall = true

vim.opt.jumpoptions:append("stack") -- https://www.reddit.com/r/neovim/comments/16nead7/comment/k1e1nj5/?context=3
vim.opt.startofline = true -- motions like "G" also move to the first char

vim.opt.timeoutlen = 666

-- Formatting `vim.opt.formatoptions:remove("o")` would not work, since it's
-- overwritten by ftplugins having the `o` option (which many do). Therefore
-- needs to be set via autocommand.
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Remove `o` from `formatoptions`",
	callback = function(ctx)
		if ctx.match ~= "markdown" then
			vim.opt_local.formatoptions:remove("o")
			vim.opt_local.formatoptions:remove("t")
		end
	end,
})

--------------------------------------------------------------------------------
-- APPEARANCE
vim.opt.sidescrolloff = 15
vim.opt.scrolloff = 12

vim.opt.winborder = "single"

-- max height of completion menu (even with completion plugin still relevant for native cmdline-popup)
vim.opt.pumheight = 12

--------------------------------------------------------------------------------
-- CLIPBOARD
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Highlighted Yank",
	callback = function() vim.highlight.on_yank { timeout = 1000 } end,
})

--------------------------------------------------------------------------------
-- EDITORCONFIG

-- By default, nvim automatically sets `textwidth` to follow the
-- `max_line_length` value of `editorconfig`. However, I prefer to keep have
-- different values for `textwidth` and `max_line_length`, so vim behavior like
-- `gww` or auto-breaking comment still follows `textwidth`, while using a
-- larger line length setting for formatters.
-- Setting those values independently is not possible normally, so we disable
-- the respective function in the `editorconfig` module instead as a workaround.
require("editorconfig").properties.max_line_length = nil
vim.opt.textwidth = 80

-- mostly set by `editorconfig`, therefore only fallback
vim.opt.expandtab = false
vim.opt.tabstop = 3 -- yes, I like my indentation 3 spaces wide
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
-- SEARCH & CMDLINE

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cmdheight = 0

--------------------------------------------------------------------------------
-- INVISIBLE CHARS

vim.opt.list = true
vim.opt.conceallevel = 2
vim.opt.listchars = {
	nbsp = "󰚌",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "│ ", -- mostly overridden by indent-blankline
	lead = " ",
	trail = " ",
}
vim.opt.fillchars:append {
	eob = " ",
	lastline = "↓",
	diff = "▄",
	-- thick window separators
	horiz = "▄",
	vert = "█",
	horizup = "█",
	horizdown = "█",
	vertleft = "█",
	vertright = "█",
	verthoriz = "█",
}
--------------------------------------------------------------------------------

-- FOLDING
vim.opt.foldenable = true
vim.opt.foldlevel = 99 -- do not auto-fold
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "0" -- 0 = disable
vim.opt.fillchars:append { fold = " " }

do
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "User: Set LSP folding if client supports it",
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client and client:supports_method("textDocument/foldingRange") then
				local win = vim.api.nvim_get_current_win()
				vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
			end
		end,
	})
end

--------------------------------------------------------------------------------
