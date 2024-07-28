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
	elseif ft == "zsh" then
		toggles["&&"] = "||"
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
return M
