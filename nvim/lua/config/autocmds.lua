-- SYNC TERMINAL BACKGROUND
-- SOURCE https://github.com/neovim/neovim/issues/16572#issuecomment-1954420136
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

-- AUTO-CLEANUP
vim.api.nvim_create_autocmd("FocusLost", {
	desc = "User: Auto-cleanup. Once a week, on first `FocusLost`, delete older files.",
	once = true,
	callback = function()
		if os.date("%a") ~= "Mon" or jit.os == "windows" then return end
		vim.system { "find", vim.o.viewdir, "-mtime", "+30d", "-delete" }
		vim.system { "find", vim.o.undodir, "-mtime", "+15d", "-delete" }
		vim.system { "find", vim.lsp.log.get_filename(), "-size", "+50M", "-delete" }
	end,
})

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
	desc = "User: Auto-save",
	callback = function(ctx)
		local saveInstantly = ctx.event == "FocusLost" or ctx.event == "BufLeave"
		local bufnr = ctx.buf
		local bo, b = vim.bo[bufnr], vim.b[bufnr]
		if bo.buftype ~= "" or bo.ft == "gitcommit" or bo.readonly then return end
		if b.saveQueued and not saveInstantly then return end

		b.saveQueued = true
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then return end
			-- `noautocmd` prevents weird cursor movement
			vim.api.nvim_buf_call(bufnr, function() vim.cmd("silent! noautocmd lockmarks update!") end)
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
		"Cellar", -- opt/homebrew/Cellar/neovim
	},
}
vim.api.nvim_create_autocmd("BufEnter", {
	desc = "User: Auto-cd to project root",
	callback = function(ctx)
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
	desc = "User: FIX cwd being not available when it is deleted outside nvim.",
	callback = function()
		if not vim.uv.cwd() then vim.uv.chdir("/") end
	end,
})

vim.api.nvim_create_autocmd("FocusGained", {
	desc = "User: Close all non-existing buffers on `FocusGained`.",
	callback = function()
		local closedBuffers = {}
		vim.iter(vim.api.nvim_list_bufs())
			:filter(function(bufnr)
				local valid = vim.api.nvim_buf_is_valid(bufnr)
				local loaded = vim.api.nvim_buf_is_loaded(bufnr)
				if not valid or not loaded then return false end
				local bufPath = vim.api.nvim_buf_get_name(bufnr)
				local doesNotExist = vim.uv.fs_stat(bufPath) == nil
				local notSpecialBuffer = vim.bo[bufnr].buftype == ""
				local notNewBuffer = bufPath ~= ""
				return doesNotExist and notSpecialBuffer and notNewBuffer
			end)
			:each(function(bufnr)
				local bufName = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
				table.insert(closedBuffers, bufName)
				vim.api.nvim_buf_delete(bufnr, { force = false })
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
vim.on_key(function(char)
	local key = vim.fn.keytrans(char)
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
	["**/hammerspoon/modules/*.lua"] = "module.lua",

	["**/*.py"] = "template.py",
	["**/*.sh"] = "template.zsh",
	["**/*.applescript"] = "template.applescript",
	["**/*.mjs"] = "node-module.mjs",

	["**/Justfile"] = "justfile.just",
	["**/Alfred.alfredpreferences/workflows/**/*.js"] = "jxa.js",
	["**/*typos.toml"] = "typos.toml",
	["**/.github/workflows/**/*.y*ml"] = "github-action.yaml",
}

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
	desc = "User: Apply templates (`BufReadPost` for files created outside of nvim.)",
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
			if vim.bo[bufnr].ft ~= newFt then vim.bo[bufnr].ft = newFt end
		end, 100)
	end,
})

--------------------------------------------------------------------------------
-- GIT CONFLICT MARKERS
-- if there are conflicts, jump to first conflict, highlight conflict markers,
-- and disable diagnostics (simplified version of `git-conflict.nvim`)
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	desc = "User: Git conflict markers",
	callback = function(ctx)
		local bufnr = ctx.buf
		if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end

		vim.system(
			{ "git", "diff", "--check", "--", vim.api.nvim_buf_get_name(bufnr) },
			{},
			vim.schedule_wrap(function(out)
				local noConflicts = out.code == 0
				local notGitRepo = vim.startswith(out.stdout, "warning: Not a git repository")
				if noConflicts or notGitRepo then return end

				local ns = vim.api.nvim_create_namespace("conflictMarkers")
				vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) -- make it idempotent

				local conflictLnums = {}
				for conflictLnum in out.stdout:gmatch("(%d+): leftover conflict marker") do
					table.insert(conflictLnums, tonumber(conflictLnum))
				end
				if #conflictLnums == 0 then return end
				for _, lnum in ipairs(conflictLnums) do
					local hlgroup = "DiagnosticVirtualTextInfo"
					vim.api.nvim_buf_add_highlight(bufnr, ns, hlgroup, lnum - 1, 0, -1)
				end

				vim.api.nvim_win_set_cursor(0, { conflictLnums[1], 0 })
				vim.diagnostic.enable(false, { bufnr = bufnr })
				local msg = ("%d conflict markers found."):format(#conflictLnums)
				vim.notify_once(msg, nil, { title = "Git conflicts", icon = "󰞇" })
			end)
		)
	end,
})
--------------------------------------------------------------------------------
-- ENFORCE SCROLLOFF AT EOF
-- simplified version of https://github.com/Aasim-A/scrollEOF.nvim

