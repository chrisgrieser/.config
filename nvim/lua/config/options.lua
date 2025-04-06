--------------------------------------------------------------------------------
-- GLOBALS

vim.g.mapleader = ","
vim.g.maplocalleader = "<Nop>"

vim.g.localRepos = vim.fs.normalize("~/Developer")
vim.g.icloudSync =
	vim.fs.normalize("~/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/vim-data")

--------------------------------------------------------------------------------
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
vim.opt.cursorline = true
vim.opt.colorcolumn = "+1" -- = one more than textwidth
vim.opt.signcolumn = "yes:2" -- too many potential signs for just `1`

vim.opt.sidescrolloff = 15
vim.opt.scrolloff = 12

vim.opt.winborder = "single"

-- max height of completion menu (even with completion plugin still relevant for native cmdline-popup)
vim.opt.pumheight = 12

--------------------------------------------------------------------------------

-- SEARCH
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

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
-- DIRECTORIES

-- move to custom location where they are synced independently from the dotfiles
vim.opt.undodir = vim.g.icloudSync .. "/undo"
vim.opt.shadafile = vim.g.icloudSync .. "/main.shada"
vim.opt.viewdir = vim.g.icloudSync .. "/views"

--------------------------------------------------------------------------------
-- AUTOMATION

-- read: access cwd via window title
vim.opt.title = true
vim.opt.titlelen = 0 -- 0 = do not shorten title
vim.opt.titlestring = "%{getcwd()}"

-- write: issue commands via nvim server
if vim.g.neovide then
	pcall(os.remove, "/tmp/nvim_server.pipe") -- b/c after a crash, the server is still there
	vim.fn.serverstart("/tmp/nvim_server.pipe")
end

--------------------------------------------------------------------------------
-- MESSAGES & CMDLINE

vim.opt.report = 9001 -- disable most "x more/fewer lines" messages
vim.opt.shortmess:append("ISs") -- no intro message, disable search count
vim.opt.cmdheight = 0
vim.opt.messagesopt = { "hit-enter", "history:1000" }

--------------------------------------------------------------------------------
-- INVISIBLE CHARS

vim.opt.list = true
vim.opt.conceallevel = 2
vim.opt.listchars = {
	nbsp = "󰚌",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "│ ", -- usually overridden by `snacks.indent`
	lead = " ",
	trail = " ",
}
vim.opt.fillchars:append {
	eob = " ",
	msgsep = "═",
	lastline = "↓",
	diff = "▄",
	fold = " ", -- overwritten by nvim-origami

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
vim.opt.foldlevel = 99 -- do not auto-fold
vim.opt.foldlevelstart = 99
vim.opt.foldtext = "" -- empty string keeps text (overwritten by nvim-origami)

-- fold with LSP/Treesitter
do
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "User: Set LSP folding if client supports it",
		callback = function(ctx)
			local client = assert(vim.lsp.get_client_by_id(ctx.data.client_id))
			if client:supports_method("textDocument/foldingRange") then
				local win = vim.api.nvim_get_current_win()
				vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
			end
		end,
	})
end

--------------------------------------------------------------------------------
-- DIAGNOSTICS

vim.diagnostic.config {
	jump = {
		float = true,
	},
	signs = {
		text = { "", "▲", "●", "" }, -- Error, Warn, Info, Hint
	},
	virtual_text = {
		spacing = 2,
		severity = {
			min = vim.diagnostic.severity.WARN, -- leave out Info & Hint
		},
		format = function(diag)
			local msg = diag.message:gsub("%.$", "")
			return msg
		end,
		suffix = function(diag)
			if not diag then return "" end
			local codeOrSource = (tostring(diag.code or diag.source or ""))
			if codeOrSource == "" then return "" end
			return (" [%s]"):format(codeOrSource:gsub("%.$", ""))
		end,
	},
	float = {
		max_width = 70,
		header = "",
		prefix = function(_, _, total) return (total > 1 and "• " or ""), "Comment" end,
		suffix = function(diag)
			local source = (diag.source or ""):gsub(" ?%.$", "")
			local code = diag.code and ": " .. diag.code or ""
			return " " .. source .. code, "Comment"
		end,
		format = function(diag)
			local msg = diag.message:gsub("%.$", "")
			return msg
		end,
	},
}
