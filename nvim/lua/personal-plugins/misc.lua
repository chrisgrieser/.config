-- INFO
-- A bunch of commands that are too small to be published as plugins, but too
-- big to put in the main config, where they would crowd the actual config.
-- Every function is self-contained and should be bound to a keymap.
local M = {}
--------------------------------------------------------------------------------

--- open the current workflow for the Alfred app
function M.openAlfredPref()
	if jit.os ~= "OSX" then
		vim.notify("Not on macOS.", vim.log.levels.WARN)
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

function M.editMacro(reg)
	local macroContent = vim.fn.getreg(reg)
	local title = ("Edit macro [%s]"):format(reg)
	local icon = "󰃽"

	vim.ui.input({ prompt = icon .. " " .. title, default = macroContent }, function(input)
		if not input then return end
		vim.fn.setreg(reg, input)
		vim.notify(input, nil, { title = title, icon = icon })
	end)
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
		vim.cmd.execute('"normal! \\<C-a>"') -- needs :execute to escape `<C-a>`
	end
end

--------------------------------------------------------------------------------

function M.smartDuplicate()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()

	-- FILETYPE-SPECIFIC TWEAKS
	if vim.bo.ft == "css" then
		local newLine = line
		if line:find("top:") then newLine = line:gsub("top:", "bottom:") end
		if line:find("bottom:") then newLine = line:gsub("bottom:", "top:") end
		if line:find("right:") then newLine = line:gsub("right:", "left:") end
		if line:find("left:") then newLine = line:gsub("left:", "right:") end
		line = newLine
	elseif vim.bo.ft == "javascript" or vim.bo.ft == "typescript" then
		line = line:gsub("^(%s*)if(.+{)$", "%1} else if%2")
	elseif vim.bo.ft == "lua" then
		line = line:gsub("^(%s*)if( .* then)$", "%1elseif%2")
	elseif vim.bo.ft == "zsh" or vim.bo.ft == "bash" then
		line = line:gsub("^(%s*)if( .* then)$", "%1elif%2")
	elseif vim.bo.ft == "python" then
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

---@param limit number
function M.spellSuggest(limit)
	local suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
	suggestions = vim.list_slice(suggestions, 1, limit)

	vim.ui.select(
		suggestions,
		{ prompt = "󰓆 Spelling suggestions", kind = "spell" },
		function(selection)
			if not selection then return end
			vim.cmd.normal { '"_ciw' .. selection, bang = true }
		end
	)
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

---Cycles files in folder in alphabetical order.
---If snacks.nvim is installed, adds cycling notification.
---@param direction "next"|"prev"
function M.nextFileInFolder(direction)
	-- CONFIG
	local ignoreExt = { "png", "svg", "webp", "jpg", "jpeg", "gif", "pdf", "zip" }

	local curPath = vim.api.nvim_buf_get_name(0)
	local curFile = vim.fs.basename(curPath)
	local curFolder = vim.fs.dirname(curPath)

	local notifyOpts = {
		title = direction:sub(1, 1):upper() .. direction:sub(2) .. " file",
		icon = direction == "next" and "󰖽" or "󰖿",
		id = "next-in-folder", -- replace notifications when quickly cycling
		ft = "markdown", -- so `h1` is highlighted
	}

	-- get list of files
	local itemsInFolder = vim.fs.dir(curFolder) -- INFO `fs.dir` already returns them sorted
	local filesInFolder = vim.iter(itemsInFolder):fold({}, function(acc, name, type)
		local ext = name:match("%.(%w+)$")
		if type ~= "file" or name:find("^%.") or vim.tbl_contains(ignoreExt, ext) then return acc end
		table.insert(acc, name) -- select only name
		return acc
	end)

	-- GUARD if currently at a hidden file and there are only hidden files in the dir
	if #filesInFolder == 0 then
		vim.notify("No valid files found in folder.", vim.log.levels.ERROR, notifyOpts)
		return
	end

	-- determine next index
	local curIdx
	for idx = 1, #filesInFolder do
		if filesInFolder[idx] == curFile then
			curIdx = idx
			break
		end
	end
	local nextIdx = curIdx + (direction == "next" and 1 or -1)
	if nextIdx < 1 then nextIdx = #filesInFolder end
	if nextIdx > #filesInFolder then nextIdx = 1 end

	-- goto file
	local nextFile = curFolder .. "/" .. filesInFolder[nextIdx]
	vim.cmd.edit(nextFile)

	-- notification
	if package.loaded["snacks"] then
		local msg = vim
			.iter(filesInFolder)
			:map(function(file)
				-- mark current, using markdown h1
				local prefix = file == filesInFolder[nextIdx] and "#" or "-"
				return prefix .. " " .. file
			end)
			:slice(nextIdx - 5, nextIdx + 5) -- display ~5 files before/after
			:join("\n")
		notifyOpts.title = notifyOpts.title .. (" (%d/%d)"):format(nextIdx, #filesInFolder)
		vim.notify(msg, nil, notifyOpts)
	end
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

-- `fF` work with `nN` instead of `;,` (inspired by tT.nvim)
---@param char "f"|"F"
function M.fF(char)
	local target = vim.fn.getcharstr() -- awaits user input for a char
	local pattern = [[\V\C]] .. target
	vim.fn.setreg("/", pattern)
	vim.fn.search(pattern, char == "f" and "" or "b") -- move cursor
	vim.v.searchforward = 1 -- `n` always forward, `N` always backward
end

--------------------------------------------------------------------------------
return M
