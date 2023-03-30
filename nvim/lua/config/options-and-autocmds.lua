require("config.utils")
local opt_local = vim.opt_local
local opt = vim.opt
--------------------------------------------------------------------------------

-- DIRECTORIES
opt.directory:prepend(VimDataDir .. "swap//")
opt.undodir:prepend(VimDataDir .. "undo//")
vim.opt.viewdir = VimDataDir .. "view"
vim.opt.shadafile = VimDataDir .. "main.shada"

--------------------------------------------------------------------------------
-- Undo
opt.undofile = true -- enable persistent undo history
opt.undolevels = 500 -- less undos saved for quicker loading of undo history

-- extra undopoints (= more fine-grained undos)
-- INFO extra undo points prevent vim abbreviations w/ those characters from
-- working, so <space> and ":" should not be added here
local undopointChars = { ".", ",", ";", '"' }
for _, char in pairs(undopointChars) do
	Keymap("i", char, char .. "<C-g>u", { desc = "extra undopoint for " .. char })
end

--------------------------------------------------------------------------------

-- Search
opt.smartcase = true
opt.ignorecase = true

-- Briefly flash when closing a bracket
opt.showmatch = true
opt.matchtime = 1 -- deci-seconds (higher amount feels laggy)

-- Clipboard
opt.clipboard = "unnamedplus"

-- Quickfix / Locaton List
opt.grepprg = "rg --vimgrep" -- use rg for :grep

-- Popups / Floating Windows
opt.pumheight = 15 -- max number of items in popup menu
opt.pumwidth = 15 -- min width popup menu

-- Spelling
opt.spell = false -- off, since using vale+null-ls for the lsp-integration
opt.spelllang = "en_us" -- still used for `z=` and `1z=`

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Set title so external apps can read the current file path
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = '%{expand("%:p")}'

-- Workspace
opt.cursorline = true
opt.signcolumn = "yes:1" -- = gutter

-- Wrapping
opt.textwidth = 80
opt.wrap = false
opt.breakindent = false
opt.linebreak = true -- do not break up full words on wrap

-- Color Column: textwidth + guiding line for `gm`
Autocmd({ "VimEnter", "VimResized" }, {
	-- the "WinResized" autocmd event does not seem to work currently
	callback = function()
		if opt_local.wrap:get() then return end
		local gmColumn = math.floor(Fn.winwidth("%") / 2) ---@diagnostic disable-line: param-type-mismatch
		opt.colorcolumn = { "+1", gmColumn }
	end,
})

-- status bar & cmdline
opt.history = 300 -- reduce noise for command history search
opt.cmdheight = 0

-- Character groups
opt.iskeyword:append("-") -- don't treat "-" as word boundary, e.g. for kebab-case

opt.nrformats:append("unsigned") -- make <C-a>/<C-x> ignore negative numbers
opt.nrformats:remove { "bin", "hex" } -- remove ambiguity, since I don't use them anyway

-- Timeouts
opt.updatetime = 250 -- also affects current symbol highlight (treesitter-refactor) and currentline lsp-hints
opt.timeoutlen = 600 -- also affects duration until which-key is shown

--------------------------------------------------------------------------------
-- PATH (for `gf`)

-- pwd is set via projects.nvim
-- add pwd
Autocmd("DirChanged", {
	callback = function() opt.path:append(vim.loop.cwd()) end,
})
-- remove old path
Autocmd("DirChangedPre", {
	callback = function() opt.path:remove(vim.loop.cwd()) end,
})

--------------------------------------------------------------------------------
-- SCROLLING
opt.scrolloff = 12
opt.sidescrolloff = 13

