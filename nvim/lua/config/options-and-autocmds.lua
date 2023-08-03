local opt_local = vim.opt_local
local opt = vim.opt
local bo = vim.bo
local fn = vim.fn
local cmd = vim.cmd
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.keymap.set
local expand = vim.fn.expand
local u = require("config.utils")
local api = vim.api

--------------------------------------------------------------------------------
-- REMOTE CONTROL / AUTOMATION

-- nvim server (RPC) https://neovim.io/doc/user/remote.html

-- avoid duplicate server when opening nvim in the terminal as well
if vim.fn.has("gui_running") == 1 then
	local removed = pcall(os.remove, "/tmp/nvim_server.pipe") -- FIX server sometimes not properly shut down
	local delay = removed and 500 or 0
	vim.defer_fn(function() vim.fn.serverstart("/tmp/nvim_server.pipe") end, delay)
end

-- Set title so external apps like window managers can read the current file path
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = '%{expand("%:p")}'

--------------------------------------------------------------------------------

-- DIRECTORIES
-- move to custom location where they are synced independently from the dotfiles repo
opt.directory:prepend(u.vimDataDir .. "swap//")
opt.undodir:prepend(u.vimDataDir .. "undo//")
opt.viewdir = u.vimDataDir .. "view"
opt.shadafile = u.vimDataDir .. "main.shada"

--------------------------------------------------------------------------------
-- Undo
opt.undofile = true -- enable persistent undo history

-- extra undopoints (= more fine-grained undos)
-- WARN requires `remap = true`, since it otherwise prevents vim abbreviations
-- with those chars from working
local undopointChars = { ".", ",", ";", '"', ":", "<Space>" }
for _, char in pairs(undopointChars) do
	keymap("i", char, char .. "<C-g>u", { desc = "extra undopoint for " .. char, remap = true })
end

--------------------------------------------------------------------------------

-- Motions & Editing
opt.startofline = true -- motions like "G" also move to the first char
opt.virtualedit = "block" -- visual-block mode can select more
opt.mouse = "" -- disable mouse completely

-- Search
opt.ignorecase = true
opt.smartcase = true

-- when closing a bracket, briefly flash the matching one
opt.showmatch = true
opt.matchtime = 1 -- deci-seconds (higher amount feels laggy)

-- Clipboard
opt.clipboard = "unnamedplus"

-- Spelling
opt.spell = false -- off, since using vale & ltex for the lsp-integration
opt.spelllang = "en_us" -- still used for `z=` and `1z=`

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Workspace
opt.cursorline = true
opt.signcolumn = "yes:1"

-- Wrapping
opt.textwidth = 80
opt.wrapmargin = 3 -- extra space since using a scrollbar plugin
opt.wrap = false
opt.breakindent = false
opt.linebreak = true -- do not break up full words on wrap

-- Color Column: textwidth + guiding line for `gm`
autocmd({ "VimEnter", "VimResized" }, { -- the "WinResized" autocmd event does not seem to work currently
	callback = function()
		if opt_local.wrap:get() then return end
		local gmColumn = math.floor(vim.api.nvim_win_get_width(0) / 2)
		opt.colorcolumn = { "+1", gmColumn }
	end,
})

-- status bar & cmdline
opt.cmdheight = 0
opt.history = 400 -- reduce noise for command history search
opt.shortmess:append("s") -- reduce info in :messages
opt.shortmess:append("S") -- reduce info in :messages
opt.shortmess:append("A") -- no swap file alerts
opt.report = 9999 -- disable "x more/fewer lines" messages

-- Character groups
opt.iskeyword:append("-") -- don't treat "-" as word boundary, e.g. for kebab-case
opt.nrformats:append("unsigned") -- make <C-a>/<C-x> ignore negative numbers
opt.nrformats:remove { "bin", "hex" } -- remove ambiguity, since I don't use them anyway

-- Timeouts
opt.updatetime = 250 -- also affects current symbol highlight (treesitter-refactor) and currentline lsp-hints
opt.timeoutlen = 666 -- also affects duration until which-key is shown

--------------------------------------------------------------------------------

-- Popups & Cmdline
opt.pumheight = 15

autocmd({ "CmdlineLeave", "VimEnter" }, {
	-- min width popup menu
	callback = function() opt.pumwidth = 15 end,
})

-- do not obfuscate the buffer when searching
autocmd("CmdlineEnter", {
	callback = function()
		if not fn.getcmdtype():find("[/?]") then return end
		opt.pumwidth = 8
	end,
})

