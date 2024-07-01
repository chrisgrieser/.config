local opt = vim.opt
local u = require("config.utils")

--------------------------------------------------------------------------------
-- GENERAL

opt.undofile = true -- enables persistent undo history

opt.startofline = true -- motions like "G" also move to the first char
opt.virtualedit = "block" -- visual-block mode can select beyond end of line

opt.showmatch = true -- when closing a bracket, briefly flash the matching one
opt.matchtime = 1 -- duration of that flashing n deci-seconds

opt.spell = false
opt.spellfile = vim.g.linterConfigs .. "/spellfile.add" -- needs `.add` extension
opt.spelllang = "en_us" -- even with spellcheck disabled, still relevant for `z=`

opt.splitright = true -- split right instead of left
opt.splitbelow = true -- split down instead of up

opt.cursorline = true
opt.signcolumn = "yes:1"

opt.textwidth = 80 -- mostly set by .editorconfig, therefore only fallback
opt.colorcolumn = "+1" -- one more than textwidth
opt.wrap = false
opt.breakindent = true -- indent wrapped lines

opt.shortmess:append("sSI") -- reduce info in :messages
opt.report = 9001 -- disable "x more/fewer lines" messages

opt.iskeyword:append("-") -- treat `-` as word character, same as `_`
opt.nrformats = {} -- remove octal and hex from <C-a>/<C-x>

opt.updatetime = 250 -- also affects cursorword symbols and lsp-hints
opt.timeoutlen = 666 -- also affects duration until which-key is shown

opt.pumwidth = 15 -- min width
opt.pumheight = 12 -- max height

opt.sidescrolloff = 12
vim.g.baseScrolloff = 12 -- so scrolloff-changing function can use this
opt.scrolloff = vim.g.baseScrolloff

-- mostly set by .editorconfig, therefore only fallback
opt.expandtab = false
opt.tabstop = 3
opt.shiftwidth = 3

opt.shiftround = true
opt.smartindent = true

-- Formatting `vim.opt.formatoptions:remove("o")` would not work, since it's overwritten by ftplugins having the `o` option (which many do). Therefore needs to be set via autocommand.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(ctx)
		if ctx.match ~= "markdown" then
			vim.opt_local.formatoptions:remove("o")
			vim.opt_local.formatoptions:remove("t")
		end
	end,
})

--------------------------------------------------------------------------------
-- FILETYPES

vim.filetype.add {
	-- ignore files for fd/rg
	filename = { [".ignore"] = "gitignore" },
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
vim.api.nvim_create_autocmd("FocusLost", {
	once = true,
	callback = function()
		if os.date("%a") ~= "Mon" then return end
		vim.system { "find", opt.viewdir:get(), "-mtime", "+60d", "-delete" }
		vim.system { "find", opt.undodir:get()[1], "-mtime", "+30d", "-delete" }
	end,
})

--------------------------------------------------------------------------------
-- AUTOMATION (external control)

-- enable reading cwd via window title
opt.title = true
opt.titlelen = 0 -- 0 = do not shorten title
opt.titlestring = "%{getcwd()}"

-- issue commands via nvim server
if vim.g.neovide then
	pcall(os.remove, "/tmp/nvim_server.pipe") -- in case of crash, the server is still there
	vim.fn.serverstart("/tmp/nvim_server.pipe")
end

--------------------------------------------------------------------------------
-- CLIPBOARD
opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.highlight.on_yank { timeout = 1000 } end,
})

-- copying stuff from neovim to other apps should trim the trailing newline that
-- nvim adds for linewise selections. Also, if it's one line, remove the indent.
-- (`pbpaste` and `pbcopy` are macOS CLIs, adapt if on other OS.)
vim.api.nvim_create_autocmd("FocusLost", {
	callback = function()
		local systemCb = vim.system({ "pbpaste" }):wait().stdout or ""
		if systemCb ~= vim.fn.getreg("+") then return end
		local trimmed = systemCb:gsub("\n$", "")
		if not trimmed:find("\n") then trimmed = vim.trim(trimmed) end
		vim.system({ "pbcopy" }, { stdin = trimmed })
	end,
})

