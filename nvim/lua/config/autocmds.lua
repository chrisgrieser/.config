vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Highlighted Yank",
	callback = function() vim.hl.on_yank { timeout = 1500 } end,
})

vim.api.nvim_create_autocmd("VimResized", {
	desc = "User: keep splits equally sized on window resize",
	command = "wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Restore cursor position",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype ~= "" then return end
		vim.cmd([[silent! normal! g`"]])
	end,
})

--------------------------------------------------------------------------------

-- COLORSCHEMES DEPENDING ON SYSTEM MODE
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

--------------------------------------------------------------------------------

-- SYNC TERMINAL BACKGROUND
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
--------------------------------------------------------------------------------

-- AUTO-CLEANUP
if jit.os == "OSX" then
	vim.api.nvim_create_autocmd("FocusLost", {
		desc = "User: Auto-cleanup. Once a week, on first `FocusLost`, delete older files.",
		once = true,
		callback = function()
			if os.date("%a") == "Mon" then
				vim.system { "find", vim.o.undodir, "-mtime", "+15d", "-delete" }
				vim.system { "find", vim.lsp.log.get_filename(), "-size", "+20M", "-delete" }
			end
		end,
	})
end

--------------------------------------------------------------------------------
-- AUTO-SAVE

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
	desc = "User: Auto-save",
	callback = function(ctx)
		local saveInstantly = ctx.event == "FocusLost" or ctx.event == "BufLeave"
		local bufnr = ctx.buf
		local bo, b = vim.bo[bufnr], vim.b[bufnr]
		local bufname = ctx.file
		if bo.buftype ~= "" or bo.ft == "gitcommit" or bo.readonly then return end
		if b.saveQueued and not saveInstantly then return end

		b.saveQueued = true
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then return end

			vim.api.nvim_buf_call(bufnr, function()
				-- saving with explicit name prevents issues when changing `cwd`
				-- `:update!` suppresses "The file has been changed since reading it!!!"
				local vimCmd = ("silent! noautocmd lockmarks update! %q"):format(bufname)
				vim.cmd(vimCmd)
			end)
			b.saveQueued = false
		end, saveInstantly and 0 or 2000)
	end,
})

--------------------------------------------------------------------------------
-- AUTO-CD TO PROJECT ROOT
-- (simplified version of project.nvim)

do
	local autoCdConfig = {
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
			if not vim.uv.cwd() then vim.uv.chdir("/") end -- cwd unset of dir was deleted

			vim.schedule(function()
				-- GUARD
				if not vim.api.nvim_buf_is_valid(ctx.buf) then return end
				if vim.startswith(ctx.file, "/private/var/") then return end -- `pass` cli buffers

				local root = vim.fs.root(ctx.buf, function(name, path)
					local parentName = vim.fs.basename(vim.fs.dirname(path))
					local dirHasParentMarker = vim.tbl_contains(autoCdConfig.parentOfRoot, parentName)
					local dirHasChildMarker = vim.tbl_contains(autoCdConfig.childOfRoot, name)
					return dirHasChildMarker or dirHasParentMarker
				end)
				if root and root ~= "" then vim.uv.chdir(root) end
			end)
		end,
	})
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FocusGained", {
	desc = "User: Close all non-existing buffers on `FocusGained`.",
	callback = function()
		local closedBuffers = {}
		local allBufs = vim.fn.getbufinfo { buflisted = 1 }
		vim.iter(allBufs):each(function(buf)
			if not vim.api.nvim_buf_is_valid(buf.bufnr) then return end
			local stillExists = vim.uv.fs_stat(buf.name) ~= nil
			local specialBuffer = vim.bo[buf.bufnr].buftype ~= ""
			local newBuffer = buf.name == ""
			if stillExists or specialBuffer or newBuffer then return end
			table.insert(closedBuffers, vim.fs.basename(buf.name))
			vim.api.nvim_buf_delete(buf.bufnr, { force = false })
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

--------------------------------------------------------------------------------
-- AUTO-NOHL & INLINE SEARCH COUNT

---@param mode? "clear"
local function searchCountIndicator(mode)
	local signColumnPlusScrollbarWidth = 2 + 3 -- CONFIG

	local countNs = vim.api.nvim_create_namespace("searchCounter")
	vim.api.nvim_buf_clear_namespace(0, countNs, 0, -1)
	if mode == "clear" then return end

	local row = vim.api.nvim_win_get_cursor(0)[1]
	local count = vim.fn.searchcount()
	if vim.tbl_isempty(count) or count.total == 0 then return end
	local text = (" %d/%d "):format(count.current, count.total)
	local line = vim.api.nvim_get_current_line():gsub("\t", (" "):rep(vim.bo.shiftwidth))
	local lineFull = #line + signColumnPlusScrollbarWidth >= vim.api.nvim_win_get_width(0)
	local margin = { (" "):rep(lineFull and signColumnPlusScrollbarWidth or 0) }

	vim.api.nvim_buf_set_extmark(0, countNs, row - 1, 0, {
		virt_text = { { text, "IncSearch" }, margin },
		virt_text_pos = lineFull and "right_align" or "eol",
		priority = 200, -- so it comes in front of `nvim-lsp-endhints`
	})
end

-- without the `searchCountIndicator`, this `on_key` simply does `auto-nohl`
vim.on_key(function(key, _typed)
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

--------------------------------------------------------------------------------
-- SKELETONS (TEMPLATES)

-- CONFIG
local templateDir = vim.fn.stdpath("config") .. "/templates"
local globToTemplateMap = {
	[vim.fn.stdpath("config") .. "/lua/plugin-specs/**/*.lua"] = "plugin-spec.lua",
	[vim.fn.stdpath("config") .. "/lsp/*.lua"] = "lsp-server-config.lua",
	["**/*.lua"] = "module.lua",

	["**/*.py"] = "template.py",
	["**/*.swift"] = "template.swift",
	["**/*.{sh,zsh}"] = "template.zsh",
	["**/*.applescript"] = "template.applescript",

	["**/*.mjs"] = "node-module.mjs",
	["**/Alfred.alfredpreferences/workflows/**/*.js"] = "jxa.js",
	["**/Justfile"] = "justfile.just",
	["**/.github/workflows/*.{yml,yaml}"] = "github-action.yaml",
}

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
	-- `BufReadPost` for files created outside of nvim.
	desc = "User: Apply templates",
	callback = function(ctx)
		vim.defer_fn(function() -- defer, to ensure new files are written
			local stats = vim.uv.fs_stat(ctx.file)
			if not stats or stats.size > 10 then return end -- 10 bytes for file metadata
			local filepath, bufnr = ctx.file, ctx.buf

			-- determine template from glob
			local longestMatchingGlob = vim.iter(globToTemplateMap)
				:filter(function(glob) return vim.glob.to_lpeg(glob):match(filepath) end)
				:fold("", function(longGlob, glob) return #longGlob < #glob and glob or longGlob end)
			if longestMatchingGlob == "" then return end
			local templateFile = globToTemplateMap[longestMatchingGlob]
			local templatePath = vim.fs.normalize(templateDir .. "/" .. templateFile)
			if not vim.uv.fs_stat(templatePath) then return end

			-- read template & move to cursor placeholder
			local content = {}
			local cursor
			local row = 1
			for line in io.lines(templatePath) do
				local placeholderPos = line:find("%$0")
				if placeholderPos then
					line = line:gsub("%$0", "")
					local col = math.max(placeholderPos - 2, 0)
					cursor = { row, col }
				end
				table.insert(content, line)
				row = row + 1
			end
			vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
			if cursor then vim.api.nvim_win_set_cursor(0, cursor) end

			-- adjust filetype if needed (e.g. when applying a zsh template to .sh files)
			local newFt = vim.filetype.match { buf = bufnr }
			if newFt and vim.bo[bufnr].ft ~= newFt then vim.bo[bufnr].ft = newFt end
		end, 100)
	end,
})

--------------------------------------------------------------------------------
-- ENFORCE SCROLLOFF AT EOF
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

--------------------------------------------------------------------------------
-- FAVICON PREFIXES FOR URLS
-- inspired by the Obsidian favicon plugin: https://github.com/joethei/obsidian-link-favicon

-- REQUIREMENTS
-- 1. nvim 0.10+
-- 2. `comment` Tresitter parser (`:TSInstall comment`) & active parser for the
-- current buffer (e.g., in a lua buffer, the lua parser is required)
-- 3. Font with Nerdfont glyphs

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
	youtube = "",
}

local function addFavicons(bufnr)
	if not bufnr then bufnr = 0 end
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end
	local hasCommentParser, urlQuery =
		pcall(vim.treesitter.query.parse, "comment", "(uri) @string.special.url")
	if not hasCommentParser then return end
	local hasParserForFt, _ = pcall(vim.treesitter.get_parser, bufnr)
	if not hasParserForFt then return end

	local ns = vim.api.nvim_create_namespace("url-favicons")
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	local langTree = vim.treesitter.get_parser(bufnr)
	if not langTree then return end
	langTree:for_each_tree(function(tree, _)
		if not urlQuery.iter_captures then return end
		local commentUrlNodes = urlQuery:iter_captures(tree:root(), bufnr)
		vim.iter(commentUrlNodes):each(function(_, node)
			local nodeText = vim.treesitter.get_node_text(node, bufnr)
			local sitename = nodeText:match("(%w+)%.com") or nodeText:match("(%w+)%.io")
			local icon = favicons[sitename]
			if not icon then return end

			local row, col = node:start() ---@cast col integer
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

--------------------------------------------------------------------------------

-- LUCKY INDENT
-- Auto-set indent based on first indented line. Ignores files when an
-- `.editorconfig` is in effect. Simplified version of `guess-indent.nvim`.
local function luckyIndent(bufnr)
	local linesToCheck = 50
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end
	local ec = vim.b[bufnr].editorconfig
	if ec and (ec.indent_style or ec.indent_size or ec.tab_width) then return end

	-- guess indent from first indented line
	local indent
	local maxToCheck = math.min(linesToCheck, vim.api.nvim_buf_line_count(bufnr))
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, maxToCheck, false)
	for lnum = 1, #lines do
		indent = lines[lnum]:match("^%s*")
		if #indent > 0 then break end
	end
	local spaces = indent:match(" +")
	if vim.bo[bufnr].ft == "markdown" then
		if not spaces then return end -- no indented line
		if #spaces == 2 then return end -- 2 space indents from hardwrap, not real indent
	end

	-- apply if needed
	local opts = { title = "Lucky indent", icon = "󰉶" }
	if spaces and not vim.bo.expandtab then
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

--------------------------------------------------------------------------------
-- QUICKFIX ADD SIGNS

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

--------------------------------------------------------------------------------
-- ADD NOTIFICATION TO LSP RENAME
local originalRenameHandler = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
	originalRenameHandler(err, result, ctx, config)
	if err or not result then return end

	-- count changes
	local changes = result.changes or result.documentChanges or {}
	local changedFiles = vim.iter(vim.tbl_keys(changes))
		:filter(function(file) return #changes[file] > 0 end)
		:map(function(file) return "- " .. vim.fs.basename(file) end)
		:totable()
	local changeCount = vim.iter(changes)
		:fold(0, function(sum, _, change) return sum + #(change.edits or change) end)

	-- notification
	local pluralS = changeCount > 1 and "s" or ""
	local msg = ("[%d] instance%s"):format(changeCount, pluralS)
	if #changedFiles > 1 then
		local fileList = table.concat(changedFiles, "\n")
		msg = ("**%s in [%d] files**\n%s"):format(msg, #changedFiles, fileList)
	end
	vim.notify(msg, nil, { title = "Renamed with LSP", icon = "󰑕" })

	-- save all
	if #changedFiles > 1 then vim.cmd("silent! wall") end
end
--------------------------------------------------------------------------------

-- MACROS
-- add sound while recording
if jit.os == "OSX" then
	local function playSound(file)
		local soundDir =
			"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/"
		vim.system { "afplay", soundDir .. file }
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
