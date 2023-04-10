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
-- WARN requires remap, otherwise prevents vim abbrev. w/ those chars from working
local undopointChars = { ".", ",", ";", '"', ":", "<Space>" }
for _, char in pairs(undopointChars) do
	keymap("i", char, function()
		local expr = char .. "<C-g>u"
		if bo.filetype == "TelescopePrompt" then expr = char end -- FIX interference with telescope otherwise
		return expr
	end, { desc = "extra undopoint for " .. char, remap = true, expr = true })
end

--------------------------------------------------------------------------------

-- Motions & Editing
opt.startofline = true -- motions like "G" also move to the first char
opt.matchpairs:append("<:>") -- added pairs must be different (e.g. not two double quotes)

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
opt.previewheight = 20

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
opt.wrapmargin = 2 -- especially useful when using a scrollbar
opt.wrap = false
opt.breakindent = false
opt.linebreak = true -- do not break up full words on wrap

-- Color Column: textwidth + guiding line for `gm`
autocmd({ "VimEnter", "VimResized" }, {
	-- the "WinResized" autocmd event does not seem to work currently
	callback = function()
		if opt_local.wrap:get() then return end
		local gmColumn = math.floor(fn.winwidth("%") / 2) ---@diagnostic disable-line: param-type-mismatch
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
opt.timeoutlen = 666 -- also affects duration until which-key is shown

--------------------------------------------------------------------------------
-- PATH (for `gf`)

-- pwd is set via projects.nvim
autocmd("DirChanged", {
	callback = function() opt.path:append(vim.loop.cwd()) end,
})
autocmd("DirChangedPre", {
	callback = function() opt.path:remove(vim.loop.cwd()) end,
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
		local scrolloff = math.min(opt.scrolloff:get(), math.floor(win_height / 2))
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

autocmd("BufReadPost", {
	callback = function()
		-- trigger to ensure it's run before determining spaces/tabs
		local success = pcall(cmd.IndentOMatic)
		if not success then
			vim.notify("Indent-o-Matic not found.", LogWarn)
			return
		end

		opt_local.listchars = vim.opt_global.listchars:get() -- copy the global
		if bo.expandtab then
			opt_local.listchars:append { tab = "↹ " }
			opt_local.listchars:append { lead = " " }
		else
			opt_local.listchars:append { tab = "  " }
			opt_local.listchars:append { lead = "·" }
		end
	end,
})

--------------------------------------------------------------------------------
-- AUTO-SAVING
opt.autowrite = true
opt.autowriteall = true

autocmd({ "BufWinLeave", "BufLeave", "QuitPre", "FocusLost", "InsertLeave" }, {
	pattern = "?*", -- pattern required for some events
	callback = function()
		local filepath = expand("%:p")
		if
			fn.filereadable(filepath) == 1
			and not bo.readonly
			and expand("%") ~= ""
			and (bo.buftype == "" or bo.buftype == "acwrite")
			and bo.filetype ~= "gitcommit"
		then
			cmd.update(filepath)
		end
	end,
})

--------------------------------------------------------------------------------

-- Formatting `vim.opt.formatoptions:remove("o")` would not work, since it's
-- overwritten by the ftplugins having the `o` option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
autocmd("FileType", {
	callback = function() opt_local.formatoptions:remove("o") end,
})

--------------------------------------------------------------------------------
-- FOLDING

-- fold settings
opt.foldlevelstart = 5 -- close deep folds at the beginning; only applies to new buffers
opt.foldopen:remove { "search" } -- less unintentional opening of folds

-- Remember folds and cursor
local function remember(mode)
	-- stylua: ignore
	local ignoredFts = { "TelescopePrompt", "DressingSelect", "DressingInput", "toggleterm", "gitcommit", "replacer", "harpoon", "help", "qf" }
	if vim.tbl_contains(ignoredFts, bo.filetype) or bo.buftype ~= "" or not bo.modifiable then return end

	if mode == "save" then
		cmd.mkview(1)
	else
		pcall(function() cmd.loadview(1) end) -- pcall, since new files have no view yet
	end
end
autocmd("BufWinLeave", {
	pattern = "?*", -- pattern required, otherwise does not trigger
	callback = function() remember("save") end,
})
autocmd("BufWinEnter", {
	pattern = "?*",
	callback = function() remember("load") end,
})
--------------------------------------------------------------------------------
-- Add missing buffer names, e.g. for status bar
autocmd("FileType", {
	pattern = { "Glance", "lazy", "PlenaryTestPopup" },
	callback = function()
		local name = vim.fn.expand("<amatch>")
		name = name:sub(1, 1):upper() .. name:sub(2) -- capitalize
		vim.api.nvim_buf_set_name(0, name)
	end,
})

--------------------------------------------------------------------------------

-- Skeletons (Templates)
-- apply templates for any filetype named `./templates/skeleton.{ft}`
local skeletonDir = fn.stdpath("config") .. "/templates"
local filetypeList =
	fn.system([[ls "]] .. skeletonDir .. [[/skeleton."* | xargs basename | cut -d. -f2]])
local ftWithSkeletons = vim.split(filetypeList, "\n", {})

for _, ft in pairs(ftWithSkeletons) do
	if ft == "" then break end
	local readCmd = "keepalt 0r " .. skeletonDir .. "/skeleton." .. ft .. " | normal! G"

	autocmd("BufNewFile", {
		pattern = "*." .. ft,
		command = readCmd,
	})

	-- BufReadPost + empty file as additional condition to also auto-insert
	-- skeletons when empty files were created by other apps
	autocmd("BufReadPost", {
		pattern = "*." .. ft,
		callback = function()
			local curFile = expand("%")
			local fileIsEmpty = fn.getfsize(curFile) < 4 -- to account for linebreak weirdness
			if fileIsEmpty then cmd(readCmd) end
		end,
	})
end

--------------------------------------------------------------------------------
