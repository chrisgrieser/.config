local M = {}
--------------------------------------------------------------------------------
-- A bunch of commands that are too small to be published as plugins, but too
-- big to put in the main config, where they would crowd the actual config.
-- Every function is self-contained (except the helper functions below), and
-- should be bound to a keymap.

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

--- open the current workflow for the Alfred app
function M.openAlfredPref()
	local bufPath = vim.api.nvim_buf_get_name(0)
	local workflowId = bufPath:match("Alfred%.alfredpreferences/workflows/(.-)/")
	if not workflowId then
		notify("", "Not in an Alfred directory.", "warn")
		return
	end
	-- using JXA and URI for redundancy, as both are not 100% reliable
	-- https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local jxa = 'Application("com.runningwithcrayons.Alfred").revealWorkflow(' .. workflowId .. ")"
	vim.system { "osascript", "-l", "JavaScript", "-e", jxa }
	local uri = "alfredpreferences://navigateto/workflows>workflow>" .. workflowId
	vim.ui.open(uri)
end

---open the next regex at https://regex101.com/
---REQUIRED nvim-rip-substitute & nvim-treesitter-textobjects
function M.openAtRegex101()
	local ft = vim.bo.filetype
	local data = {}

	if ft == "javascript" or ft == "typescript" then
		vim.cmd.TSTextobjectSelect("@regex.outer")
		normal('"zy')

		data.regex, data.flags = vim.fn.getreg("z"):match("/(.*)/(%l*)")
		data.substitution = vim.api.nvim_get_current_line():match('%.replace ?%(/.*/.*, ?"(.-)"')
		data.delimiter = "/"
		data.flavor = "javascript"

		vim.cmd.TSTextobjectSelect("@regex.inner") -- reselect for easier pasting
	elseif ft == "python" then
		normal('"zyi"vi"') -- yank & reselect inside quotes

		data.regex = vim.fn.getreg("z")
		local flagInLine = vim.api.nvim_get_current_line():match("re%.([MIDSUA])")
		data.flags = flagInLine and "g" .. flagInLine:gsub("D", "S"):lower() or "g"
		data.delimiter = '"'
		data.flavor = "python"
	else
		notify("", "Unsupported filetype.", "warn")
		return
	end
	data.testString = ""

	require("rip-substitute.open-at-regex101").open(data)
end

---@param first any -- if truthy, run first recipe
function M.justRecipe(first)
	local config = {
		ignoreRecipe = { "release" }, -- since it requires user input
		skipFirstInSelection = true,
		useQuickfix = { "check-tsc" },
	}

	local function run(recipe)
		vim.cmd.update()
		if not recipe then return end
		if vim.tbl_contains(config.useQuickfix, recipe) then
			vim.opt_local.makeprg = "just"
			vim.cmd.make(recipe)
			pcall(vim.cmd.cfirst)
		else
			local result = vim.system({ "just", recipe }):wait()
			local out = vim.trim((result.stdout or "") .. (result.stderr or ""))
			local severity = result.code == 0 and "INFO" or "ERROR"
			if out ~= "" then
				vim.notify(out, vim.log.levels[severity], { title = "Just: " .. recipe })
			end
		end
		vim.cmd.checktime() -- reload buffer
	end
	-----------------------------------------------------------------------------

	local result = vim.system({ "just", "--summary", "--unsorted" }):wait()
	if result.code ~= 0 then
		vim.notify(result.stderr, vim.log.levels.ERROR, { title = "Just" })
		return
	end
	local recipes = vim.split(vim.trim(result.stdout), " ")
	recipes = vim.tbl_filter(
		function(r) return not vim.tbl_contains(config.ignoreRecipe, r) end,
		recipes
	)

	if first then
		run(recipes[1])
	else
		if config.skipFirstInSelection and #recipes > 1 then table.remove(recipes, 1) end
		vim.ui.select(recipes, { prompt = " Just Recipes", kind = "just-recipes" }, run)
	end
end

