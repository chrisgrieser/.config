-- INFO A bunch of commands that are too small to be published as plugins, but
-- too big to put in the main config, where they would crowd the actual config.
-- Every function is self-contained and should be bound to a keymap.
local M = {}
--------------------------------------------------------------------------------

--- open the current workflow for the Alfred app
function M.openAlfredPref()
	if jit.os ~= "OSX" then
		vim.notify("Not on macOS.", vim.log.levels.WARN)
		return
	end
	local bufPath = vim.api.nvim_buf_get_name(0)
	local workflowUid = bufPath:match("Alfred%.alfredpreferences/workflows/(.-)/")
	if not workflowUid then
		vim.notify("Not in an Alfred directory.", vim.log.levels.WARN)
		return
	end
	-- redundancy: using JXA and URI, as both are not 100% reliable
	-- https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local jxa = 'Application("com.runningwithcrayons.Alfred").revealWorkflow(' .. workflowUid .. ")"
	vim.system { "osascript", "-l", "JavaScript", "-e", jxa }
	local uri = "alfredpreferences://navigateto/workflows>workflow>" .. workflowUid
	vim.ui.open(uri)
end

--- Simple taskrunner using `just`
---@param which "first"|"select"
function M.justRecipe(which)
	local config = {
		ignoreRecipes = { "release" }, -- since it requires user input
		useQuickfix = { "check-tsc" },
	}

	local function run(recipe)
		if not recipe then return end

		-- 1: QUICKFIX
		if vim.tbl_contains(config.useQuickfix, recipe) then
			vim.opt_local.makeprg = "just"
			vim.cmd.make(recipe)
			pcall(vim.cmd.cfirst) -- if there is a quickfix item, move to the 1st one
			vim.cmd.checktime() -- reload buffer in case of changes
			return
		end

		-- 2A: `JUST` SYSTEM CALL
		--  (= things like progress bars can be displayed)
		-- Requires `snacks.nvim`, to replace the previous notification via `id`
		if package.loaded["snacks"] then
			local buffer = ""
			local function bufferedOut(severity)
				return function(_, data)
					if not data then return end
					buffer = buffer .. data:gsub("\n$", "")
					local opts = { title = "Just: " .. recipe, id = "just-recipe" }
					vim.notify(buffer, vim.log.levels[severity], opts)
				end
			end
			vim.system(
				{ "just", recipe },
				{ stdout = bufferedOut("INFO"), stderr = bufferedOut("ERROR") },
				vim.cmd.checktime
			)
			return
		end

		-- 2B: `JUST` SYSTEM CALL
		-- async & unbuffered output
		vim.system({ "just", recipe }, {}, function(out)
			local text = vim.trim((out.stdout or "") .. (out.stderr or ""))
			local severity = out.code == 0 and "INFO" or "ERROR"
			vim.notify(text, vim.log.levels[severity], { title = "Just: " .. recipe })
			vim.cmd.checktime()
		end)
	end
	-----------------------------------------------------------------------------

	vim.cmd("silent! update")
	local result = vim.system({ "just", "--summary", "--unsorted" }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR, { title = "Just" })
		return
	end
	local recipes = vim.iter(vim.split(vim.trim(result.stdout), " "))
		:filter(function(r) return not vim.tbl_contains(config.ignoreRecipes, r) end)
		:totable()

	if which == "first" then
		run(recipes[1])
		return
	end

	table.insert(recipes, table.remove(recipes, 1)) -- 1st recipe to end, since accessible via "first"
	vim.ui.select(recipes, { prompt = " Just Recipes", kind = "plain" }, run)
end

