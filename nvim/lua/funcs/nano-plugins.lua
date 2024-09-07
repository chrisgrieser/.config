-- A bunch of commands that are too small to be published as plugins, but too
-- big to put in the main config, where they would crowd the actual config.
-- Every function is self-contained and should be bound to a keymap.
local M = {}
--------------------------------------------------------------------------------

--- open the current workflow for the Alfred app
function M.openAlfredPref()
	local bufPath = vim.api.nvim_buf_get_name(0)
	local workflowId = bufPath:match("Alfred%.alfredpreferences/workflows/(.-)/")
	if not workflowId then
		vim.notify("Not in an Alfred directory.", vim.log.levels.WARN)
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
		ignoreRecipes = { "release" }, -- since it requires user input
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
		function(r) return not vim.tbl_contains(config.ignoreRecipes, r) end,
		recipes
	)

	if first then
		run(recipes[1])
	else
		table.insert(recipes, table.remove(recipes, 1)) -- move first to end
		vim.ui.select(recipes, { prompt = " Just Recipes", kind = "plain" }, run)
		vim.api.nvim_create_autocmd("DressingSelect", {
			callback = function(ctx)
				local lastLine = vim.api.nvim_buf_line_count(ctx.buf)
				vim.api.nvim_buf_add_highlight(ctx.buf, 0, "Comment", lastLine, 0, -1)
			end,
		})
	end
end

-- Increment or toggle if cursorword is true/false. Simplified implementation
-- of dial.nvim. (REQUIRED `expr = true` for the keymap.)
function M.toggleOrIncrement()
	local toggles = {
		["true"] = "false",
		["True"] = "False", -- python
		["const"] = "let", -- js
		["and"] = "or", -- lua
	}

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
		vim.cmd.normal { "q" .. register, bang = true }
	else
		vim.cmd.normal { "q", bang = true }
		local macro = vim.fn.getreg(register):sub(1, -(#toggleKey + 1)) -- as the key itself is recorded
		if macro ~= "" then
			vim.fn.setreg(register, macro)
			vim.notify(vim.fn.keytrans(macro), vim.log.levels.TRACE, { title = "Recorded" })
		else
			vim.notify("Aborted.", vim.log.levels.TRACE, { title = "Recording" })
		end
	end
	-- sound if on macOS
	if vim.uv.os_uname().sysname == "Darwin" then
		local sound = "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/"
			.. (notRecording and "begin_record.caf" or "end_record.caf")
		vim.system { "afplay", sound }
	end
end

-- UPPER -> lower -> Title -> UPPER
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

--------------------------------------------------------------------------------
return M