-- FIX scrolloff at EoF
-- https://github.com/Aasim-A/scrollEOF.nvim/blob/master/lua/scrollEOF.lua#L11
Autocmd("CursorMoved", {
	callback = function()
		if Bo.filetype == "DressingSelect" then return end

		local win_height = vim.api.nvim_win_get_height(0)
		local win_view = Fn.winsaveview()
		local scrolloff = math.min(opt.scrolloff:get(), math.floor(win_height / 2))
		local scrolloff_line_count = win_height - (Fn.line("w$") - win_view.topline + 1)
		local distance_to_last_line = Fn.line("$") - win_view.lnum ---@diagnostic disable-line: undefined-field
		if
			distance_to_last_line < scrolloff
			and scrolloff_line_count + distance_to_last_line < scrolloff
		then
			win_view.topline = win_view.topline + scrolloff - (scrolloff_line_count + distance_to_last_line)
			Fn.winrestview(win_view)
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
opt.fillchars = { eob = " ", fold = " " }
-- opt.showbreak = "↪"
opt.listchars = {
	nbsp = "󰚌",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "  ",
	lead = "·",
}

Autocmd("BufReadPost", {
	callback = function()
		-- trigger to ensure it's run before determining spaces/tabs
		local success = pcall(Cmd.IndentOMatic)
		if not success then
			vim.notify("IndentOMatic not found.", LogWarn)
			return
		end

		opt_local.listchars = vim.opt_global.listchars:get() -- copy the global
		if Bo.expandtab then
			opt_local.listchars:append { tab = "↹ " }
			opt_local.listchars:append { lead = " " }
		else
			opt_local.listchars:append { tab = "  " }
			opt_local.listchars:append { lead = "·" }
		end
	end,
})

--------------------------------------------------------------------------------
-- Auto-Saving & Auto-read on change
Autocmd({ "BufWinLeave", "BufLeave", "QuitPre", "FocusLost", "InsertLeave" }, {
	pattern = "?*", -- pattern required for some events
	callback = function()
		if
			not Bo.readonly
			and Expand("%") ~= ""
			and (Bo.buftype == "" or Bo.buftype == "acwrite")
			and Bo.filetype ~= "gitcommit"
		then
			Cmd.update(Expand("%:p"))
		end
	end,
})

-- Auto-read on external change. Requires `checktime` to actually check for it
opt.autoread = true

--------------------------------------------------------------------------------

-- Formatting `vim.opt.formatoptions:remove("o")` would not work, since it's
-- overwritten by the ftplugins having the `o` option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
Autocmd("FileType", {
	callback = function() opt_local.formatoptions:remove("o") end,
})

--------------------------------------------------------------------------------
-- FOLDING

-- fold settings required for UFO
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99

-- if not using UFO for folding
-- opt.foldmethod = "indent"

-- Remember folds and cursor
local function remember(mode)
	local ignoredFts = {
		"TelescopePrompt",
		"DressingSelect",
		"DressingInput",
		"toggleterm",
		"gitcommit",
		"replacer",
		"harpoon",
		"help",
		"qf",
	}
	if vim.tbl_contains(ignoredFts, Bo.filetype) or Bo.buftype ~= "" or not Bo.modifiable then return end

	if mode == "save" then
		Cmd.mkview(1)
	else
		Cmd([[silent! loadview 1]]) -- silent to avoid error for files w/o view (e.g. after creation)
	end
end
Autocmd("BufWinLeave", {
	pattern = "?*", -- pattern required, otherwise does not trigger
	callback = function() remember("save") end,
})
Autocmd("BufWinEnter", {
	pattern = "?*",
	callback = function() remember("load") end,
})

--------------------------------------------------------------------------------
-- Add missing buffer names
Autocmd("FileType", {
	pattern = { "Glance", "lazy" },
	callback = function()
		local name = vim.fn.expand("<amatch>")
		name = name:sub(1, 1):upper() .. name:sub(2) -- capitalize
		vim.api.nvim_buf_set_name(0, name)
	end,
})

--------------------------------------------------------------------------------
-- DIAGNOSTICS

local function diagnosticFormat(diagnostic, mode)
	local source = diagnostic.source and diagnostic.source:gsub("%.$", "") or nil
	local code = diagnostic.code
	local out = diagnostic.message
	if code then out = out .. " (" .. code .. ")" end -- some linters have no code
	if source and mode == "float" then out = out .. " [" .. source .. "]" end
	return out
end

vim.diagnostic.config {
	virtual_text = {
		format = function(diagnostic) return diagnosticFormat(diagnostic, "virtual_text") end,
		severity = { min = vim.diagnostic.severity.WARN },
	},
	float = {
		focusable = true,
		border = BorderStyle,
		max_width = 70,
		header = "", -- remove "Diagnostics:" heading
		format = function(diagnostic) return diagnosticFormat(diagnostic, "float") end,
	},
}

--------------------------------------------------------------------------------

-- Skeletons (Templates)
-- apply templates for any filetype named `./templates/skeleton.{ft}`
local skeletonDir = Fn.stdpath("config") .. "/templates"
local filetypeList =
	Fn.system([[ls "]] .. skeletonDir .. [[/skeleton."* | xargs basename | cut -d. -f2]])
local ftWithSkeletons = vim.split(filetypeList, "\n", {})

for _, ft in pairs(ftWithSkeletons) do
	if ft == "" then break end
	local readCmd = "keepalt 0r " .. skeletonDir .. "/skeleton." .. ft .. " | normal! G"

	Autocmd("BufNewFile", {
		pattern = "*." .. ft,
		command = readCmd,
	})

	-- BufReadPost + empty file as additional condition to also auto-insert
	-- skeletons when empty files were created by other apps
	Autocmd("BufReadPost", {
		pattern = "*." .. ft,
		callback = function()
			local curFile = Expand("%")
			local fileIsEmpty = Fn.getfsize(curFile) < 4 -- to account for linebreak weirdness
			if fileIsEmpty then Cmd(readCmd) end
		end,
	})
end

--------------------------------------------------------------------------------
