-- INFO A bunch of commands that are too small to be published as plugins, but
-- too big to put in the main config, where they would crowd the actual config.
-- Every function is self-contained and should be bound to a keymap.
local M = {}
--------------------------------------------------------------------------------

--- open the current workflow for in the Alfred workflow preferences
function M.openAlfredPref()
	if jit.os ~= "OSX" then
		vim.notify("Alfred is only available on macOS.", vim.log.levels.WARN)
		return
	end
	local workflowUid =
		vim.api.nvim_buf_get_name(0):match("Alfred%.alfredpreferences/workflows/(.-)/")
	if not workflowUid then
		vim.notify("Not in an Alfred directory.", vim.log.levels.WARN)
		return
	end
	-- https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local jxa = ('Application("com.runningwithcrayons.Alfred").revealWorkflow(%q)'):format(
		workflowUid
	)
	vim.system { "osascript", "-l", "JavaScript", "-e", jxa }
end

--------------------------------------------------------------------------------

---1. start/stop with just one keypress
---2. add notification & sound for recording
---@param toggleKey string key used to trigger this function
---@param reg string vim register (single letter)
function M.startOrStopRecording(toggleKey, reg)
	local notRecording = vim.fn.reg_recording() == ""

	if notRecording then
		vim.cmd.normal { "q" .. reg, bang = true }
	else
		vim.cmd.normal { "q", bang = true }
		local macro = vim.fn.getreg(reg):sub(1, -(#toggleKey + 1)) -- as the key itself is recorded
		if macro ~= "" then
			vim.fn.setreg(reg, macro)
			local msg = vim.fn.keytrans(macro)
			vim.notify(msg, vim.log.levels.TRACE, { title = "Recorded", icon = "󰃽" })
		else
			vim.notify("Aborted.", vim.log.levels.TRACE, { title = "Recording", icon = "󰜺" })
		end
	end
	-- sound if on macOS
	if jit.os == "OSX" then
		local sound = "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/"
			.. (notRecording and "begin_record.caf" or "end_record.caf")
		vim.system { "afplay", sound } -- async
	end
end

--------------------------------------------------------------------------------

-- Simplified implementation of `coerce.nvim`
function M.camelSnakeLspRename()
	local cword = vim.fn.expand("<cword>")
	local snakePattern = "_(%w)"
	local camelPattern = "([%l%d])(%u)"

	if cword:find(snakePattern) then
		local camelCased = cword:gsub(snakePattern, function(c1) return c1:upper() end)
		vim.lsp.buf.rename(camelCased)
	elseif cword:find(camelPattern) then
		local snake_cased = cword
			:gsub(camelPattern, function(c1, c2) return c1 .. "_" .. c2 end)
			:lower()
		vim.lsp.buf.rename(snake_cased)
	else
		local msg = "Neither snake_case nor camelCase: " .. cword
		vim.notify(msg, vim.log.levels.WARN, { title = "LSP Rename" })
	end
end

function M.toggleTitleCase()
	local prevCursor = vim.api.nvim_win_get_cursor(0)

	local cword = vim.fn.expand("<cword>")
	local cmd = cword == cword:lower() and "guiwgUl" or "guiw"
	vim.cmd.normal { cmd, bang = true }

	vim.api.nvim_win_set_cursor(0, prevCursor)
end

-- Increment or toggle if cursorword is true/false (Simplified version of dial.nvim)
function M.toggleOrIncrement()
	local toggles = {
		["true"] = "false",
		["True"] = "False", -- python
		["const"] = "let", -- js
	}
	local cword = vim.fn.expand("<cword>")
	local newWord
	for word, opposite in pairs(toggles) do
		if cword == word then newWord = opposite end
		if cword == opposite then newWord = word end
	end
	if newWord then
		vim.cmd.normal { '"_ciw' .. newWord, bang = true }
	else
		-- needs `:execute` to escape `<C-a>`
		vim.cmd.execute('"normal! ' .. vim.v.count1 .. '\\<C-a>"')
	end
end

--------------------------------------------------------------------------------

function M.smartDuplicate()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local ft = vim.bo.filetype

	-- FILETYPE-SPECIFIC TWEAKS
	if ft == "css" then
		local newLine = line
		if line:find("top:") then newLine = line:gsub("top:", "bottom:") end
		if line:find("bottom:") then newLine = line:gsub("bottom:", "top:") end
		if line:find("right:") then newLine = line:gsub("right:", "left:") end
		if line:find("left:") then newLine = line:gsub("left:", "right:") end
		line = newLine
	elseif ft == "javascript" or ft == "typescript" then
		line = line:gsub("^(%s*)if(.+{)$", "%1} else if%2")
	elseif ft == "lua" then
		line = line:gsub("^(%s*)if( .* then)$", "%1elseif%2")
	elseif ft == "zsh" or ft == "bash" then
		line = line:gsub("^(%s*)if( .* then)$", "%1elif%2")
	elseif ft == "python" then
		line = line:gsub("^(%s*)if( .*:)$", "%1elif%2")
	end

	-- INSERT DUPLICATED LINE
	vim.api.nvim_buf_set_lines(0, row, row, false, { line })

	-- MOVE CURSOR DOWN, AND TO VALUE/FIELD (IF EXISTS)
	local _, luadocFieldPos = line:find("%-%-%-@%w+ ")
	local _, valuePos = line:find("[:=][:=]? ")
	local targetCol = luadocFieldPos or valuePos or col
	vim.api.nvim_win_set_cursor(0, { row + 1, targetCol })
end

--------------------------------------------------------------------------------

function M.spellSuggest()
	local limit = 9 -- CONFIG
	local suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
	suggestions = vim.list_slice(suggestions, 1, limit)

	vim.ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" }, function(selection)
		if selection then return end
		vim.cmd.normal { '"_ciw' .. selection, bang = true }
	end)
end

--------------------------------------------------------------------------------

function M.gotoMostChangedFile()
	local notifyOpts = { title = "Most changed file", icon = "󰊢" }

	-- get list of changed files
	local gitResponse = vim.system({ "git", "diff", "--numstat", "." }):wait()
	if gitResponse.code ~= 0 then
		vim.notify("Not in git repo.", vim.log.levels.WARN, notifyOpts)
		return
	end
	local changedFiles = vim.split(gitResponse.stdout, "\n", { trimempty = true })
	local gitroot = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout)
	if #changedFiles == 0 then
		vim.notify("No files with changes found.", nil, notifyOpts)
		return
	end

	-- identify file with most changes
	local targetFile
	local mostChanges = 0
	vim.iter(changedFiles):each(function(line)
		local added, deleted, relPath = line:match("(%d+)%s+(%d+)%s+(.+)")
		if not (added and deleted and relPath) then return end -- in case of changed binary files

		local absPath = vim.fs.normalize(gitroot .. "/" .. relPath)
		if not vim.uv.fs_stat(absPath) then return end

		local changes = tonumber(added) + tonumber(deleted)
		if changes > mostChanges then
			mostChanges = changes
			targetFile = absPath
		end
	end)
	local currentFile = vim.api.nvim_buf_get_name(0)
	if targetFile == currentFile then
		vim.notify("Already at only changed file.", nil, notifyOpts)
		return
	end

	vim.cmd.edit(targetFile)
end

--------------------------------------------------------------------------------

function M.formatWithFallback()
	local formattingLsps = vim.lsp.get_clients { method = "textDocument/formatting", bufnr = 0 }

	if #formattingLsps > 0 then
		-- save for efm-formatters that don't use stdin
		if vim.bo.ft == "markdown" then
			-- saving with explicit name prevents issues when changing `cwd`
			-- `:update!` suppresses "The file has been changed since reading it!!!"
			local vimCmd = ("silent update! %q"):format(vim.api.nvim_buf_get_name(0))
			vim.cmd(vimCmd)
		end
		vim.lsp.buf.format()
	else
		vim.cmd([[% substitute_\s\+$__e]]) -- remove trailing spaces
		vim.cmd([[% substitute _\(\n\n\)\n\+_\1_e]]) -- remove duplicate blank lines
		vim.cmd([[silent! /^\%(\n*.\)\@!/,$ delete]]) -- remove blanks at end of file
	end
end

--------------------------------------------------------------------------------
return M