vim.api.nvim_create_autocmd("CursorMoved", {
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

-- FIX for some reason `scrolloff` sometimes being set to `0` on new buffers
local originalScrolloff = vim.o.scrolloff
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNew" }, {
	desc = "User: FIX scrolloff on entering new buffer",
	callback = function(ctx)
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(ctx.buf) or vim.bo[ctx.buf].buftype ~= "" then return end
			if vim.o.scrolloff == 0 then
				vim.o.scrolloff = originalScrolloff
				vim.notify("Triggered by [" .. ctx.event .. "]", nil, { title = "Scrolloff fix" })
			end
		end, 100)
	end,
})

--------------------------------------------------------------------------------
-- ADD SIGNS FOR RETURN STATEMENTS
vim.api.nvim_create_autocmd({ "BufReadPost", "TextChanged", "InsertLeave" }, {
	desc = "User: Add signs for return statements to the signcolumn",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype ~= "" then return end

		-- get return statement nodes
		local currentFt = vim.bo[ctx.buf].filetype
		local hasReturnStatement, query =
			pcall(vim.treesitter.query.parse, currentFt, [[((return_statement) @user.returns)]])
		if not hasReturnStatement then return end
		local rootTree = vim.treesitter.get_parser(0):parse()[1]:root()
		local allNodesIter = query:iter_captures(rootTree, 0)

		-- construct returns table
		local funcNodes = {
			"function_definition",
			"function_declaration",
			"method_definition",
			"method_declaration",
		}
		local funcs = {}

		local returns = vim.iter(allNodesIter)
			:map(function(_, node, _) ---@cast node TSNode
				local row, _, _ = node:start()
				local funcId
				repeat
					node = node:parent()
					if not node then funcId = "global_scope" end
					if node and vim.tbl_contains(funcNodes, node:type()) then funcId = node:id() end
				until funcId
				funcs[funcId] = (funcs[funcId] or 0) + 1
				return { row = row, number = funcs[funcId], funcId = funcId }
			end)
			:totable()

		-- set signs
		local ns = vim.api.nvim_create_namespace("return-signcolumn")
		vim.api.nvim_buf_clear_namespace(ctx.buf, ns, 0, -1)

		vim.iter(returns):each(function(node)
			if funcs[node.funcId] < 2 then return end -- only returns when more than 1 in func
			vim.api.nvim_buf_set_extmark(ctx.buf, ns, node.row, 0, {
				sign_text = "󰌑",
				sign_hl_group = "@keyword.return",
				priority = 10, -- Gitsigns uses 6
				strict = false,
			})
		end)
	end,
})

--------------------------------------------------------------------------------
-- FAVICON PREFIXES FOR URLS
-- inspired by the Obsidian favicon plugin:

-- REQUIRED
-- 1. comment parser (`:TSInstall comment`) and active parser for the current
-- buffer (e.g., in a lua buffer, the lua parser is required)
-- 2. Nerdfont icon

local faviconConfig = {
	hlGroup = "Comment",
	icons = {
		github = "",
		neovim = "",
		stackoverflow = "󰓌",
		discord = "󰙯",
		slack = "",
		reddit = "",
	},
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

	local ns = vim.api.nvim_create_namespace("favicon")
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	local langTree = vim.treesitter.get_parser(bufnr)
	langTree:for_each_tree(function(tree, _)
		local commentUrlNodes = urlQuery:iter_captures(tree:root(), bufnr)
		vim.iter(commentUrlNodes):each(function(_, node)
			local nodeText = vim.treesitter.get_node_text(node, bufnr)
			local sitename = nodeText:match("(%w+)%.com") or nodeText:match("(%w+)%.io")
			local icon = faviconConfig.icons[sitename]
			if not icon then return end

			local row, col = node:start()
			vim.api.nvim_buf_set_extmark(bufnr, ns, row, col, {
				virt_text = { { icon .. " ", faviconConfig.hlGroup } },
				virt_text_pos = "inline",
			})
		end)
	end)
end
-- deferred so treesitter is ready
vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, {
	desc = "User: Add favicons to urls",
	callback = function(ctx)
		vim.defer_fn(function() addFavicons(ctx.buf) end, 200)
	end,
})
vim.defer_fn(addFavicons, 200)
