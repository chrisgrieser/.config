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

function M.openAlfredPref()
	local bufPath = vim.api.nvim_buf_get_name(0)
	local workflowId = bufPath:match("Alfred%.alfredpreferences/workflows/(.-)/")
	if not workflowId then
		notify("", "Not in an Alfred directory.", "warn")
		return
	end

	-- using JXA and URI for redundancy, as both are not 100% reliable
	-- https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local uri = "alfredpreferences://navigateto/workflows>workflow>" .. workflowId
	local jxa = 'Application("com.runningwithcrayons.Alfred").revealWorkflow(' .. workflowId .. ")"
	vim.system { "osascript", "-l", "JavaScript", "-e", jxa }
	vim.ui.open(uri)
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
	vim.ui.open(url)
end

-- simple task selector from makefile
function M.selectMake()
	-- GUARD
	local makefile = vim.uv.cwd() .. "/Makefile"
	local fileExists = vim.uv.fs_stat(makefile)
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
		vim.cmd.checktime() -- reload buffer in case file is formatter
	end)
end

-- Increment or toggle if cursorword is true/false. Simplified implementation
-- of dial.nvim. (REQUIRED `expr = true` for the keymap.)
function M.toggleOrIncrement()
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
-- 2. does not move the cursor to the left, useful for vertical changes
function M.betterTilde()
	local toggleSigns = {
		["'"] = '"',
		["+"] = "-",
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

--------------------------------------------------------------------------------

local changedFileNotif
function M.gotoChangedFiles()
	local funcName = "Changed Files"

	-- Calculate numstat (`--intent-to-add` so new files show up in `--numstat`)
	vim.fn.system(
		"git ls-files --others --exclude-standard | xargs -I {} git add --intent-to-add {}"
	)
	local gitResponse = vim.system({ "git", "diff", "--numstat" }):wait()
	local numstat = vim.trim(gitResponse.stdout)
	local numstatLines = vim.split(numstat, "\n")

	-- GUARD
	if gitResponse.code ~= 0 then
		notify(funcName, "Not in git repo", "warn")
		return
	elseif numstat == "" then
		notify(funcName, "No changes found.", "info")
		return
	end

	-- parameters
	local gitroot = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout)
	local pwd = vim.uv.cwd() or ""
	local currentFile = vim.api.nvim_buf_get_name(0)

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
		notify(funcName, "Already at only changed file.", "info")
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

	-- Notification
	if not package.loaded["notify"] then return end
	local currentFileIcon = ""
	local listOfChangedFiles = {}
	for i = 1, #changedFiles do
		local prefix = (i == nextFileIndex and currentFileIcon or "·") .. " "
		local path = changedFiles[i].relPath
		table.insert(listOfChangedFiles, prefix .. path)
	end
	local msg = table.concat(listOfChangedFiles, "\n")

	changedFileNotif = vim.notify(msg, vim.log.levels.INFO, {
		title = funcName,
		replace = changedFileNotif and changedFileNotif.id,
		animate = false,
		hide_from_history = changedFileNotif ~= nil, -- keep only first in history
		on_open = function(win)
			local bufnr = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_call(
				bufnr,
				function() vim.fn.matchadd("Title", currentFileIcon .. ".*") end
			)
		end,
	})
end

--------------------------------------------------------------------------------
return M
