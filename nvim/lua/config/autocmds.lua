-- SYNC TERMINAL BACKGROUND
-- SOURCE https://github.com/neovim/neovim/issues/16572#issuecomment-1954420136
-- https://new.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
if vim.fn.has("gui_running") == 0 then
	local termBgModified = false
	vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
		callback = function()
			local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
			if normal.bg then
				io.write(string.format("\027]11;#%06x\027\\", normal.bg))
				termBgModified = true
			end
		end,
	})

	vim.api.nvim_create_autocmd("UILeave", {
		callback = function()
			if termBgModified then io.write("\027]111\027\\") end
		end,
	})
end

--------------------------------------------------------------------------------

-- AUTO-CLEANUP
-- -> once a week, on first `FocusLost`, delete older files
vim.api.nvim_create_autocmd("FocusLost", {
	once = true,
	callback = function()
		if os.date("%a") ~= "Mon" then return end
		vim.system { "find", vim.opt.viewdir:get(), "-mtime", "+30d", "-delete" }
		vim.system { "find", vim.opt.undodir:get()[1], "-mtime", "+14d", "-delete" }
	end,
})

--------------------------------------------------------------------------------

-- AUTO-SAVE
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
	callback = function(ctx)
		local bufnr = ctx.buf
		local bo = vim.bo[bufnr]
		local b = vim.b[bufnr]
		if bo.buftype ~= "" or bo.ft == "gitcommit" or bo.readonly then return end
		if b.saveQueued then return end

		local saveInstantly = ctx.event == "FocusLost" or ctx.event == "BufLeave"
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
		"biome.jsonc", -- biome
	},
	parentOfRoot = {
		".config",
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
		if root and root ~= "" then vim.uv.chdir(root) end
	end,
})

--------------------------------------------------------------------------------

-- Close all non-existing buffers on `FocusGained`
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
				vim.api.nvim_buf_delete(bufnr, { force = false })
			end)
		if #closedBuffers == 0 then return end

		if #closedBuffers == 1 then
			vim.notify(closedBuffers[1], nil, { title = "󰅗 Buffer closed" })
		else
			local text = "- " .. table.concat(closedBuffers, "\n- ")
			vim.notify(text, nil, { title = "󰅗 Buffers closed" })
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
		end, 200)
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
	[vim.g.localRepos .. "/**/lua/**/*.lua"] = "module.lua",
	[vim.fn.stdpath("config") .. "/lua/funcs/*.lua"] = "module.lua",
	["**/hammerspoon/modules/*.lua"] = "module.lua",

	["**/*.py"] = "template.py",
	["**/*.sh"] = "template.zsh",
	["**/*.applescript"] = "template.applescript",
	["**/*.mjs"] = "node-module.mjs",

	["**/Justfile"] = "justfile.just",
	["**/Alfred.alfredpreferences/workflows/**/*.js"] = "jxa.js",
	["**/*.jxa"] = "jxa.js",
	["**/*typos.toml"] = "typos.toml",
	["**/.github/workflows/**/*.y*ml"] = "github-action.yaml",
}

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
	-- `BufReadPost` for files created outside of nvim
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

-- QUICKFIX: Add signs
local quickfixSign = "" -- CONFIG
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	callback = function()
		local ns = vim.api.nvim_create_namespace("quickfixSigns")

		local function setSigns(qf)
			vim.api.nvim_buf_set_extmark(qf.bufnr, ns, qf.lnum - 1, qf.col - 1, {
				sign_text = quickfixSign,
				sign_hl_group = "DiagnosticSignInfo",
				priority = 200, -- Gitsigns uses 6 by default, we want to be above
				invalidate = true, -- deletes the extmark if the line is deleted
				undo_restore = true, -- makes undo restore those
			})
		end

		-- clear signs
		local group = vim.api.nvim_create_augroup("quickfixSigns", { clear = true })
		vim.iter(vim.api.nvim_list_bufs())
			:each(function(bufnr) vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) end)

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

-- QUICKFIX: Goto first item
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	-- `pcall` as event also triggered on empty quickfix, where `:cfirst` fails
	callback = function() pcall(vim.cmd.cfirst) end,
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
