local opt_local = vim.opt_local
local opt = vim.opt
local fs = vim.fs
local autocmd = vim.api.nvim_create_autocmd
local u = require("config.utils")

--------------------------------------------------------------------------------
-- FILETYPES

vim.filetype.add {
	extension = {
		zsh = "sh",
		sh = "sh", -- force sh-files with zsh-shebang to still get `sh` as filetype
	},
	filename = {
		[".ignore"] = "gitignore", -- ignore files for fd/rg
	},
}

--------------------------------------------------------------------------------
-- DIRECTORIES

-- move to custom location where they are synced independently from the dotfiles repo
opt.undodir = vim.g.syncedData .. "/undo"
opt.viewdir = vim.g.syncedData .. "/view"
opt.shadafile = vim.g.syncedData .. "/main.shada"
opt.swapfile = false -- doesn't help and only creates useless files and notifications

-- automatically cleanup dirs to prevent bloating.
-- once a week, on first FocusLost, delete files older than 30/60 days.
autocmd("FocusLost", {
	once = true,
	callback = function()
		if os.date("%a") == "Mon" then
			vim.fn.system { "find", opt.viewdir:get(), "-mtime", "+60d", "-delete" }
			vim.fn.system { "find", opt.undodir:get()[1], "-mtime", "+30d", "-delete" }
		end
	end,
})

--------------------------------------------------------------------------------
-- UNDO

opt.undofile = true -- enables persistent undo history

-- extra undo-points (= more fine-grained undos)
-- WARN insert mode mappings with `.` or `,` cause problems with typescript
local triggerChars = { ";", '"', "'", "<Space>" }
for _, char in pairs(triggerChars) do
	vim.keymap.set("i", char, function()
		if vim.bo.buftype ~= "" then return char end
		return char .. "<C-g>u"
		-- WARN requires `remap = true`, otherwise prevents abbreviations with them
	end, { desc = "󰕌 Extra undopoint", remap = true, expr = true })
end

--------------------------------------------------------------------------------
-- AUTOMATION (external control)

-- enable reading cwd via window title
opt.title = true
opt.titlelen = 0 -- 0 = do not shorten title
opt.titlestring = "%{getcwd()}"

-- issue commands (via nvim server https://neovim.io/doc/user/remote.html)
if vim.g.neovide then
	pcall(os.remove, "/tmp/nvim_server.pipe") -- FIX server sometimes not properly shut down
	vim.defer_fn(function() vim.fn.serverstart("/tmp/nvim_server.pipe") end, 400)
end

--------------------------------------------------------------------------------
-- CLIPBOARD
opt.clipboard = "unnamedplus"

autocmd("TextYankPost", {
	callback = function() vim.highlight.on_yank { timeout = 1000 } end,
})

--------------------------------------------------------------------------------
-- GENERAL

opt.startofline = true -- motions like "G" also move to the first char
opt.virtualedit = "block" -- visual-block mode can select beyond end of line

opt.showmatch = true -- when closing a bracket, briefly flash the matching one
opt.matchtime = 1 -- duration of that flashing n deci-seconds

opt.spell = false
opt.spellfile = { vim.g.dictionaryPath }
opt.spelllang = "en_us" -- even with spellcheck disabled, still relevant for `z=`

opt.splitright = false -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

opt.cursorline = true
opt.signcolumn = "yes:1"

opt.textwidth = 80 -- mostly set by .editorconfig, therefore only fallback
opt.colorcolumn = "+1" -- one more than textwidth
opt.wrap = false

opt.shortmess:append("sSI") -- reduce info in :messages
opt.report = 9001 -- disable "x more/fewer lines" messages

opt.iskeyword:append("-") -- don't treat "-" as word boundary, e.g. for kebab-case variables
opt.nrformats = {} -- remove octal and hex from <C-a>/<C-x>

opt.updatetime = 250 -- also affects cursorword symbols and lsp-hints
opt.timeoutlen = 666 -- also affects duration until which-key is shown

opt.makeprg = "make --silent --warn-undefined-variables"

opt.pumwidth = 15 -- min width
opt.pumheight = 12 -- max height

opt.sidescrolloff = 15
opt.scrolloff = 15

-- mostly set by .editorconfig, therefore only fallback
opt.expandtab = false
opt.tabstop = 3
opt.shiftwidth = 3

opt.shiftround = true
opt.smartindent = true

-- Formatting `vim.opt.formatoptions:remove("o")` would not work, since it's
-- overwritten by ftplugins having the `o` option (which many do). Therefore
-- needs to be set via autocommand.
autocmd("FileType", {
	callback = function(ctx)
		if ctx.match == "markdown" then return end
		opt_local.formatoptions:remove("o")
		opt_local.formatoptions:remove("t")
	end,
})

--------------------------------------------------------------------------------
-- SEARCH & SUBSTITUTION

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split" -- preview incremental commands like `:substitute`

-- make `:substitute` also notify how many changes were made
-- works, as `CmdlineLeave` is triggered before the execution of the command
autocmd("CmdlineLeave", {
	callback = function()
		local cmdline = vim.fn.getcmdline()
		local isSubstitution = cmdline:find("s ?/.-/.*/%a*$")
		local isMultiFileCmd = cmdline:find("^%l%l?%l?do ") -- cdo, bufdo, etc.
		if isSubstitution and not isMultiFileCmd then vim.cmd(cmdline .. "n") end
	end,
})

--------------------------------------------------------------------------------
-- CMDLINE
opt.cmdheight = 0 -- also auto-set by noice
opt.history = 400 -- reduce noise for command history search

-- if last command was line-jump, remove it from history to reduce noise
vim.api.nvim_create_autocmd("CmdlineLeave", {
	callback = function(ctx)
		if not ctx.match == ":" then return end
		vim.defer_fn(function()
			local lineJump = vim.fn.histget(":", -1):match("^%d+$")
			if lineJump then vim.fn.histdel(":", -1) end
		end, 100)
	end,
})

--------------------------------------------------------------------------------
-- INVISIBLE CHARS

opt.list = true
opt.conceallevel = 1

opt.fillchars:append {
	eob = " ",
	fold = " ",
	-- solid window separators
	horiz = "▄",
	vert = "█",
	horizup = "█",
	horizdown = "█",
	vertleft = "█",
	vertright = "█",
	verthoriz = "█",
}
opt.listchars = {
	nbsp = "󰚌",
	conceal = "?",
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "│ ", -- mostly overridden by indent-blankline
	lead = " ",
	trail = " ",
}

--------------------------------------------------------------------------------
-- keep split evenly sized on window resize
vim.api.nvim_create_autocmd("WinResized", {
	callback = function() vim.cmd.wincmd("=") end,
})

--------------------------------------------------------------------------------
-- AUTO-SAVE
opt.autowriteall = true
autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
	callback = function(ctx)
		local bufnr = ctx.buf
		local bo = vim.bo[bufnr]
		local b = vim.b[bufnr]
		if
			(b.saveQueued and ctx.event ~= "FocusLost")
			or bo.buftype ~= ""
			or bo.ft == "gitcommit"
			or bo.readonly
		then
			return
		end

		local debounce = ctx.event == "FocusLost" and 0 or 2000 -- save at once on focus loss
		b.saveQueued = true
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then return end
			-- INFO removing `noautocmd` results in weird cursor movement
			vim.api.nvim_buf_call(bufnr, function() vim.cmd("silent! noautocmd lockmarks update!") end)
			b.saveQueued = false
		end, debounce)
	end,
})