---1. start/stop with just one keypress
---2. add notification & sound for recording
---@param toggleKey string key used to trigger this function
---@param reg string vim register (single letter)
function M.startOrStopRecording(toggleKey, reg)
	if not reg:find("^%l$") then
		vim.notify("Invalid register: " .. reg, vim.log.levels.ERROR)
		return
	end
	local notRecording = vim.fn.reg_recording() == ""
	if notRecording then
		vim.cmd.normal { "q" .. reg, bang = true }
	else
		vim.cmd.normal { "q", bang = true }
		local macro = vim.fn.getreg(reg):sub(1, -(#toggleKey + 1)) -- as the key itself is recorded
		if macro ~= "" then
			vim.fn.setreg(reg, macro)
			vim.notify(vim.fn.keytrans(macro), vim.log.levels.TRACE, { title = "Recorded" })
		else
			vim.notify("Aborted.", vim.log.levels.TRACE, { title = "Recording" })
		end
	end
	-- sound if on macOS
	if jit.os == "OSX" then
		local sound = "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/"
			.. (notRecording and "begin_record.caf" or "end_record.caf")
		vim.system { "afplay", sound }
	end
end

--------------------------------------------------------------------------------

-- Increment or toggle if cursorword is true/false.
-- + Simplified implementation of dial.nvim.
-- + REQUIRED `expr = true` for the keybinding
function M.toggleOrIncrement()
	local toggles = {
		["true"] = "false",
		["True"] = "False", -- python
		["const"] = "let", -- js
		["and"] = "or", -- lua
	}
	-- cannot use vim.cmd.normal, because it changes cursor position
	local cword = vim.fn.expand("<cword>")
	for word, opposite in pairs(toggles) do
		if cword == word then return '"_ciw' .. opposite .. "<Esc>" end
		if cword == opposite then return '"_ciw' .. word .. "<Esc>" end
	end
	return "<C-a>"
end

-- Simplified implementation of coerce.nvim
function M.camelSnakeToggle()
	local cword = vim.fn.expand("<cword>")
	local newWord
	local snakePattern = "_(%w)"
	local camelPattern = "([%l%d])(%u)"

	if cword:find(snakePattern) then
		newWord = cword:gsub(snakePattern, function(capture) return capture:upper() end)
	elseif cword:find(camelPattern) then
		newWord = cword:gsub(camelPattern, function(c1, c2) return c1 .. "_" .. c2:lower() end)
	else
		vim.notify("Neither a snake_case nor camelCase", vim.log.levels.WARN)
		return
	end

	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local start, ending
	while true do
		start, ending = line:find(cword, ending or 0, true)
		if start <= col and ending >= col then break end
	end
	local newLine = line:sub(1, start - 1) .. newWord .. line:sub(ending + 1)
	vim.api.nvim_set_current_line(newLine)
end

-- UPPER -> lower -> Title -> UPPER -> …
function M.toggleWordCasing()
	local prevCursor = vim.api.nvim_win_get_cursor(0)

	local cword = vim.fn.expand("<cword>")
	local cmd
	if cword == cword:upper() then
		cmd = "guiw"
	elseif cword == cword:lower() then
		cmd = "guiwgUl"
	else
		cmd = "gUiw"
	end

	vim.cmd.normal { cmd, bang = true }
	vim.api.nvim_win_set_cursor(0, prevCursor)
end

function M.gotoMostChangedFile()
	-- get list of changed files
	local gitResponse = vim.system({ "git", "diff", "--numstat", "." }):wait()
	if gitResponse.code ~= 0 then
		vim.notify("Not in git repo.", vim.log.levels.WARN)
		return
	end
	local changedFiles = vim.split(gitResponse.stdout, "\n", { trimempty = true })
	local gitroot = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout)
	if #changedFiles == 0 then
		vim.notify("No files with changes found.")
		return
	end

	-- identify file with most changes
	local targetFile
	local mostChanges = 0
	vim.iter(changedFiles):each(function(line)
		local added, deleted, relPath = line:match("(%d+)%s+(%d+)%s+(.+)")
		if not (added and deleted and relPath) then return end -- exclude changed binaries

		local absPath = vim.fs.normalize(gitroot .. "/" .. relPath)
		if not vim.uv.fs_stat(absPath) then return end

		local changes = tonumber(added) + tonumber(deleted)
		if changes > mostChanges then
			mostChanges = changes
			targetFile = absPath
		end
	end)

	-- open
	if targetFile == vim.api.nvim_buf_get_name(0) then
		vim.notify("Already at only changed file.")
	else
		vim.cmd.edit(targetFile)
	end
end

--------------------------------------------------------------------------------
return M
