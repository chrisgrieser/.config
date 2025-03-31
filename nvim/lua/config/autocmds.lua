-- SYNC TERMINAL BACKGROUND
-- https://github.com/neovim/neovim/issues/16572#issuecomment-1954420136
-- https://new.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
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
-- RESTORE CURSOR
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Restore cursor position",
	callback = function(ctx)
		if ctx.match == "gitcommit" or vim.bo[ctx.buf].buftype ~= "" then return end
		vim.cmd.normal { 'g`"', bang = true }
	end,
})

--------------------------------------------------------------------------------

-- AUTO-CLEANUP
vim.api.nvim_create_autocmd("FocusLost", {
	desc = "User: Auto-cleanup. Once a week, on first `FocusLost`, delete older files.",
	once = true,
	callback = function()
		if os.date("%a") ~= "Mon" or jit.os == "windows" then return end
		vim.system { "find", vim.o.undodir, "-mtime", "+15d", "-delete" }
		vim.system { "find", vim.lsp.log.get_filename(), "-size", "+50M", "-delete" }
	end,
})

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
		"Cellar", -- homebrew stuff
	},
}
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	-- also trigger on `FocusGained` to account for deletions of file outside nvim
	desc = "User: Auto-cd to project root",
	callback = function(ctx)
		if not vim.uv.cwd() then vim.uv.chdir("/") end -- prevent error when no cwd

		local root = vim.fs.root(ctx.buf, function(name, path)
			local parentName = vim.fs.basename(vim.fs.dirname(path))
			local dirHasParentMarker = vim.tbl_contains(autoCdConfig.parentOfRoot, parentName)
			local dirHasChildMarker = vim.tbl_contains(autoCdConfig.childOfRoot, name)
			return dirHasChildMarker or dirHasParentMarker
		end)
		if root and root ~= "" then vim.uv.chdir(root) end
	end,
})

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
-- AUTO-NOHL & INLINE SEARCH COUNT

---@param mode? "clear"
local function searchCountIndicator(mode)
	local signColumnPlusScrollbarWidth = 2 + 3 -- CONFIG

	local countNs = vim.api.nvim_create_namespace("searchCounter")
	vim.api.nvim_buf_clear_namespace(0, countNs, 0, -1)
	if mode == "clear" then return end

	local row = vim.api.nvim_win_get_cursor(0)[1]
	local count = vim.fn.searchcount()
	if count.total == 0 then return end
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
	[vim.g.localRepos .. "/**/*.lua"] = "module.lua",
	[vim.fn.stdpath("config") .. "/lua/personal-plugins/*.lua"] = "module.lua",
	[vim.fn.stdpath("config") .. "/lua/plugin-specs/*.lua"] = "plugin-spec.lua",
	["**/hammerspoon/modules/*.lua"] = "module.lua",

	["**/*.py"] = "template.py",
	["**/*.sh"] = "template.zsh",
	["**/*.*sh"] = "template.zsh",
	["**/*.applescript"] = "template.applescript",

	["**/*.mjs"] = "node-module.mjs",
	["**/Alfred.alfredpreferences/workflows/**/*.js"] = "jxa.js",

	["**/Justfile"] = "justfile.just",
	["**/*typos.toml"] = "typos.toml",
	["**/.github/workflows/**/*.y*ml"] = "github-action.yaml",
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
			local matchedGlob = vim.iter(globToTemplateMap):find(function(glob)
				local globMatchesFilename = vim.glob.to_lpeg(glob):match(filepath)
				return globMatchesFilename
			end)
			if not matchedGlob then return end
			local templateFile = globToTemplateMap[matchedGlob]
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
					cursor = { row, placeholderPos - 1 }
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
vim.defer_fn(function() -- defer to prevent unneeded trigger on startup
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNew" }, {
		desc = "User: FIX scrolloff on entering new buffer",
		callback = function(ctx)
			if vim.bo[ctx.buf].buftype ~= "" then return end
			vim.opt.scrolloff = originalScrolloff
		end,
	})