-- Increment or toggle if cursorword is true/false. Simplified implementation
-- of dial.nvim. (REQUIRED `expr = true` for the keymap.)
function M.toggleOrIncrement()
	local ft = vim.bo.filetype
	local toggles = { ["true"] = "false" }
	if ft == "typescript" or ft == "javascript" then
		toggles["const"] = "let"
		toggles["&&"] = "||"
		toggles["!=="] = "==="
	elseif ft == "python" then
		toggles["true"] = nil
		toggles["True"] = "False"
		toggles["!="] = "=="
	elseif ft == "lua" then
		toggles["and"] = "or"
		toggles["~="] = "=="
	end

	local cword = vim.fn.expand("<cword>")
	local toggle
	for word, opposite in pairs(toggles) do
		if cword == word then toggle = opposite end
		if cword == opposite then toggle = word end
		if toggle then return 'mz"_ciw' .. toggle .. "<Esc>`z" end
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

---1. start/stop with just one keypress
---2. add notification & sound for recording
---@param toggleKey string
---@param register string
function M.startStopRecording(toggleKey, register)
	local notRecording = vim.fn.reg_recording() == ""
	if notRecording then
		normal("q" .. register)
	else
		normal("q")
		local macro = vim.fn.getreg(register):sub(1, -(#toggleKey + 1)) -- as the key itself is recorded
		if macro ~= "" then
			vim.fn.setreg(register, macro)
			notify("Recorded", vim.fn.keytrans(macro), "trace")
		else
			notify("Recording", "Aborted.", "trace")
		end
	end
	local sound = "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/"
		.. (notRecording and "begin_record.caf" or "end_record.caf")
	vim.system { "afplay", sound } -- macOS only
end

--------------------------------------------------------------------------------

function M.gitChanges()
	local out = vim.system({ "git", "diff" }):wait()
	if out.code ~= 0 then
		notify("git", out.stderr, "error")
		return
	end
	local changesPerFile = vim.split(out.stdout, "diff --git a/", { plain = true })
	table.remove(changesPerFile, 1) -- first item is always an empty string

	-- Loop through each file, and then through each hunk of that file. Construct
	-- flattened list of hunks, each with their own diff header, so they work as
	-- independent patches. Those patches in turn are needed for `git apply`
	-- stage only part of a file.
	local hunks = {}
	for _, file in ipairs(changesPerFile) do
		file = "diff --git a/" .. file
		local diffLines = vim.split(file, "\n")
		local relPath = diffLines[3]:sub(7)
		local diffHeader = table.concat(vim.list_slice(diffLines, 1, 4), "\n")

		local changesInFile = vim.list_slice(diffLines, 5)
		local hunksInFile = {}
		for _, line in ipairs(changesInFile) do
			if vim.startswith(line, "@@") then
				table.insert(hunksInFile, line)
			else
				hunksInFile[#hunksInFile] = hunksInFile[#hunksInFile] .. "\n" .. line
			end
		end

		for _, hunk in ipairs(hunksInFile) do
			local lnum = hunk:match("@@ %-(%d+)")
			local patch = diffHeader .. "\n" .. hunk
			table.insert(hunks, {
				file = relPath,
				lnum = lnum,
				display = vim.fs.basename(relPath) .. ":" .. lnum,
				patch = patch,
			})
		end
	end

	-----------------------------------------------------------------------------

	vim.ui.select(hunks, {
		prompt = "Git Hunks",
		format_item = function(hunk) return hunk.display end,
		telescope = {
			previewer = require("telescope.previewers").new_buffer_previewer {
				define_preview = function(self, entry)
					local bufnr = self.state.bufnr
					local hunk = entry.value
					local display = vim.list_slice(vim.split(hunk.patch, "\n"), 5)
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, display)
					vim.bo[bufnr].filetype = "diff"
				end,
				dyn_title = function(_, entry)
					local hunk = entry.value
					return hunk.file .. ":" .. hunk.lnum
				end,
			},
		},
	}, function(hunk)
		if not hunk then return end

		-- use `git apply` to stage only part of a file, see https://stackoverflow.com/a/66618356/22114136
		local out2 = vim.system({ "git", "apply", "-", "--cached" }, { stdin = hunk.patch }):wait()
		if out2.code ~= 0 then
			notify("git", out.stderr, "error")
			return
		end
		notify("git", "Staged hunk " .. hunk.display)

		-- call itself to continue staging
		if #hunks > 1 then M.gitChanges() end
	end)
end

--------------------------------------------------------------------------------
return M
