---MY VARIABLES-----------------------------------------------------------------
vim.g.localRepos = vim.env.HOME .. "/Developer"
vim.g.notesDir = vim.env.HOME .. "/Notes"
vim.g.iCloudSync = vim.env.HOME .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/nvim-data"

vim.g.useEmmyluaLsp = false

-- names need to match `lua/colorschemes/{name}.lua` & the name for `vim.cmd.colorscheme`
vim.g.lightColor = "dawnfox"
vim.g.darkColor = "tokyonight"

---GENERAL OPTIONS--------------------------------------------------------------
vim.g.mapleader = ","
vim.g.maplocalleader = "<Nop>"
vim.opt.clipboard = "unnamedplus"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true -- enables session-persistent undo history
vim.opt.undodir = vim.g.iCloudSync .. "/undo"

vim.opt.shadafile = vim.g.iCloudSync .. "/main.shada"
vim.opt.swapfile = false -- doesn't help and only creates useless files and notifications

vim.opt.spell = false
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spellfile.add" -- needs `.add` extension
vim.opt.spelllang = "en_us" -- even with spellcheck disabled, still relevant for `z=`
vim.opt.spelloptions = "camel"

vim.opt.splitright = true -- split right instead of left
vim.opt.splitbelow = true -- split down instead of up

vim.opt.iskeyword:append("-") -- treat `-` as word character, same as `_`

vim.opt.nrformats = { "unsigned" } -- treat all numbers as positive & `<C-x>` stops at 0
vim.opt.virtualedit = { "block" } -- in visual block mode, cursor can move beyond end of line

vim.opt.autowriteall = true

vim.opt.jumpoptions:append("stack") -- https://www.reddit.com/r/neovim/comments/16nead7/comment/k1e1nj5/?context=3
vim.opt.startofline = true -- motions like "G" also move to the first char
vim.opt.mousescroll = "ver:1,hor:3" -- more fine-grained scrolling with mouse

-- Formatting `vim.opt.formatoptions:remove("o")` would not work, since it's
-- overwritten by ftplugins having the `o` option (which many do).
-- Therefore needs to be set via autocommand.
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Remove `o` from `formatoptions`",
	callback = function()
		vim.opt_local.formatoptions:remove("o")
		vim.opt_local.formatoptions:remove("t")
	end,
})

---WRAP-------------------------------------------------------------------------
vim.opt.wrap = false -- off by default, enable when needed
vim.opt.linebreak = true -- wrap at full words
vim.opt.breakindent = true -- wrapped lines inherit indent from previous line
vim.opt.breakindentopt = "list:-1" -- wrap lists with correct indentation

vim.api.nvim_create_autocmd("Filetype", {
	desc = "User: set `showbreak` in regular buffers only",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype == "" then vim.opt_local.showbreak = "↳ " end
	end,
})

---APPEARANCE-------------------------------------------------------------------
vim.opt.cursorline = true
vim.opt.colorcolumn = "+1" -- = one more than textwidth
vim.opt.signcolumn = "yes:1"

vim.opt.sidescrolloff = 15
vim.opt.scrolloff = 13

vim.opt.winborder = "rounded"

vim.opt.pumheight = 12 -- max height of completion menu

---EDITORCONFIG-----------------------------------------------------------------
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
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.smartindent = true

---MESSAGES & CMDLINE-----------------------------------------------------------
vim.opt.report = 9001 -- disable most "x more/fewer lines" messages
vim.opt.shortmess:append("ISs") -- no intro message, disable search count
vim.opt.cmdheight = 0

---CONCEAL----------------------------------------------------------------------
vim.opt.conceallevel = 2 -- hide some chars in markdown and json
vim.opt.concealcursor = "n" -- do not display current line conceals in normal mode

---INVISIBLE CHARS--------------------------------------------------------------
vim.opt.list = true
vim.opt.listchars:append {
	nbsp = "󰚌", -- ␣
	precedes = "…",
	extends = "…",
	multispace = "·",
	trail = " ",
	tab = "  ", -- already handled by indentation plugin
	lead = " ",
	space = " ",
}
vim.opt.fillchars:append {
	eob = " ",
	msgsep = "═",
	lastline = "↓",
}

-- stylua: ignore
vim.opt.fillchars:append { horiz = "═", vert = "║", horizup = "╩", horizdown = "╦", vertleft = "╣", vertright = "╠", verthoriz = "╬" }
-- vim.opt.fillchars:append { horiz = "▄", vert = "█", horizup = "█", horizdown = "▄", vertleft = "█", vertright = "█", verthoriz = "█" }

---DIAGNOSTICS------------------------------------------------------------------
vim.diagnostic.config {
	severity_sort = true,
	jump = { float = true },
	signs = {
		text = { "󰅚 ", " ", "󰋽 ", " " }, -- Error, Warn, Info, Hint
	},
	virtual_text = {
		spacing = 2,
		severity = {
			min = vim.diagnostic.severity.WARN, -- leave out Info & Hint
		},
		format = function(diag)
			local msg = diag.message:gsub("%.$", "") -- remove trailing `.` from lua_ls
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
		focusable = true, -- allow entering float
		prefix = function(_, _, total) return (total > 1 and "• " or ""), "Comment" end,
		suffix = function(diag)
			local source = (diag.source or ""):gsub(" ?%.$", "")
			local code = diag.code and ": " .. diag.code or ""
			return " " .. source .. code, "Comment"
		end,
		format = function(diag) -- remove trailing `.`
			return diag.source == "lua_ls" and diag.message:gsub("%.$", "") or diag.message
		end,
		close_events = {
			"CursorMoved",
			"TextChanged", -- leave out "TextChangedI" to continue showing diagnostics while typing
			"BufHidden", -- fix window persisting on buffer switch (not `BufLeave` so float can be entered)
			"LspDetach", -- fix window persisting when restarting LSP
		},
	},
}

vim.api.nvim_create_autocmd("WinNew", {
	desc = "User: Use markdown highlighting in diagnostic floats",
	callback = function()
		vim.defer_fn(function()
			if not vim.b.lsp_floating_preview then return end -- no lsp float
			local bufnr = vim.api.nvim_win_get_buf(vim.b.lsp_floating_preview)
			if vim.bo[bufnr].filetype ~= "" then return end -- other type of lsp float
			vim.bo[bufnr].filetype = "markdown"
		end, 1)
	end,
})

--------------------------------------------------------------------------------
