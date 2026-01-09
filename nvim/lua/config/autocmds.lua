---BASICS-----------------------------------------------------------------------
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Highlighted Yank",
	callback = function() vim.hl.on_yank { timeout = 1500 } end,
})

vim.api.nvim_create_autocmd("VimResized", {
	desc = "User: keep splits equally sized on window resize",
	command = "wincmd =",
})

vim.api.nvim_create_autocmd("BufReadPost", {
	desc = "User: Restore cursor position",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype ~= "" then return end
		vim.cmd([[silent! normal! g`"]])
	end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "WinLeave" }, {
	desc = "User: Cursorline only in active window",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype ~= "" then return end
		vim.opt_local.cursorline = ctx.event ~= "WinLeave"
	end,
})

-- https://github.com/neovim/neovim/issues/26449#issuecomment-1845293096
-- using an insert-mode mapping on `esc` breaks `:abbreviate`, and `InsertLeave`
-- also does not work
vim.api.nvim_create_autocmd("WinScrolled", {
	desc = "User: exit snippet",
	callback = function() vim.snippet.stop() end,
})

---LSP CODELENS-----------------------------------------------------------------
do
	vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "LspAttach", "LspProgress" }, {
		desc = "User: enable LSP codelenses",
		callback = function(ctx)
			-- when the LSP has loaded the workspace (needed for `lua_ls`)
			local lspProgressEnd = ctx.event == "LspProgress"
				and ctx.data.params.value.kind == "end"
				and ctx.data.params.value.title == "Loading workspace"
			if ctx.event == "LspProgress" and not lspProgressEnd then return end

			vim.lsp.codelens.refresh { bufnr = ctx.buf }
		end,
	})

	-- format with padding & icon
	-- caveat: flickers on refresh, since there is an eager display in
	-- `resolve_lenses` which is not exposed
	local function formatLenses(lenses)
		local icon = "󰏷"
		local formattedLenses = vim.iter(lenses or {}):fold({}, function(acc, lens)
			local title = lens.command and lens.command.title
			if not title then return acc end -- filter "Unresolved lens…"
			lens.command.title = title
				:gsub("(%d+) reference(s?) to file", " %1 backlink%2 ") -- markdown_oxide
				:gsub("(%d+) references?", " " .. icon .. " %1 ")
			table.insert(acc, lens)
			return acc
		end)
		return formattedLenses
	end

	local originalDisplay = vim.lsp.codelens.display
	vim.lsp.codelens.display = function(lenses, bufnr, client_id) ---@diagnostic disable-line: duplicate-set-field
		originalDisplay(formatLenses(lenses), bufnr, client_id)
	end
end

---COLORSCHEMES DEPENDING ON SYSTEM MODE----------------------------------------
do
	-- 1. tell neovide to sync `background` with system dark mode
	-- (terminal already does so by default)
	vim.g.neovide_theme = "auto"
	local prevBg

	-- 2. tell nvim to sync colorscheme with `background`
	vim.api.nvim_create_autocmd("OptionSet", {
		desc = "User: Sync colorscheme with `background`",
		pattern = "background",
		callback = function()
			-- prevent recursion, since some colorschemes also set background
			-- (not using `vim.v.option_old` due to race with multiple triggerings)
			if vim.v.option_new == prevBg then return end
			prevBg = vim.v.option_new

			vim.cmd.highlight("clear") -- so next theme isn't affected by previous one
			local newColor = vim.v.option_new == "light" and vim.g.lightColor or vim.g.darkColor
			vim.schedule(function() pcall(vim.cmd.colorscheme, newColor) end)
		end,
	})
end

---SYNC TERMINAL BACKGROUND-----------------------------------------------------

-- https://github.com/neovim/neovim/issues/16572#issuecomment-1954420136
-- https://www.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
if vim.fn.has("gui_running") == 0 then
	local termBgModified = false
	vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
		desc = "User: Enable terminal background sync",
		callback = function()
			local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
			if normal.bg then
				io.write(string.format("\027]11;#%06x\027\\", normal.bg))
				termBgModified = true
			end
		end,
	})

	vim.api.nvim_create_autocmd("UILeave", {
		desc = "User: Disable terminal background sync",
		callback = function()
			if termBgModified then io.write("\027]111\027\\") end
		end,
	})
end

---AUTO-CLEANUP-----------------------------------------------------------------
vim.api.nvim_create_autocmd("FocusLost", {
	desc = "User: Auto-cleanup. Once a week, on first `FocusLost`, delete older files.",
	once = true,
	callback = function()
		if jit.os ~= "OSX" then return end -- using macOS commands
		if os.date("%a") == "Mon" then
			vim.system { "find", vim.o.undodir, "-mtime", "+30d", "-delete" }
			vim.system { "find", vim.lsp.log.get_filename(), "-size", "+20M", "-delete" }
		end
	end,
})

---AUTO-SAVE--------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
	desc = "User: Auto-save",
	callback = function(ctx)
		local saveInstantly = ctx.event == "FocusLost" or ctx.event == "BufLeave"
		local bo, b = vim.bo[ctx.buf], vim.b[ctx.buf]
		local bufname = ctx.file
		if bo.buftype ~= "" or bo.ft == "gitcommit" or bo.readonly then return end
		if b.saveQueued and not saveInstantly then return end

		b.saveQueued = true
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(ctx.buf) then return end

			vim.api.nvim_buf_call(ctx.buf, function()
				-- saving with explicit name prevents issues when changing `cwd`
				-- `:update!` suppresses "The file has been changed since reading it!!!"
				local vimCmd = ("silent! noautocmd lockmarks update! %q"):format(bufname)
				vim.cmd(vimCmd)
			end)
			b.saveQueued = false
		end, saveInstantly and 0 or 2000)
	end,
})

---AUTO-CD TO PROJECT ROOT------------------------------------------------------
-- (simplified version of project.nvim)
do
	local config = {
		childOfRoot = {
			".git",
			"Justfile",
			"info.plist", -- Alfred workflows
			"biome.jsonc",
		},
		parentOfRoot = {
			".config", -- my dotfiles
			"com~apple~CloudDocs", -- macOS iCloud
			vim.fs.basename(vim.env.HOME), -- $HOME
			"Cellar", -- homebrew
		},
	}

	vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
		-- also trigger on `FocusGained` to account for deletions of file outside nvim
		desc = "User: Auto-cd to project root",
		callback = function(ctx)
			-- GUARD
			local filename = vim.fs.basename(ctx.file)
			if filename == "COMMIT_EDITMSG" or filename == "git-rebase-todo" then return end
			if not vim.uv.cwd() then -- cwd is unset if dir was deleted
				vim.uv.chdir(vim.fn.stdpath("config")) -- fallback to nvim config
			end

			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(ctx.buf) then return end
				if vim.startswith(ctx.file, "/private/var/") then return end -- `pass` cli buffers

				local root = vim.fs.root(ctx.buf, function(name, path)
					local parentName = vim.fs.basename(vim.fs.dirname(path))
					local dirHasParentMarker = vim.tbl_contains(config.parentOfRoot, parentName)
					local dirHasChildMarker = vim.tbl_contains(config.childOfRoot, name)
					return dirHasChildMarker or dirHasParentMarker
				end)
				if root and root ~= "" then vim.uv.chdir(root) end
			end)
		end,
	})
end

---AUTO-CLOSE DELETED BUFFERS---------------------------------------------------
vim.api.nvim_create_autocmd("FocusGained", {
	desc = "User: Close all non-existing buffers on `FocusGained`.",
	callback = function()
		local allBufs = vim.fn.getbufinfo { buflisted = 1 }
		local closedBuffers = vim.iter(allBufs):fold({}, function(acc, buf)
			if not vim.api.nvim_buf_is_valid(buf.bufnr) then return acc end
			local stillExists = vim.uv.fs_stat(buf.name) ~= nil
			local specialBuffer = vim.bo[buf.bufnr].buftype ~= ""
			local newBuffer = buf.name == ""
			if stillExists or specialBuffer or newBuffer then return acc end
			table.insert(acc, vim.fs.basename(buf.name))
			vim.api.nvim_buf_delete(buf.bufnr, { force = false })
			return acc
		end)
		if #closedBuffers == 0 then return end

		if #closedBuffers == 1 then
			vim.notify(closedBuffers[1], nil, { title = "Buffer closed", icon = "󰅗" })
		else
			local text = "- " .. table.concat(closedBuffers, "\n- ")
			vim.notify(text, nil, { title = "Buffers closed", icon = "󰅗" })
		end

		-- If ending up in empty buffer, re-open the first oldfile that exists
		vim.schedule(function()
			if vim.api.nvim_buf_get_name(0) ~= "" then return end
			for _, file in ipairs(vim.v.oldfiles) do
				if vim.uv.fs_stat(file) and vim.fs.basename(file) ~= "COMMIT_EDITMSG" then
					vim.cmd.edit(file)
					return
				end
			end
		end)
	end,
})

---AUTO-NOHL & INLINE SEARCH COUNT----------------------------------------------

do
	local config = {
		scrollbarWidth = 3, -- e.g., from satellite.nvim
		ignoredPrevNormalModeKeys = { "g", vim.g.mapleader }, -- don't trigger for `gn` or `<leader>n`
	}
	local prevKey

	---tip: use `vim.opt.shortmess:append("S")` to silence regular search count
	---@param mode? "clear"
	local function searchCountIndicator(mode)
		local countNs = vim.api.nvim_create_namespace("searchCounter")
		vim.api.nvim_buf_clear_namespace(0, countNs, 0, -1)
		if mode == "clear" then return end

		local row = vim.api.nvim_win_get_cursor(0)[1]
		local count = vim.fn.searchcount()
		if vim.tbl_isempty(count) or count.total == 0 then return end
		local text = (" %d/%d "):format(count.current, count.total)
		local line = vim.api.nvim_get_current_line():gsub("\t", (" "):rep(vim.bo.shiftwidth))
		local signcolumn = tonumber(vim.wo.signcolumn:match("%d+") or "0") * 2
		local viewportWidth = vim.api.nvim_win_get_width(0) - signcolumn - config.scrollbarWidth
		local lineFull = #line + #text > viewportWidth
		local margin = { lineFull and (" "):rep(config.scrollbarWidth) or "" }

		vim.api.nvim_buf_set_extmark(0, countNs, row - 1, 0, {
			virt_text = { { text, "IncSearch" }, margin },
			virt_text_pos = lineFull and "right_align" or "eol",
			priority = 49, -- so it comes in front of `nvim-lsp-endhints`
		})
	end

	-- without the `searchCountIndicator`, this `on_key` simply does `auto-nohl`
	vim.on_key(function(key, typed)
		local ignore = vim.tbl_contains(config.ignoredPrevNormalModeKeys, prevKey)
		prevKey = typed
		if ignore then return end

		key = vim.fn.keytrans(key)
		local isCmdlineSearch = vim.fn.getcmdtype():find("[/?]") ~= nil
		local isNormalMode = vim.api.nvim_get_mode().mode == "n"
		local searchStarted = (key == "/" or key == "?") and isNormalMode
		local searchConfirmed = (key == "<CR>" and isCmdlineSearch)
		local searchCancelled = (key == "<Esc>" and isCmdlineSearch)
		if not (searchStarted or searchConfirmed or searchCancelled or isNormalMode) then return end

		-- works for RHS, therefore no need to consider remaps
		local searchMovement = vim.tbl_contains({ "n", "N", "*", "#" }, key)

		if searchCancelled or (not searchMovement and not searchConfirmed) then
			vim.opt.hlsearch = false
			searchCountIndicator("clear")
		elseif searchMovement or searchConfirmed or searchStarted then
			vim.opt.hlsearch = true
			vim.defer_fn(searchCountIndicator, 1)
		end
	end, vim.api.nvim_create_namespace("autoNohlAndSearchCount"))
end

---TEMPLATES--------------------------------------------------------------------
local templateConfig = {
	templateDir = vim.fn.stdpath("config") .. "/templates",
	ignoreDirs = { vim.fn.stdpath("data") },
	globToTemplateMap = {
		[vim.fn.stdpath("config") .. "/lua/plugin-specs/**/*.lua"] = "plugin-spec.lua",
		[vim.fn.stdpath("config") .. "/lsp/*.lua"] = "lsp-server-config.lua",
		["**/*.lua"] = "module.lua",

		["**/*.py"] = "template.py",
		["**/*.scm"] = "template.scm",
		["**/*.swift"] = "template.swift",
		["**/*.{sh,zsh}"] = "template.zsh",
		["**/zsh/utilities/*"] = "template.zsh",
		["**/*.applescript"] = "template.applescript",

		["**/*.mjs"] = "node-module.mjs",
		["**/Alfred.alfredpreferences/workflows/**/*.js"] = "jxa.js",
		["**/Justfile"] = "justfile.just",
		["**/.github/workflows/*.{yml,yaml}"] = "github-action.yaml",

		[vim.g.notesDir .. "/**/*.md"] = "note.md",
	},
}

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
	-- `BufReadPost` for files created outside of nvim.
	desc = "User: Apply templates",
	callback = function(ctx)
		vim.defer_fn(function() -- defer, to ensure new files are written
			local stats = vim.uv.fs_stat(ctx.file)
			if not stats or stats.size > 10 then return end -- 10 bytes for file metadata
			local filepath, bufnr = ctx.file, ctx.buf
			local conf = templateConfig
			local ignore = vim.iter(conf.ignoreDirs)
				:any(function(dir) return vim.startswith(filepath, dir) end)
			if ignore then return end

			-- determine template from glob
			local longestMatchingGlob = vim.iter(conf.globToTemplateMap)
				:filter(function(glob) return vim.glob.to_lpeg(glob):match(filepath) end)
				:fold("", function(longGlob, glob) return #longGlob < #glob and glob or longGlob end)
			if longestMatchingGlob == "" then return end
			local templateFile = conf.globToTemplateMap[longestMatchingGlob]
			local templatePath = vim.fs.normalize(conf.templateDir .. "/" .. templateFile)

			-- read template
			local file = io.open(templatePath, "r")
			if not file then return end
			local content = file:read("*a")
			vim.snippet.expand(content) -- expands placeholders like `$0`

			-- adjust filetype if needed (e.g. when applying a zsh template to .sh files)
			local newFt = vim.filetype.match { buf = bufnr }
			if newFt and vim.bo[bufnr].ft ~= newFt then vim.bo[bufnr].ft = newFt end
		end, 100)
	end,
})

---ENFORCE SCROLLOFF AT EOF-----------------------------------------------------
-- simplified version of https://github.com/Aasim-A/scrollEOF.nvim
vim.api.nvim_create_autocmd({ "CursorMoved", "BufReadPost" }, {
	desc = "User: Enforce scrolloff at EoF",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype ~= "" then return end

		local winHeight = vim.api.nvim_win_get_height(0)
		local visualDistanceToEof = winHeight - vim.fn.winline()
		local scrolloff = math.min(vim.o.scrolloff, math.floor(winHeight / 2))

		if visualDistanceToEof < scrolloff then
			local topline = vim.fn.winsaveview().topline
			-- topline is inaccurate if it is a folded line, thus add number of folded lines
			local toplineFoldAmount = vim.fn.foldclosedend(topline) - vim.fn.foldclosed(topline)
			topline = topline + toplineFoldAmount
			vim.fn.winrestview { topline = topline + scrolloff - visualDistanceToEof }
		end
	end,
})

-- FIX for some reason `scrolloff` sometimes being set to `0` on new buffers!?
local originalScrolloff = vim.o.scrolloff
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNew" }, {
	desc = "User: FIX scrolloff on entering new buffer",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype == "" then vim.opt.scrolloff = originalScrolloff end
	end,
})

---FAVICON PREFIXES FOR URLS----------------------------------------------------
-- Requirements
-- 1. nvim 0.10+
-- 2. `comment` Tresitter parser (`:TSInstall comment`) & active parser for the
-- current buffer (e.g., in a lua buffer, the lua parser is required)
-- 3. Nerdfont glyphs

local favicons = {
	apple = "",
	github = "",
	google = "",
	microsoft = "",
	neovim = "",
	openai = "",
	reddit = "",
	stackoverflow = "󰓌",
	ycombinator = "",
}

local function addFavicons(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end
	if not bufnr then bufnr = 0 end

	local ns = vim.api.nvim_create_namespace("url-favicons")
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	local hasCommentParser, urlQuery =
		pcall(vim.treesitter.query.parse, "comment", "(uri) @string.special.url")
	if not (hasCommentParser and urlQuery) then return end
	local hasParserForFt, langTree = pcall(vim.treesitter.get_parser, bufnr)
	if not (hasParserForFt and langTree) then return end

	langTree:for_each_tree(function(tree, _)
		local commentUrlNodes = urlQuery:iter_captures(tree:root(), bufnr)
		vim.iter(commentUrlNodes):each(function(_, node)
			local nodeText = vim.treesitter.get_node_text(node, bufnr)
			local sitename = nodeText:match("(%w+)%.com") or nodeText:match("(%w+)%.io")
			local icon = favicons[sitename]
			if not icon then return end

			local row, col = node:start()
			vim.api.nvim_buf_set_extmark(bufnr, ns, row, col, {
				virt_text = { { icon .. " ", "Comment" } },
				virt_text_pos = "inline",
			})
		end)
	end)
end

vim.api.nvim_create_autocmd({ "FocusGained", "BufReadPost", "TextChanged", "InsertLeave" }, {
	desc = "User: Add favicons to URLs",
	callback = function(ctx)
		local delay = ctx.event == "BufReadPost" and 300 or 0 -- wait for treesitter, for some reason
		vim.defer_fn(function() addFavicons(ctx.buf) end, delay)
	end,
})

---LUCKY INDENT-----------------------------------------------------------------
-- Auto-set indent based on first indented line. Ignores files when an
-- `.editorconfig` is in effect. Simplified version of `guess-indent.nvim`.

local function luckyIndent(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end

	-- don't apply if .editorconfig is in effect
	local ec = vim.b[bufnr].editorconfig
	if ec and (ec.indent_style or ec.indent_size or ec.tab_width) then return end

	-- guess indent from first indented line
	local indent
	local maxToCheck = math.min(30, vim.api.nvim_buf_line_count(bufnr))
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, maxToCheck, false)
	for lnum = 1, #lines do
		-- require at least two spaces to avoid jsdoc setting indent to 1, etc.
		indent = lines[lnum]:match("^  +") or lines[lnum]:match("^\t*")
		if #indent > 0 then break end
	end
	if not indent then return end
	local spaces = indent:match(" +")
	if vim.bo[bufnr].ft == "markdown" then
		if not spaces then return end -- no indented line
		if #spaces == 2 then return end -- 2 space indents from hardwrap, not real indent
	end

	-- apply if needed
	local opts = { title = "Lucky indent", icon = "󰉶" }
	if spaces and (not vim.bo.expandtab or vim.bo[bufnr].shiftwidth ~= #spaces) then
		vim.bo[bufnr].expandtab = true
		vim.bo[bufnr].shiftwidth = #spaces
		vim.notify_once(("Set indentation to %d spaces."):format(#spaces), nil, opts)
	elseif not spaces and vim.bo.expandtab then
		vim.bo[bufnr].expandtab = false
		vim.notify_once("Set indentation to tabs.", nil, opts)
	end
end

vim.api.nvim_create_autocmd("BufReadPost", {
	desc = "User: lucky indent",
	callback = function(ctx)
		vim.defer_fn(function() luckyIndent(ctx.buf) end, 100)
	end,
})

---QUICKFIX SIGNS---------------------------------------------------------------
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	desc = "User: Add signs to quickfix (1/2)",
	callback = function()
		local ns = vim.api.nvim_create_namespace("quickfix-signs")

		local function setSigns(qf)
			pcall(vim.api.nvim_buf_set_extmark, qf.bufnr, ns, qf.lnum - 1, 0, {
				sign_text = "▶",
				sign_hl_group = "DiagnosticSignInfo",
				priority = 200, -- above most signs
				invalidate = true, -- deletes the extmark if the line is deleted
				undo_restore = true, -- makes undo restore them
			})
		end

		-- clear existing signs/autocmds
		local group = vim.api.nvim_create_augroup("quickfix-signs", { clear = true })
		vim.iter(vim.api.nvim_list_bufs())
			:each(function(bufnr) vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) end)

		-- set signs
		for _, qf in pairs(vim.fn.getqflist()) do
			if vim.api.nvim_buf_is_loaded(qf.bufnr) then
				setSigns(qf)
			else
				vim.api.nvim_create_autocmd("BufReadPost", {
					desc = "User(once): Add signs to quickfix (2/2)",
					group = group,
					once = true,
					buffer = qf.bufnr,
					callback = function() setSigns(qf) end,
				})
			end
		end
	end,
})

---ADD NOTIFICATION TO LSP RENAME-----------------------------------------------
local originalRenameHandler = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
	originalRenameHandler(err, result, ctx, config)
	if err or not result then return end

	-- count changes
	local changedFiles, changeCount = {}, 0
	if result.changes then
		changedFiles = vim.iter(vim.tbl_keys(result.changes))
			:map(function(uri) return "- " .. vim.fs.basename(vim.uri_to_fname(uri)) end)
			:totable()
		changeCount = vim.iter(result.changes)
			:fold(0, function(sum, _, ch) return sum + #(ch.edits or ch) end)
	elseif result.documentChanges then
		changedFiles = vim.iter(result.documentChanges)
			:map(function(file)
				local uri = file.textDocument and file.textDocument.uri or file.newUri
				local extra = file.kind == "rename" and " (renamed)" or ""
				return "* " .. vim.fs.basename(vim.uri_to_fname(uri)) .. extra
			end)
			:totable()
		changeCount = vim.iter(result.documentChanges)
			:fold(0, function(sum, ch) return sum + (ch.edits and #ch.edits or 1) end)
	end
	assert(changeCount > 0, "Unknown form of changes reported by LSP.")

	-- notification
	local pluralS = changeCount > 1 and "s" or ""
	local msg = ("[%d] change%s"):format(changeCount, pluralS)
	if #changedFiles > 1 then
		local fileList = table.concat(changedFiles, "\n")
		msg = ("**%s in [%d] files**\n%s"):format(msg, #changedFiles, fileList)
	end
	vim.notify(msg, nil, { title = "Renamed with LSP", icon = "󰑕" })

	-- save all
	if #changedFiles > 1 then vim.cmd("silent! wall") end
end

---ADD SOUND TO MACROS----------------------------------------------------------
if jit.os == "OSX" then
	local function playSound(file)
		local soundDir =
			"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/"
		vim.system { "afplay", "--volume", "0.5", soundDir .. file }
	end
	vim.api.nvim_create_autocmd("RecordingEnter", {
		desc = "User: Macro recording utilities (1/2)",
		callback = function() playSound("begin_record.caf") end, -- typos: ignore-line
	})
	vim.api.nvim_create_autocmd("RecordingLeave", {
		desc = "User: Macro recording utilities (2/2)",
		callback = function() playSound("end_record.caf") end, -- typos: ignore-line
	})
end
--------------------------------------------------------------------------------
