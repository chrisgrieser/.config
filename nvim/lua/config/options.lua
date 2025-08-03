--------------------------------------------------------------------------------
-- GLOBALS

vim.g.mapleader = ","
vim.g.maplocalleader = "<Nop>"

vim.g.localRepos = vim.fs.normalize("~/Developer")
vim.g.icloudSync =
	vim.fs.normalize("~/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/nvim-data")

vim.g.use_emmylua = false

--------------------------------------------------------------------------------
-- GENERAL
vim.opt.clipboard = "unnamedplus"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true -- enables session-persistent undo history
vim.opt.undodir = vim.g.icloudSync .. "/undo"

vim.opt.shadafile = vim.g.icloudSync .. "/main.shada"
vim.opt.swapfile = false -- doesn't help and only creates useless files and notifications

vim.opt.spell = false
vim.opt.spellfile = vim.fs.normalize("~/.config/+ linter-configs/spellfile.add") -- needs `.add`
vim.opt.spelllang = "en_us" -- even with spellcheck disabled, still relevant for `z=`
vim.opt.spelloptions = "camel"

vim.opt.splitright = true -- split right instead of left
vim.opt.splitbelow = true -- split down instead of up

vim.opt.iskeyword:append("-") -- treat `-` as word character, same as `_`

-- treat all numbers as positive (ignoring dashes), also makes `<C-x>` stop at `0`
vim.opt.nrformats = { "unsigned" }
vim.opt.virtualedit = { "block" } -- in visual block mode, cursor can move beyond end of line

vim.opt.autowriteall = true

vim.opt.jumpoptions:append("stack") -- https://www.reddit.com/r/neovim/comments/16nead7/comment/k1e1nj5/?context=3
vim.opt.startofline = true -- motions like "G" also move to the first char

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
-- WRAP
vim.opt.wrap = false -- off by default
vim.opt.breakindent = true -- wrapped lines inherit indent from previous line
vim.opt.cursorlineopt = "screenline" -- highlight visual line, not logical line

vim.api.nvim_create_autocmd("Filetype", {
	desc = "User: set `showbreak` in regular buffers only",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype == "" then vim.opt_local.showbreak = "↳ " end
	end,
})

--------------------------------------------------------------------------------
-- APPEARANCE
vim.opt.cursorline = true
vim.opt.colorcolumn = "+1" -- = one more than textwidth
vim.opt.signcolumn = "yes:1"

vim.opt.sidescrolloff = 15
vim.opt.scrolloff = 13

vim.opt.winborder = "single"

vim.opt.pumheight = 12 -- max height of completion menu

--------------------------------------------------------------------------------
-- EDITORCONFIG

-- By default, nvim automatically sets `textwidth` to follow the
-- `max_line_length` value of `editorconfig`. However, I prefer to keep have
-- different values for `textwidth` and `max_line_length`, so vim behavior like
-- `gww` or auto-breaking comment still follows `textwidth`, while using a
-- larger line length setting for formatters.
-- Setting those values independently is normally not possible, so we disable
-- the respective function in the `editorconfig` module instead as a workaround.
require("editorconfig").properties.max_line_length = nil
vim.opt.textwidth = 80

vim.opt.expandtab = false -- mostly set by `editorconfig`, therefore only fallback
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.shiftround = true
vim.opt.smartindent = true

--------------------------------------------------------------------------------
-- AUTOMATION

if vim.g.neovide then
	-- read: access cwd via window title
	vim.opt.title = true
	vim.opt.titlelen = 0 -- 0 = do not shorten title
	vim.opt.titlestring = "%{getcwd()}"

	-- write: issue commands via nvim server
	pcall(os.remove, "/tmp/nvim_server.pipe") -- after a crash, server is still there and needs to be removed
	vim.fn.serverstart("/tmp/nvim_server.pipe")
end

--------------------------------------------------------------------------------
-- MESSAGES & CMDLINE

vim.opt.report = 9001 -- disable most "x more/fewer lines" messages
vim.opt.shortmess:append("ISs") -- no intro message, disable search count
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
	trail = " ",
	tab = "  ",
	lead = " ",
	space = " ",
}
vim.opt.fillchars:append {
	eob = " ",
	msgsep = "═",
	lastline = "↓",

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
-- DIAGNOSTICS

vim.diagnostic.config {
	severity_sort = true,
	jump = {
		float = true,
	},
	signs = {
		text = { "󰅚 ", " ", "󰋽 ", "󰌶 " }, -- Error, Warn, Info, Hint
	},
	virtual_text = {
		spacing = 2,
		severity = {
			min = vim.diagnostic.severity.WARN, -- leave out Info & Hint
		},
		format = function(diag)
			local msg = diag.message:gsub("%.$", "") -- lua_ls adds trailing `.`
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