end, 1)

--------------------------------------------------------------------------------
-- FAVICON PREFIXES FOR URLS
-- inspired by the Obsidian favicon plugin: https://github.com/joethei/obsidian-link-favicon

-- REQUIRED
-- 1. nvim 0.10+
-- 2. `comment` Tresitter parser (`:TSInstall comment`) & active parser for the
-- current buffer (e.g., in a lua buffer, the lua parser is required)
-- 3. Nerdfont icons

local favicons = {
	github = "",
	neovim = "",
	stackoverflow = "󰓌",
	discord = "󰙯",
	slack = "",
	reddit = "",
}

local function addFavicons(bufnr)
	-- GUARD
	if not bufnr then bufnr = 0 end
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end
	local hasParser, urlQuery =
		pcall(vim.treesitter.query.parse, "comment", "(uri) @string.special.url")
	if not hasParser then return end
	local hasParserForFt, _ = pcall(vim.treesitter.get_parser, bufnr)
	if not hasParserForFt then return end

	local ns = vim.api.nvim_create_namespace("url-favicons")
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	local langTree = vim.treesitter.get_parser(bufnr)
	if not langTree then return end
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
-- deferred so treesitter is ready
vim.api.nvim_create_autocmd({ "FocusGained", "BufReadPost", "TextChanged", "InsertLeave" }, {
	desc = "User: Add favicons to urls",
	callback = function(ctx)
		local delay = ctx.event == "BufReadPost" and 200 or 0
		vim.defer_fn(function() addFavicons(ctx.buf) end, delay)
	end,
})
vim.defer_fn(addFavicons, 200)

--------------------------------------------------------------------------------

-- LUCKY INDENT
-- Auto-set indent based on first indented line. Ignores files when an
-- `.editorconfig` is in effect. Simplified version of `guess-indent.nvim`.
local function luckyIndent(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then return end
	local ec = vim.b[bufnr].editorconfig
	if ec and (ec.indent_style or ec.indent_size or ec.tab_width) then return end
	if vim.bo[bufnr].buftype ~= "" then return end

	-- guess indent from first indented line
	local indent
	local lnum = 1
	local maxToCheck = math.min(100, vim.api.nvim_buf_line_count(bufnr))
	repeat
		local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
		indent = line:match("^%s*")
		lnum = lnum + 1
		if lnum > maxToCheck then return end
	until #indent > 0
	local spaces = indent:match(" +")

	-- apply
	if spaces then
		vim.bo.expandtab = true
		vim.bo.tabstop = #spaces
		vim.bo.shiftwidth = #spaces
	else
		vim.bo.expandtab = false
	end
	local msg = spaces and ("%s spaces"):format(#spaces) or "tabs"
	vim.notify("Set to " .. msg, nil, { title = "Lucky indent", icon = "󰉶" })
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
			vim.api.nvim_buf_set_extmark(qf.bufnr, ns, qf.lnum - 1, 0, {
				sign_text = "󱘹▶", -- actually two chars
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
-- LSP RENAME – ADD NOTIFICATION
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
	local changeCount = 0
	for _, change in pairs(changes) do
		changeCount = changeCount + #(change.edits or change)
	end

	-- notification
	local pluralS = changeCount > 1 and "s" or ""
	local msg = ("[%d] instance%s"):format(changeCount, pluralS)
	if #changedFiles > 1 then
		local fileList = table.concat(changedFiles, "\n")
		msg = ("**%s in [%d] files**\n%s"):format(msg, #changedFiles, fileList)
	end
	vim.notify(msg, nil, { title = "Renamed with LSP", icon = "󰑕" })

	-- save all
	if #changedFiles > 1 then vim.cmd.wall() end
end
--------------------------------------------------------------------------------
-- SPLITS
vim.api.nvim_create_autocmd("VimResized", {
	desc = "User: keep splits equally sized on window resize",
	command = "wincmd =",
})
