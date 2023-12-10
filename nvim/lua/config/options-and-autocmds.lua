local opt_local = vim.opt_local
local opt = vim.opt
local autocmd = vim.api.nvim_create_autocmd
local u = require("config.utils")

--------------------------------------------------------------------------------
-- FILETYPES

vim.filetype.add {
	extension = {
		applescript = "applescript",
	},
	filename = {
		[".ignore"] = "gitignore",
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
-- UNDO
opt.undofile = true -- enables persistent undo history

-- extra undo-points (= more fine-grained undos)
-- WARN requires `remap = true`, since it otherwise prevents vim abbreviations
-- with those chars from working
for _, char in pairs { ".", ",", ";", '"', ":", "'", "<Space>" } do
	vim.keymap.set("i", char, function()
		if vim.bo.buftype ~= "" then return char end
		return char .. "<C-g>u"
	end, { desc = "󰕌 Extra undopoint for " .. char, remap = true, expr = true })
end

--------------------------------------------------------------------------------

-- AUTOMATION (external control)

-- Set title so current file can be read from automation app via window title
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = '%{expand("%:p")}'

-- nvim server (RPC) to remote control neovide instances https://neovim.io/doc/user/remote.html
if vim.fn.has("gui_running") == 1 then
	pcall(os.remove, "/tmp/nvim_server.pipe") -- FIX server sometimes not properly shut down
	vim.defer_fn(function() vim.fn.serverstart("/tmp/nvim_server.pipe") end, 400)
end

--------------------------------------------------------------------------------

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

-- Spelling
opt.spell = false
opt.spellfile = { u.linterConfigFolder .. "/spellfile-vim-ltex.add" } -- has to be `.add`
opt.spelllang = "en_us" -- even with spellcheck disabled, still relevant for `z=`

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Workspace
opt.cursorline = true
opt.signcolumn = "yes:1"

-- Wrapping & Line Length
opt.textwidth = 80 -- mostly set by .editorconfig, therefore only fallback
opt.colorcolumn = "+1"
opt.wrap = false

-- status bar & cmdline
opt.cmdheight = 0
opt.history = 400 -- reduce noise for command history search
opt.shortmess:append("sSI") -- reduce info in :messages
opt.report = 9001 -- disable "x more/fewer lines" messages

-- Character groups
opt.iskeyword:append("-") -- don't treat "-" as word boundary, e.g. for kebab-case variables

opt.nrformats:append("unsigned") -- make <C-a>/<C-x> ignore negative numbers
opt.nrformats:remove { "bin", "hex" } -- remove ambiguity, since I don't use them anyway

-- Timeouts
opt.updatetime = 250 -- also affects cursorword symbols and lsp-hints
opt.timeoutlen = 666 -- also affects duration until which-key is shown

-- Make
opt.makeprg = "make --silent --warn-undefined-variables"

--------------------------------------------------------------------------------
-- CLIPBOARD

opt.clipboard = "unnamedplus"

-- sticky yank operations
vim.keymap.set({ "n", "x" }, "y", function()
	vim.g.cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y"
end, { desc = "󰅍 Sticky yank", expr = true })
vim.keymap.set("n", "Y", function()
	vim.g.cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y$"
end, { desc = "󰅍 Sticky yank", expr = true })

-- post-yank-highlight
autocmd("TextYankPost", {
	callback = function()
		if vim.v.event.operator ~= "y" then return end -- do not trigger for `d`

		-- FIX issue with vim-visual-multi
		if vim.b["VM_Selection"] and vim.b["VM_Selection"].Regions then return end

		vim.highlight.on_yank { timeout = 1000 }
		vim.api.nvim_win_set_cursor(0, vim.g.cursorPreYank)
	end,
})
--------------------------------------------------------------------------------

-- Popups & Cmdline
opt.pumwidth = 15 -- min width
opt.pumheight = 12 -- max height

-- scrolling
opt.sidescrolloff = 13
opt.scrolloff = 13

-- whitespace & indentation
opt.shiftround = true
opt.smartindent = true
opt.expandtab = false -- mostly set by .editorconfig, therefore only fallback
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
opt.listchars = {
	nbsp = "󰚌",
	conceal = "?",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "│ ", -- mostly overridden by indent-blankline
	lead = " ",
	trail = nil, -- so multi-space gets priority
}

-- no list chars in special buffers
autocmd({ "BufNew", "BufReadPost" }, {
	callback = function()
		vim.defer_fn(function()
			if vim.bo.buftype ~= "" and vim.bo.ft ~= "query" then opt_local.list = false end
		end, 1)
	end,
})

--------------------------------------------------------------------------------
-- AUTO-SAVE

opt.autowriteall = true
autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
	callback = function(ctx)
		local b = vim.bo[ctx.buf]
		local bufname = vim.api.nvim_buf_get_name(0)
		local function exists(file) return vim.loop.fs_stat(file) and file ~= "" end

		if vim.b.saveQueued or b.buftype ~= "" or b.ft == "gitcommit" or b.readonly then return end

		vim.b["saveQueued"] = true
		vim.defer_fn(function()
			if not exists(bufname) then return end
			vim.cmd("silent! noautocmd update")
			vim.b["saveQueued"] = false
		end, 2000)
	end,
})

--------------------------------------------------------------------------------
-- AUTO-CD TO PROJECT ROOT (PROJECT.NVIM LITE)
local autocdConfig = {
	rootFiles = { "info.plist", "Makefile", ".git" }, -- order = priority
	childOfDir = { ".config" },
}

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(ctx)
		local function exists(path) return vim.loop.fs_stat(path) ~= nil end
		local bufname = vim.api.nvim_buf_get_name(ctx.buf)
		if vim.bo.buftype ~= "" or not exists(bufname) then return end

		local startPath = vim.fs.dirname(bufname)
		local root
		repeat
			for _, file in ipairs(autocdConfig.rootFiles) do
				local path = startPath .. "/" .. file
				if exists(path) then
					root = vim.fs.dirname(path)
					break
				end
			end
			if root then break end
			for _, dir in ipairs(autocdConfig.childOfDir) do
				if vim.fs.basename(vim.fs.dirname(startPath)) == dir then
					root = startPath
					break
				end
			end
			if root then break end
			startPath = vim.fs.dirname(startPath)
		until startPath == "/"

		if root and vim.loop.cwd() ~= root then vim.cmd.cd(root) end
	end,
})

--------------------------------------------------------------------------------

-- Formatting `vim.opt.formatoptions:remove{"o"}` would not work, since it's
-- overwritten by ftplugins having the `o` option (which most do). Therefore
-- needs to be set via autocommand
autocmd("FileType", {
	callback = function() opt_local.formatoptions:remove("o") end,
})

--------------------------------------------------------------------------------

-- AUTO-NOHL
-- https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
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
	javascript = "js",
	make = "make",
	sh = "sh",
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(skeletons),
	callback = function(ctx)
		vim.defer_fn(function()
			local fileStats = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
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

			-- write file
			local file = io.open(skeletonFile, "r")
			if not file then return end
			local lines = vim.split(file:read("*a"), "\n")
			file:close()
			-- overwrite so it's idempotent, since `Filetype` event is sometimes triggered twice
			vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
			vim.api.nvim_win_set_cursor(0, { #lines, 0 })
		end, 1)
	end,
})

--------------------------------------------------------------------------------
