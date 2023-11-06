local opt_local = vim.opt_local
local opt = vim.opt
local bo = vim.bo
local autocmd = vim.api.nvim_create_autocmd
local u = require("config.utils")

--------------------------------------------------------------------------------
-- FILETYPES

-- make zsh files recognized as sh for bash-ls & treesitter
vim.filetype.add {
	extension = {
		zsh = "sh",
		sh = "sh", -- force sh-files with zsh-shebang to still get sh as filetype
	},
	filename = {
		[".zshrc"] = "sh",
		[".zshenv"] = "sh",
		[".ignore"] = "gitignore", -- fd ignore files
	},
}

--------------------------------------------------------------------------------

-- DIRECTORIES
-- move to custom location where they are synced independently from the dotfiles repo
opt.undodir:prepend(u.vimDataDir .. "undo//")
opt.viewdir = u.vimDataDir .. "view"
opt.shadafile = u.vimDataDir .. "main.shada"
opt.swapfile = false -- doesn't help and only creates useless files and notifications

--------------------------------------------------------------------------------
-- Undo
opt.undofile = true -- enables persistent undo history

-- extra undo-points (= more fine-grained undos)
-- WARN requires `remap = true`, since it otherwise prevents vim abbreviations
-- with those chars from working
local undopointChars = { ".", ",", ";", '"', ":", "'", "<Space>" }
for _, char in pairs(undopointChars) do
	vim.keymap.set("i", char, function()
		if vim.bo.buftype ~= "" then return char end
		return char .. "<C-g>u"
	end, { desc = "󰕌 Extra undopoint for " .. char, remap = true, expr = true })
end

--------------------------------------------------------------------------------

-- Set title so current file can be read from automation app via window title
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = '%{expand("%:p")}'

opt.exrc = true

-- Motions & Editing
opt.startofline = true -- motions like "G" also move to the first char
opt.virtualedit = "block" -- visual-block mode can select beyond end of line
opt.jumpoptions = "stack" -- https://www.reddit.com/r/neovim/comments/16nead7/comment/k1e1nj5/?context=3

-- Search
opt.ignorecase = true
opt.smartcase = true

-- when closing a bracket, briefly flash the matching one
opt.showmatch = true
opt.matchtime = 1 -- deci-seconds

-- Clipboard
opt.clipboard = "unnamedplus"

-- Spelling
opt.spell = false
opt.spelloptions = "camel"
opt.spellfile = { u.linterConfigFolder .. "/spellfile-vim-ltex.add" } -- has to be `.add`
opt.spelllang = "en_us" -- still relevant for `z=`

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Workspace
opt.cursorline = true
opt.signcolumn = "yes:1"

-- Wrapping & Line Length
opt.textwidth = 80 -- only fallback value, mostly overridden by .editorconfig
opt.colorcolumn = "+1"
opt.wrap = false

-- status bar & cmdline
opt.cmdheight = 0
opt.history = 400 -- reduce noise for command history search
opt.shortmess:append("sSI") -- reduce info in :messages
opt.report = 9001 -- disable "x more/fewer lines" messages

-- Character groups
opt.iskeyword:append("-") -- don't treat "-" as word boundary, e.g., for kebab-case

opt.nrformats:append("unsigned") -- make <C-a>/<C-x> ignore negative numbers
opt.nrformats:remove { "bin", "hex" } -- remove ambiguity, since I don't use them anyway

-- Timeouts
opt.updatetime = 250 -- also affects cursorword symbols and lsp-hints
opt.timeoutlen = 666 -- also affects duration until which-key is shown

-- Make
opt.makeprg = "make --silent --warn-undefined-variables"

--------------------------------------------------------------------------------

-- Popups & Cmdline
opt.pumwidth = 15 -- min width
opt.pumheight = 12 -- max height

-- scrolling
opt.scrolloff = 13
opt.sidescrolloff = 13

