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
			local parentName = vim.fs.basename(vim.fs.dirname(path))
			local dirHasParentMarker = vim.tbl_contains(autoCdConfig.parentOfRoot, parentName)
			local dirHasChildMarker = vim.tbl_contains(autoCdConfig.childOfRoot, name)
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
				local doesNotExist = vim.uv.fs_stat(bufPath) == nil
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
		priority = 200, -- so it comes in front of lsp-endhints
	})
end

-- without the `searchCountIndicator`, this function simply does `auto-nohl`
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

	if (searchCancelled or not searchMovement) and not searchConfirmed then
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
	["**/lua/*.lua"] = "module.lua",
	[vim.g.localRepos .. "/**/lua/**/*.lua"] = "module.lua",
	["**/lua/funcs/*.lua"] = "module.lua",

	["**/*.py"] = "template.py",
	["**/*.sh"] = "template.zsh",
	["**/*.applescript"] = "template.applescript",
	["**/Alfred.alfredpreferences/workflows/**/*.js"] = "jxa.js",

	["**/*Justfile"] = "justfile.just",
	["**/*typos.toml"] = "typos.toml",
	["**/.github/workflows/**/*.y*ml"] = "github-action.yaml",
}

-- `BufNewFile` doesn't trigger on files created outside nvim
vim.api.nvim_create_autocmd("FileType", {
	callback = function(ctx)
		vim.defer_fn(function()
			-- GUARD
			local stats = vim.uv.fs_stat(ctx.file)
			if not stats or stats.size > 10 then return end -- 10 bytes for file metadata
			local filename = ctx.file
			vim.notify("👾 filename: " .. tostring(filename))

			-- determine template from glob
			local matchingGlob = vim.iter(globToTemplateMap):find(
				function(glob) return vim.glob.to_lpeg(glob):match(filename) end
			)
			if not matchingGlob then return end
			local ft = vim.bo.filetype
			if not ft or not globToTemplateMap[ft] then return end
			local templateFile = globToTemplateMap[matchingGlob]
			local templatePath = vim.fs.normalize(templateDir .. "/" .. templateFile)
			vim.notify("👾 templatePath: " .. tostring(templatePath))

			-- read template & look for cursor placeholder
			local lines = {}
			local cursor
			local row = 1
			for line in io.lines(templatePath) do
				local placeholderPos = line:find("%$0")
				if placeholderPos then
					line = line:gsub("%$0", "")
					cursor = { row, placeholderPos - 1 }
				end
				table.insert(lines, line)
				row = row + 1
			end

			-- write & set cursor
			vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
			if cursor then vim.api.nvim_win_set_cursor(0, cursor) end
		end, 100)
	end,
})

--------------------------------------------------------------------------------

-- QUICKFIX LIST: ADD SIGNS
local quickfixSign = "" -- CONFIG
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	callback = function()
		local ns = vim.api.nvim_create_namespace("quickfixSigns")

		local function setSigns(qf)
			vim.api.nvim_buf_set_extmark(qf.bufnr, ns, qf.lnum - 1, qf.col - 1, {
				sign_text = quickfixSign,
				sign_hl_group = "DiagnosticSignInfo",
				priority = 200, -- Gitsigns uses 6 by default, we want to be above
			})
		end

		-- move to 1st item
		pcall(vim.cmd.cfirst) -- `pcall` as deleting the list also triggers `QuickFixCmdPost`

		-- clear signs
		local group = vim.api.nvim_create_augroup("quickfixSigns", { clear = true })
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

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

		local bufnr = ctx.buf
		if not vim.api.nvim_buf_is_valid(bufnr) then return end

		vim.system(
			{ "git", "diff", "--check", "--", vim.api.nvim_buf_get_name(bufnr) },
			{},
			vim.schedule_wrap(function(out)
				local noConflicts = out.code == 0
				local notGitRepo = vim.startswith(out.stdout, "warning: Not a git repository")
				if noConflicts or notGitRepo then return end

				local ns = vim.api.nvim_create_namespace("conflictMarkers")
				local firstConflictLn
				for conflictLnum in out.stdout:gmatch("(%d+): leftover conflict marker") do
					local lnum = tonumber(conflictLnum)
					vim.api.nvim_buf_add_highlight(bufnr, ns, hlgroup, lnum - 1, 0, -1)
					if not firstConflictLn then firstConflictLn = lnum end
				end
				if not firstConflictLn then return end

				vim.api.nvim_win_set_cursor(0, { firstConflictLn, 0 })
				vim.diagnostic.enable(false, { bufnr = bufnr })
				vim.notify_once("Conflict markers found.", nil, { title = "Git Conflicts" })
			end)
		)
	end,
})