--------------------------------------------------------------------------------

-- SCROLLING
opt.scrolloff = 13
opt.sidescrolloff = 13

-- FIX scrolloff at EoF
-- https://github.com/Aasim-A/scrollEOF.nvim/blob/master/lua/scrollEOF.lua#L11
autocmd("CursorMoved", {
	callback = function()
		if bo.filetype == "DressingSelect" then return end

		local win_height = vim.api.nvim_win_get_height(0)
		local win_view = fn.winsaveview()
		local scrolloff = math.min(opt_local.scrolloff:get(), math.floor(win_height / 2))
		local scrolloff_line_count = win_height - (fn.line("w$") - win_view.topline + 1)
		local distance_to_last_line = fn.line("$") - win_view.lnum
		if
			distance_to_last_line < scrolloff
			and scrolloff_line_count + distance_to_last_line < scrolloff
		then
			win_view.topline = win_view.topline + scrolloff - (scrolloff_line_count + distance_to_last_line)
			fn.winrestview(win_view)
		end
	end,
})

--------------------------------------------------------------------------------

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.smartindent = true

-- invisible chars
opt.list = true
opt.fillchars = {
	eob = " ",
	fold = " ",
}
opt.listchars = {
	nbsp = "󰚌",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "  ",
	lead = "·",
}

autocmd("BufReadPost", {
	callback = function()
		-- run delayed, to ensure it runs after `:GuessIndent`
		vim.defer_fn(function()
			opt_local.listchars = vim.opt_global.listchars:get() -- copy the global
			if bo.expandtab then
				opt_local.listchars:append { tab = "↹ " }
				opt_local.listchars:append { lead = " " }
			else
				opt_local.listchars:append { tab = "  " }
				opt_local.listchars:append { lead = "·" }
			end
		end, 5)
	end,
})

--------------------------------------------------------------------------------
-- AUTO-SAVING

-- save on leaving file
opt.autowrite = true
opt.autowriteall = true
autocmd({ "BufLeave", "BufDelete", "FocusLost" }, {
	pattern = "?*",
	callback = function()
		local filepath = expand("%:p")
		if
			filepath ~= ""
			and (bo.buftype == "" or bo.buftype == "acwrite")
			and bo.filetype ~= "gitcommit"
			and opt.write:get()
			and not bo.readonly
		then
			cmd("silent noautocmd update " .. filepath)
		end
	end,
})

-- save on changes
autocmd({ "InsertLeave", "TextChanged" }, {
	pattern = "?*",
	callback = function()
		local debounceDelaySec = 4 -- save at most every x seconds

		-- for hot-reloading css
		local smallerThanRegularWin = (vim.opt.columns:get() < 65 or vim.opt.lines:get() < 20)
		if bo.filetype == "css" and smallerThanRegularWin then debounceDelaySec = 1.5 end

		local bufNo = api.nvim_get_current_buf()
		local filepath = expand("%:p")

		if
			not vim.b["savingQueued"]
			and fn.reg_executing() == ""
			and filepath ~= ""
			and (bo.buftype == "" or bo.buftype == "acwrite")
			and bo.filetype ~= "gitcommit"
			and opt.write:get()
			and not bo.readonly
		then
			api.nvim_buf_set_var(bufNo, "savingQueued", true)
			vim.defer_fn(function()
				local closedInMeantime = not api.nvim_buf_is_valid(bufNo)
				local bufferChangedInMeantime = api.nvim_get_current_buf() ~= bufNo
				local isInCmdline = vim.fn.getcmdtype():find("[/?]") ~= nil
				if closedInMeantime or bufferChangedInMeantime or isInCmdline then return end

				cmd("silent noautocmd update " .. filepath)
				api.nvim_buf_set_var(bufNo, "savingQueued", false)
			end, 1000 * debounceDelaySec)
		end
	end,
})

--------------------------------------------------------------------------------

-- Formatting `vim.opt.formatoptions:remove{"o"}` would not work, since it's
-- overwritten by the ftplugins having the `o` option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
autocmd("FileType", {
	callback = function() opt_local.formatoptions:remove("o") end,
})

--------------------------------------------------------------------------------

-- Add missing buffer names, e.g. for status bar
autocmd("FileType", {
	pattern = { "Glance", "lazy", "mason" },
	callback = function()
		local name = vim.fn.expand("<amatch>")
		name = name:sub(1, 1):upper() .. name:sub(2) -- capitalize
		vim.api.nvim_buf_set_name(0, name)
	end,
})