-- whitespace & indentation
opt.shiftround = true
opt.smartindent = true
-- fallback, mostly set by .editorconfig
opt.expandtab = false
opt.tabstop = 3
opt.shiftwidth = 3

-- invisible chars
opt.list = true
opt.conceallevel = 1
opt.fillchars:append {
	eob = " ",
	fold = " ",
	vert = "║",
	horiz = "═",
}
opt.listchars:append {
	nbsp = "󰚌",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "│ ", -- overridden by indent-blankline
	conceal = "?",
	lead = " ",
	trail = " ",
}

--------------------------------------------------------------------------------
-- AUTOCMDs

-- no list chars in special buffers
autocmd({ "BufNew", "BufReadPost" }, {
	callback = function()
		if bo.buftype ~= "" then opt_local.list = false end
	end,
})

-- Formatting `vim.opt.formatoptions:remove{"o"}` would not work, since it's
-- overwritten by the ftplugins having the `o` option. Therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
autocmd("FileType", {
	callback = function() opt_local.formatoptions:remove("o") end,
})

-- check if file has changed by external program and reload if so
autocmd("FocusGained", {
	callback = vim.cmd.checktime,
})

vim.api.nvim_create_autocmd("QuitPre", {
	callback = function()
		vim.v.oldfiles = vim.tbl_filter(function(path)
			return vim.fn.filereadable(path) == 1
		end)
	end,
})

--------------------------------------------------------------------------------

-- auto-nohl -> https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	local key = vim.fn.keytrans(char)
	local isCmdlineSearch = vim.fn.getcmdtype():find("[/?]") ~= nil
	local searchMvKeys = { "n", "N", "*", "#" } -- works for RHS, therefore no need to consider remaps
	local isNormalMode = vim.api.nvim_get_mode().mode == "n"

	local searchStarted = (key == "/" or key == "?") and isNormalMode
	local searchConfirmed = (key == "<CR>" and isCmdlineSearch)
	local searchCancelled = (key == "<Esc>" and isCmdlineSearch)
	if not (searchStarted or searchConfirmed or searchCancelled or isNormalMode) then return end
	local searchMovement = vim.tbl_contains(searchMvKeys, key)
	local hlSearchOn = vim.o.hlsearch

	if (searchMovement or searchConfirmed or searchStarted) and not hlSearchOn then
		vim.opt.hlsearch = true
	elseif (searchCancelled or not searchMovement) and hlSearchOn and not searchConfirmed then
		vim.opt.hlsearch = false
	end

	-- nvim-hlslens plugin
	if searchConfirmed or searchMovement then
		local installed, hlslens = pcall(require, "hlslens")
		if installed then hlslens.start() end
	end
end, vim.api.nvim_create_namespace("auto_nohl"))

--------------------------------------------------------------------------------

-- SKELETIONS (TEMPLATES)
-- filetype -> extension
local skeletons = {
	python = "py",
	applescript = "applescript",
	javascript = "jxa",
	make = "make",
	sh = "zsh",
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(skeletons),
	callback = function(ctx)
		vim.defer_fn(function()
			local fileStats = vim.loop.fs_stat(vim.fn.expand("%"))
			local specialBuffer = vim.bo.buftype ~= ""
			if specialBuffer or not fileStats then return end

			local filetype = ctx.match
			local ext = skeletons[filetype]
			local skeletonFile = vim.fn.stdpath("config") .. "/templates/skeleton." .. ext
			local noSkeleton = vim.loop.fs_stat(skeletonFile) == nil
			if noSkeleton then
				u.notify("Skeleton", "Skeleton file not found.", "error")
				return
			end

			local fileIsEmpty = fileStats.size < 4 -- account for linebreaks
			if not fileIsEmpty then return end

			vim.cmd("silent keepalt 0read " .. skeletonFile)
			u.normal("G")
		end, 1)
	end,
})

--------------------------------------------------------------------------------