--------------------------------------------------------------------------------
-- AUTO-CD TO PROJECT ROOT
-- (simplified version of project.nvim)
local autoCd = {
	rootFiles = {
		"Makefile",
		".git",
		"info.plist", -- Alfred workflows
		".project-root", -- manual marker file
	},
	childOfDir = {
		".config", -- my dotfiles
		"com~apple~CloudDocs", -- iCloud
	},
}

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(ctx)
		-- GUARD
		local bufPath = ctx.file
		local specialBuffer = vim.api.nvim_buf_get_option(ctx.buf, "buftype") ~= ""
		local exists = vim.loop.fs_stat(bufPath) ~= nil
		if specialBuffer or not exists then return end

		-- rootFile
		local newRoot
		local rootFile = fs.find(autoCd.rootFiles, { upward = true, path = bufPath })[1]
		if rootFile then newRoot = fs.dirname(rootFile) end

		-- childOfDir
		for dir in fs.parents(bufPath) do
			local parent = fs.dirname(dir)
			local isChildOfDir = vim.tbl_contains(autoCd.childOfDir, fs.basename(parent))
			local parentIsDeeper = #dir > #(newRoot or "")
			if isChildOfDir and parentIsDeeper then
				newRoot = dir
				break
			end
		end

		if newRoot and vim.loop.cwd() ~= newRoot then vim.loop.chdir(newRoot) end
	end,
})

--------------------------------------------------------------------------------

-- AUTO-CLOSE BUFFERS whose files do not exist anymore
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "QuickFixCmdPost" }, {
	-- INFO also trigger on `QuickFixCmdPost`, in case a make command deletes file
	callback = function(ctx)
		local bufnr = ctx.buf
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then return end

			local function fileExists(bufpath) return vim.loop.fs_stat(bufpath) ~= nil end

			-- check if buffer was deleted
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			local isSpecialBuffer = vim.bo[bufnr].buftype ~= ""
			local isNewBuffer = bufname == ""
			-- prevent the temporary buffers from conform.nvim's "injected"
			-- formatter to be closed by this (filename is like "README.md.5.lua")
			local conformTempBuf = bufname:find("%.md%.%d+%.%l+$")
			if fileExists(bufname) or isSpecialBuffer or isNewBuffer or conformTempBuf then return end

			-- open last existing oldfile
			for _, oldfile in pairs(vim.v.oldfiles) do
				if fileExists(oldfile) then
					vim.cmd.edit(oldfile)
					vim.notify(("%q does not exist anymore."):format(vim.fs.basename(bufname)))
					return
				end
			end
		end, 150)
	end,
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
	sh = "zsh",
	toml = "toml",
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(skeletons),
	callback = function(ctx)
		vim.defer_fn(function()
			-- GUARD
			if not vim.api.nvim_buf_is_valid(ctx.buf) then return end
			local fileStats = vim.loop.fs_stat(ctx.file)
			local specialBuffer = vim.api.nvim_buf_get_option(ctx.buf, "buftype") ~= ""
			if specialBuffer or not fileStats then return end

			-- GUARD terminal buffer edited in nvim
			if ctx.file:find("^/private/tmp/.*.zsh") then return end

			local ft = ctx.match
			local ext = skeletons[ft]
			local skeletonFile = vim.fn.stdpath("config") .. "/templates/skeleton." .. ext
			local noSkeleton = vim.loop.fs_stat(skeletonFile) == nil
			if noSkeleton then
				u.notify("Skeleton", "Skeleton file not found.", "error")
				return
			end

			local fileIsEmpty = fileStats.size < 4 -- account for linebreaks
			if not fileIsEmpty then return end

			-- read file
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
