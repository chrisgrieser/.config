-- A bunch of commands that are too small to be published as plugins, but too
-- big to put in the main config, where they would crowd the actual
-- configuration. Every function is self-contained (except the helper
-- functions here), and should be binded to a keymap.
--------------------------------------------------------------------------------
local M = {}

---@param cmd string
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

---@param msg string
---@param title string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(title, msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = title })
end

--------------------------------------------------------------------------------

---Convenience wrapper around `:cdo` (simplified nvim-spectre)
function M.globalSubstitute()
	vim.ui.input({
		prompt = " Search Globally:",
		default = vim.fn.expand("<cword>"),
	}, function(input)
		if not input then return end

		-- search
		local ignoreCaseBefore = vim.o.ignorecase
		vim.o.ignorecase = false
		vim.cmd(("silent! vimgrep /%s/g **/*"):format(input)) -- vimgrep = internal search = no dependency

		-- replace
		vim.defer_fn(function()
			-- add title to quickfix
			vim.fn.setqflist({}, "a", { title = input })

			-- GUARD
			local qf = vim.fn.getqflist { items = true }
			if #qf.items == 0 then
				notify("Global Search", ("No match found for %q"):format(input), "warn")
				return
			end

			-- preview search results
			local height = math.min(20, #qf.items + 1)
			vim.cmd("copen " .. tostring(height))

			-- prefill & position cursor in cmdline
			local cmd = (":cdo s/%s//"):format(input)
			vim.api.nvim_feedkeys(cmd, "i", true)
			local left = vim.api.nvim_replace_termcodes("<Left>", true, false, true)
			vim.defer_fn(function() vim.api.nvim_feedkeys(left, "i", false) end, 100)

			-- leave cmdline
			vim.api.nvim_create_autocmd("CmdlineLeave", {
				once = true,
				callback = function()
					vim.defer_fn(function()
						vim.cmd.cclose()
						vim.cmd.cfirst() -- move cursor back
						vim.cmd.cexpr("[]") -- clear quickfix
						vim.cmd.cfdo("silent update") -- save all changes
						vim.o.ignorecase = ignoreCaseBefore
					end, 1)
				end,
			})
		end, 1)
	end)
end

--------------------------------------------------------------------------------

function M.openAlfredPref()
	local parentFolder = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	if not parentFolder:find("Alfred%.alfredpreferences") then
		notify("", "Not in an Alfred directory.", "warn")
		return
	end
	-- URI seems more reliable than JXA when called via nvim https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local workflowId = parentFolder:match("Alfred%.alfredpreferences/workflows/([^/]+)")
	local uri = "alfredpreferences://navigateto/workflows>workflow>" .. workflowId
	vim.fn.system { "open", uri }
	-- in case the right workflow is already open, Alfred is not focused.
	-- Therefore manually focusing in addition to that here as well.
	vim.fn.system { "open", "-a", "Alfred Preferences" }
end

--- open the next regex at https://regex101.com/
function M.openAtRegex101()
	local lang = vim.bo.filetype
	local text, pattern, replace, flags

	if lang == "javascript" or lang == "typescript" then
		vim.cmd.TSTextobjectSelect("@regex.outer")
		normal('"zy')
		vim.cmd.TSTextobjectSelect("@regex.inner") -- reselect for easier pasting
		text = vim.fn.getreg("z")
		pattern = text:match("/(.*)/")
		flags = text:match("/.*/(%l*)") or "gm"
		replace = vim.api.nvim_get_current_line():match('replace ?%(/.*/.*, ?"(.-)"')
	elseif lang == "python" then
		normal('"zyi"vi"') -- yank & reselect inside quotes
		pattern = vim.fn.getreg("z")
		local flagInLine = vim.api.nvim_get_current_line():match("re%.([MIDSUA])")
		flags = flagInLine and "g" .. flagInLine:gsub("D", "S"):lower() or "g"
	else
		notify("", "Unsupported filetype.", "warn")
		return
	end

	-- CAVEAT `+` is the only character that does not get escaped correctly
	pattern = pattern:gsub("%+", "PLUS")

	-- DOCS https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url = ("https://regex101.com/?regex=%s&flags=%s&flavor=%s%s"):format(
		pattern,
		flags,
		lang,
		(replace and "&subst=" .. replace or "")
	)
	vim.fn.system { "open", url }
end

-- simple task selector from makefile
function M.selectMake()
	-- GUARD
	local makefile = vim.loop.cwd() .. "/Makefile"
	local fileExists = vim.loop.fs_stat(makefile)
	if not fileExists then
		notify("", "Makefile not found", "warn")
		return
	end

	local recipes = {}
	for line in io.lines(makefile) do
		local recipe = line:match("^[%w_-]+")
		if recipe then table.insert(recipes, recipe) end
	end

	-- release script require version number input, which does only work in the terminal
	recipes = vim.tbl_filter(function(rec) return rec ~= "release" end, recipes)

	vim.ui.select(recipes, {
		prompt = " make",
		kind = "make-selector",
		format_item = function(recipe)
			if recipe:find("tsc") then recipe = recipe .. " (↪ quickfix)" end
			return recipe
		end,
	}, function(selection)
		if not selection then return end
		vim.cmd.update()
		if selection:find("tsc") then
			vim.cmd.make(selection) -- populate global quickfix list if check with `tsc`
			pcall(vim.cmd.cfirst)
		else
			vim.cmd.lmake(selection)
		end
	end)
end

-- Increment or toggle if cursorword is true/false. Simplified implementation
-- of dial.nvim. (Requires `expr = true` for the keymap.)
function M.toggleOrIncrement()
	-- CONFIG
	local bool = {
		["true"] = "false",
		["True"] = "False", -- python
		["const"] = "let", -- js/ts
	}

	local cword = vim.fn.expand("<cword>")
	local toggle
	for word, opposite in pairs(bool) do
		if cword == word then toggle = opposite end
		if cword == opposite then toggle = word end
		if toggle then return "mzciw" .. toggle .. "<Esc>`z" end
	end
	return "<C-a>"
end

-- 1. in addition to toggling case of letters, also toggls some common characters
-- 2. does not mvoe the cursor to the left, useful for vertical changes
function M.betterTilde()
	local toggleSigns = {
		["'"] = '"',
		["+"] = "-",
		["!"] = "=", -- for != and ==
		["("] = ")",
		["["] = "]",
		["{"] = "}",
		["<"] = ">",
	}
	local col = vim.fn.col(".") -- fn.col correctly considers tab-indentation
	local charUnderCursor = vim.api.nvim_get_current_line():sub(col, col)

	local changeTo
	for left, right in pairs(toggleSigns) do
		if charUnderCursor == left then changeTo = right end
		if charUnderCursor == right then changeTo = left end
	end
	if changeTo then
		normal("r" .. changeTo)
	else
		normal("v~") -- (`v~` instead of `~h` so dot-repetition doesn't move cursor)
	end
end

function M.gotoProject()
	-- CONFIG
	local projectFolder = vim.env.LOCAL_REPOS

	---@param folder string
	local function browseProject(folder)
		require("telescope.builtin").find_files {
			prompt_title = "Project: " .. vim.fs.basename(folder),
			cwd = folder,
		}
	end

	local handler = vim.loop.fs_scandir(projectFolder)
	if not handler then return end
	local folders = {}
	repeat
		local file, type = vim.loop.fs_scandir_next(handler)
		if type == "directory" then table.insert(folders, projectFolder .. "/" .. file) end
	until not file

	-- GUARD
	if #folders == 0 then
		notify("", "No projects found.", "warn")
	elseif #folders == 1 then
		browseProject(folders[1])
	else
		vim.ui.select(folders, {
			prompt = " Select project:",
			format_item = function(folder) return vim.fs.basename(folder) end,
			kind = "project-selector",
		}, function(selection)
			if selection then browseProject(selection) end
		end)
	end
end

--------------------------------------------------------------------------------

function M.gotoChangedFiles()
	local funcName = "Changed Files"
	local currentFile = vim.api.nvim_buf_get_name(0)
	local gitroot = vim.trim(vim.fn.system { "git", "rev-parse", "--show-toplevel" })
	local pwd = vim.loop.cwd() or ""

	-- Calculate numstat (`--intent-to-add` so new files show up in `--numstat`)
	vim.fn.system("git ls-files --others --exclude-standard | xargs git add --intent-to-add")
	local numstat = vim.trim(vim.fn.system { "git", "diff", "--numstat" })
	local numstatLines = vim.split(numstat, "\n")
	local error = vim.v.shell_error ~= 0

	-- GUARD
	if error then
		notify(funcName, "No changes found.", "warn")
		return
	elseif numstat == "" then
		notify(funcName, "Not in git repo", "warn")
		return
	end

	-- Changed Files, sorted by most changes
	local changedFiles = {}
	for _, line in pairs(numstatLines) do
		local added, deleted, file = line:match("(%d+)%s+(%d+)%s+(.+)")
		if added and deleted and file then -- exclude changed binaries
			local changes = tonumber(added) + tonumber(deleted)
			local absPath = vim.fs.normalize(gitroot .. "/" .. file)
			local relPath = absPath:sub(#pwd + 2)

			-- only add if in pwd, useful for monorepos
			if vim.startswith(absPath, pwd) then
				table.insert(changedFiles, {
					relPath = relPath,
					absPath = absPath,
					changes = changes,
				})
			end
		end
	end
	table.sort(changedFiles, function(a, b) return a.changes > b.changes end)

	-- GUARD
	if #changedFiles == 1 and changedFiles[1].absPath == currentFile then
		notify(funcName, "Already at sole changed file.", "info")
		return
	end

	-- Select next file
	local nextFileIndex
	for i = 1, #changedFiles do
		if changedFiles[i].absPath == currentFile then
			nextFileIndex = math.fmod(i, #changedFiles) + 1 -- fmod = lua's modulo
			break
		end
	end
	if not nextFileIndex then nextFileIndex = 1 end

	local nextFile = changedFiles[nextFileIndex]
	vim.cmd.edit(nextFile.absPath)

	-- notification
	if not package.loaded["notify"] then return end
	local icon = "" -- CONFIG
	local listOfChangedFiles = {}
	for i = 1, #changedFiles do
		local prefix = (i == nextFileIndex and icon or "·") .. " "
		local path = changedFiles[i].relPath
		table.insert(listOfChangedFiles, prefix .. path)
	end
	local msg = table.concat(listOfChangedFiles, "\n")

	vim.g.changedFilesNotif = vim.notify(msg, vim.log.levels.INFO, {
		title = funcName,
		replace = vim.g.changedFilesNotif and vim.g.changedFilesNotif.id,
		on_open = function(win)
			local bufnr = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_call(bufnr, function() vim.fn.matchadd("Title", icon .. ".*") end)
		end,
	})
end

--------------------------------------------------------------------------------

function M.gotoPluginConfig()
	local plugins = require("lazy").plugins()
	vim.ui.select(plugins, {
		prompt = "󰣖 Select Plugin:",
		format_item = function(plugin) return vim.fs.basename(plugin[1]) end,
	}, function(plugin)
		if not plugin then return end
		local module = plugin._.module:gsub("%.", "/")
		local filepath = vim.fn.stdpath("config") .. "/lua/" .. module .. ".lua"
		local repo = plugin[1]:gsub("/", "\\/") -- escape for `:edit`
		vim.cmd(("edit +/%q %s"):format(repo, filepath))
	end)
end

--------------------------------------------------------------------------------
return M
