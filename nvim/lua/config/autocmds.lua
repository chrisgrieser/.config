local u = require("config.utils")

--------------------------------------------------------------------------------
-- AUTO-SAVE
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
	callback = function(ctx)
		local bufnr = ctx.buf
		local bo = vim.bo[bufnr]
		local b = vim.b[bufnr]
		if bo.buftype ~= "" or bo.ft == "gitcommit" or bo.readonly then return end
		if b.saveQueued and ctx.event ~= "FocusLost" then return end

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
local autoCdConfig = {
	childOfRoot = {
		".git",
		"Justfile",
		"info.plist", -- Alfred workflows
	},
	parentOfRoot = {
		".config",
		".obsidian", -- internal Obsidian folder
		"com~apple~CloudDocs", -- macOS iCloud
		"Cellar", -- opt/homebrew/Cellar/neovim
	},
}
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(ctx)
		local root = vim.fs.root(ctx.buf, function(name, path)
			local dirHasChildMarker = vim.tbl_contains(autoCdConfig.childOfRoot, name)
			local parentName = vim.fs.basename(vim.fs.dirname(path))
			local dirHasParentMarker = vim.tbl_contains(autoCdConfig.parentOfRoot, parentName)
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
			u.notify("󰅗 Buffer closed", closedBuffers[1])
		else
			local text = "- " .. table.concat(closedBuffers, "\n- ")
			u.notify("󰱝 Buffers closed", text)
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

-- AUTO-NOHL & INLINE SEARCH COUNT
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

	local countNs = vim.api.nvim_create_namespace("searchCounter")
	vim.api.nvim_buf_clear_namespace(0, countNs, 0, -1)

	if (searchCancelled or not searchMovement) and not searchConfirmed then
		vim.opt.hlsearch = false
	elseif searchMovement or searchConfirmed or searchStarted then
		vim.opt.hlsearch = true

		-- CONFIG
		local signColumnPlusScrollbarWidth = 2 + 3

		vim.defer_fn(function()
			local row = vim.api.nvim_win_get_cursor(0)[1]
			local count = vim.fn.searchcount()
			if count.total == 0 then return end
			local text = (" %s/%s "):format(count.current, count.total)
			local line = vim.api.nvim_get_current_line():gsub("\t", (" "):rep(vim.bo.shiftwidth)) -- ffff
			local lineFull = #line + signColumnPlusScrollbarWidth >= vim.api.nvim_win_get_width(0)
			local margin = { (" "):rep(lineFull and signColumnPlusScrollbarWidth or 0), "None" }

			vim.api.nvim_buf_set_extmark(0, countNs, row - 1, 0, {
				virt_text = { { text, "IncSearch" }, margin },
				virt_text_pos = lineFull and "right_align" or "eol",
				priority = 200, -- so it comes in front of lsp-endhints
			})
		end, 1)
	end
end, vim.api.nvim_create_namespace("autoNohlAndSearchCount"))

--------------------------------------------------------------------------------
-- FAVICONS PREFIXES FOR URLS

-- REQUIRED
-- comment parser (`:TSInstall comment`)
-- active parser for the current buffer (e.g., in a lua buffer, the lua parser is required)
-- Recommended: Nerdfont icon

local favicons = {
	hlGroup = "Comment",
	icons = {
		["github.com"] = " ",
		["neovim.io"] = "",
		["stackoverflow.com"] = "󰓌 ",
		["youtube.com"] = " ",
		["discord.com"] = "󰙯 ",
		["slack.com"] = " ",
		["new.reddit.com"] = " ",
		["www.reddit.com"] = " ",
	},
}

local function addFavicons(ctx)
	local hasCommentsParser, urlCommentsQuery =
		pcall(vim.treesitter.query.parse, "comment", "(uri) @string.special.url")
	if not hasCommentsParser then return end

	local bufnr = ctx and ctx.buf or 0
	local urlNodes = {}
	local faviconNs = vim.api.nvim_create_namespace("favicon")

	vim.defer_fn(function() -- deferred, so treesitter parser is ready
		local hasParserForFt, ltree = pcall(vim.treesitter.get_parser, bufnr)
		if not hasParserForFt then return end

		vim.api.nvim_buf_clear_namespace(bufnr, faviconNs, 0, -1)

		ltree:for_each_tree(function(tstree, _)
			local commentUrlNodes = urlCommentsQuery:iter_captures(tstree:root(), bufnr)
			for _, node in commentUrlNodes do
				table.insert(urlNodes, node)
			end
		end)
		vim.iter(urlNodes):each(function(node)
			local nodeText = vim.treesitter.get_node_text(node, bufnr)
			local host = nodeText:match("^https?://([^/]+)")
			local icon = favicons.icons[host]
			if not icon then return end

			local startRow, startCol = vim.treesitter.get_node_range(node)
			vim.api.nvim_buf_set_extmark(bufnr, faviconNs, startRow, startCol, {
				virt_text = { { icon, favicons.hlGroup } },
				virt_text_pos = "inline",
			})
		end)
	end, 1)
end
vim.api.nvim_create_autocmd(
	{ "BufEnter", "TextChanged", "InsertLeave" },
	{ callback = addFavicons }
)
addFavicons() -- initialize on current buffer

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

		-- move to 1st item
		pcall(vim.cmd.cfirst) -- (`pcall` as deleting the list also triggers `QuickFixCmdPost`)

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
-- GIT CONFLICT MARKERS
-- if there are conflicts, jump to first conflict, highlight conflict markers,
-- and disable diagnostics (simplified version of `git-conflict.nvim`)
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	callback = function(ctx)
		local hlgroup = "DiagnosticVirtualTextInfo" -- CONFIG

		if not vim.api.nvim_buf_is_valid(ctx.buf) then return end
		vim.system(
			{ "git", "diff", "--check", "--", vim.api.nvim_buf_get_name(ctx.buf) },
			{},
			vim.schedule_wrap(function(out)
				local noConflicts = out.code == 0
				local noGitRepo = vim.startswith(out.stdout, "warning: Not a git repository")
				if noConflicts or noGitRepo then return end

				local ns = vim.api.nvim_create_namespace("conflictMarkers")
				local firstConflict
				for conflictLnum in out.stdout:gmatch("(%d+): leftover conflict marker") do
					local lnum = tonumber(conflictLnum)
					vim.api.nvim_buf_add_highlight(ctx.buf, ns, hlgroup, lnum - 1, 0, -1)
					if not firstConflict then firstConflict = lnum end
				end
				if not firstConflict then return end

				vim.api.nvim_win_set_cursor(0, { firstConflict, 0 })
				vim.diagnostic.enable(false, { bufnr = ctx.buf })
				vim.notify_once("Conflict markers found.", nil, { title = "Git Conflicts" })
			end)
		)
	end,
})