--------------------------------------------------------------------------------
-- SEARCH & CMDLINE

opt.ignorecase = true
opt.smartcase = true
opt.cmdheight = 0 -- also auto-set by noice
opt.history = 400 -- reduce noise for command history search

--------------------------------------------------------------------------------
-- INVISIBLE CHARS

opt.list = true
opt.conceallevel = 2

opt.fillchars:append {
	eob = " ",
	fold = " ",
	-- thick window separators
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
	precedes = "…",
	extends = "…",
	multispace = "·",
	tab = "│ ", -- mostly overridden by indent-blankline
	lead = " ",
	trail = " ",
}

--------------------------------------------------------------------------------
-- AUTO-SAVE
opt.autowriteall = true
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
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
			-- `noautocmd` prevents weird cursor movement
			vim.api.nvim_buf_call(bufnr, function() vim.cmd("silent! noautocmd lockmarks update!") end)
			b.saveQueued = false
		end, debounce)
	end,
})

--------------------------------------------------------------------------------
-- AUTO-CD TO PROJECT ROOT
-- (simplified version of project.nvim)
local autoCd = {
	childOfRoot = {
		".git",
		"Justfile",
		"info.plist", -- Alfred workflows
	},
	parentOfRoot = {
		".config",
		".obsidian", -- internal Obsidian folder
		"com~apple~CloudDocs", -- iCloud
	},
}
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(ctx)
		local root = vim.fs.root(ctx.buf, function(name, path)
			local dirHasChildMarker = vim.tbl_contains(autoCd.childOfRoot, name)
			local parentName = vim.fs.basename(vim.fs.dirname(path))
			local dirHasParentMarker = vim.tbl_contains(autoCd.parentOfRoot, parentName)
			return dirHasChildMarker or dirHasParentMarker
		end)
		if root then vim.uv.chdir(root) end
	end,
})

--------------------------------------------------------------------------------

-- Delete all non-existing buffers on `FocusGained`
vim.api.nvim_create_autocmd("FocusGained", {
	callback = function()
		local closedBuffers = {}
		vim.iter(vim.api.nvim_list_bufs())
			:filter(function(bufnr)
				local valid = vim.api.nvim_buf_is_valid(bufnr)
				local loaded = vim.api.nvim_buf_is_loaded(bufnr)
				return valid and loaded
			end)
			:filter(function(bufnr)
				local bufPath = vim.api.nvim_buf_get_name(bufnr)
				local doesNotExist = vim.loop.fs_stat(bufPath) == nil
				local notSpecialBuffer = vim.bo[bufnr].buftype == ""
				local notNewBuffer = bufPath ~= ""
				return doesNotExist and notSpecialBuffer and notNewBuffer
			end)
			:each(function(bufnr)
				local bufName = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
				table.insert(closedBuffers, bufName)
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end)
		if #closedBuffers == 0 then return end

		if #closedBuffers == 1 then
			u.notify("Buffer closed", closedBuffers[1])
		else
			local text = "- " .. table.concat(closedBuffers, "\n- ")
			u.notify("Buffers closed", text)
		end

		-- closing all buffers and thus ending up in empty buffer, re-open the
		-- first oldfile that exists
		vim.defer_fn(function()
			if vim.api.nvim_buf_get_name(0) ~= "" then return end
			for _, file in ipairs(vim.v.oldfiles) do
				if vim.uv.fs_stat(file) and vim.fs.basename(file) ~= "COMMIT_EDITMSG" then
					vim.cmd.edit(file)
					return
				end
			end
		end, 1)
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

-- SKELETONS (TEMPLATES)
local skeletons = {
	python = { "**/*.py", "template.py" },
	lua = { vim.g.localRepos .. "/**/lua/**/*.lua", "module.lua" },
	applescript = { "**/*.applescript", "template.applescript" },
	javascript = { "**/Alfred.alfredpreferences/workflows/**/*.js", "jxa.js" },
	just = { "**/*Justfile", "justfile.just" },
	sh = { "**/*.sh", "template.zsh" },
	toml = { "**/*typos.toml", "typos.toml" },
	yaml = { "**/.github/workflows/**/*.y*ml", "github-action.yaml" },
}
-- not `BufNewFile` as it doesn't trigger on files created outside vim
vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(skeletons),
	callback = function(ctx)
		vim.defer_fn(function()
			-- GUARD
			local stats = vim.loop.fs_stat(ctx.file)
			if not stats then return end
			local fileNotEmpty = stats.size > 10 -- account for linebreaks etc.
			if fileNotEmpty then return end
			local ft = ctx.match
			local glob = skeletons[ft][1]
			local matchesGlob = vim.glob.to_lpeg(glob):match(ctx.file)
			if not matchesGlob then return end

			-- read template & look for cursor placeholder
			local skeletonFile = vim.fn.stdpath("config") .. "/templates/" .. skeletons[ft][2]
			local lines = {}
			local cursor
			local row = 1
			for line in io.lines(skeletonFile) do
				local placeholderPos = line:find("%$0")
				if placeholderPos then
					line = line:gsub("%$0", "")
					cursor = { row, placeholderPos - 1 }
				end
				table.insert(lines, line)
				row = row + 1
			end

			-- overwrite so it's idempotent, since `FileType` event is sometimes triggered twice
			vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
			if cursor then vim.api.nvim_win_set_cursor(0, cursor) end
		end, 1)
	end,
})

--------------------------------------------------------------------------------

-- add signs to the quickfix list
local quickfix_ns = vim.api.nvim_create_namespace("quickfix_signs")
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	callback = function()
		local sign = "" -- CONFIG

		local function setSigns(qf)
			vim.api.nvim_buf_set_extmark(qf.bufnr, quickfix_ns, qf.lnum - 1, qf.col - 1, {
				sign_text = sign,
				sign_hl_group = "DiagnosticSignInfo",
				priority = 200, -- Gitsigns uses 6 by default, we want to be above
			})
		end

		-- move to 1st item (`pcall` as deleting the list also triggers `QuickFixCmdPost`)
		pcall(vim.cmd.cfirst)

		-- clear signs
		local group = vim.api.nvim_create_augroup("quickfix_signs", { clear = true })
		vim.api.nvim_buf_clear_namespace(0, quickfix_ns, 0, -1)

		-- set signs
		for _, qf in pairs(vim.fn.getqflist()) do
			if vim.api.nvim_buf_is_loaded(qf.bufnr) then
				setSigns(qf)
			else
				vim.api.nvim_create_autocmd("BufReadPost", {
					group = group,
					once = true,
					buffer = qf.bufnr,
					callback = function() setSigns(qf) end,
				})
			end
		end
	end,
})

--------------------------------------------------------------------------------
-- git conflict markers
-- simplified version of `git-conflict.nvim`
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	callback = function(ctx)
		local currentFile = vim.api.nvim_buf_get_name(ctx.buf)
		vim.system({ "git", "diff", "--check", "--", currentFile }, {}, function(out)
			if out.code == 0 then return end -- no conflict markers

			local conflictLnum = out.stderr:match("(%d+): leftover conflict marker")
			assert(conflictLnum, "pattern failed: " .. out.stderr)

			vim.api.nvim_win_set_cursor(0, { tonumber(conflictLnum), 0 })
			vim.fn.matchadd("DiagnosticVirtualTextInfo", [[^\(<<<<<<<\|=======\|>>>>>>>\||||||||\).*]])
			vim.diagnostic.enable(false, { bufnr = ctx.buf })
		end)
	end,
})
