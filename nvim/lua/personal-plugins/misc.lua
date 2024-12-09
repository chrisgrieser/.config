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
	-- redundancy: using JXA and URI, as both are not 100% reliable
	-- https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local jxa = 'Application("com.runningwithcrayons.Alfred").revealWorkflow(' .. workflowUid .. ")"
	vim.system { "osascript", "-l", "JavaScript", "-e", jxa }
	local uri = "alfredpreferences://navigateto/workflows>workflow>" .. workflowUid
	vim.ui.open(uri)
end

--------------------------------------------------------------------------------

---1. start/stop with just one keypress
---2. add notification & sound for recording
---@param toggleKey string key used to trigger this function
---@param reg string vim register (single letter)
function M.startOrStopRecording(toggleKey, reg)
	if not reg:find("^%l$") then
		vim.notify("Register must be single lowercase letter.", vim.log.levels.ERROR)
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
	local title = "Edit macro [" .. reg .. "]"

	vim.ui.input({ prompt = title, default = macroContent }, function(editedMacro)
		if not editedMacro then return end
		vim.fn.setreg(reg, editedMacro)
		vim.notify(editedMacro, nil, { title = title })
	end)
end

--------------------------------------------------------------------------------

-- Simplified implementation of coerce.nvim
function M.camelSnakeLspRename()
	local cword = vim.fn.expand("<cword>")
	local snakePattern = "_(%w)"
	local camelPattern = "([%l%d])(%u)"

	if cword:find(snakePattern) then
		local camelCased = cword:gsub(snakePattern, function(c1) return c1:upper() end)
		vim.lsp.buf.rename(camelCased)
	elseif cword:find(camelPattern) then
		local snake_cased = cword:gsub(
			camelPattern,
			function(c1, c2) return c1 .. "_" .. c2:lower() end
		)
		vim.lsp.buf.rename(snake_cased)
	else
		local msg = "Neither snake_case nor camelCase: " .. cword
		vim.notify(msg, vim.log.levels.WARN, { title = "LSP Rename" })
	end
end

-- Increment or toggle if cursorword is true/false.
-- + Simplified implementation of dial.nvim.
-- + REQUIRED `expr = true` for the keybinding
function M.toggleOrIncrement()
	local toggles = {
		["true"] = "false",
		["True"] = "False", -- python
		["const"] = "let", -- js
	}
	-- cannot use vim.cmd.normal, because it changes cursor position
	local cword = vim.fn.expand("<cword>")
	for word, opposite in pairs(toggles) do
		if cword == word then return '"_ciw' .. opposite .. "<Esc>" end
		if cword == opposite then return '"_ciw' .. word .. "<Esc>" end
	end
	return "<C-a>"
end

function M.toggleTitleCase()
	local prevCursor = vim.api.nvim_win_get_cursor(0)
	local cword = vim.fn.expand("<cword>")
	local cmd = cword == cword:lower() and "guiwgUl" or "guiw"
	vim.cmd.normal { cmd, bang = true }
	vim.api.nvim_win_set_cursor(0, prevCursor)
end

--------------------------------------------------------------------------------

function M.smartDuplicate()
	local originalLine = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = originalLine

	-- FILETYPE-SPECIFIC TWEAKS
	if vim.bo.ft == "css" then
		if line:find("top:") then
			line = line:gsub("top:", "bottom:")
		elseif line:find("bottom:") then
			line = line:gsub("bottom:", "top:")
		end
		if line:find("right:") then
			line = line:gsub("right:", "left:")
		elseif line:find("left:") then
			line = line:gsub("left:", "right:")
		end
	elseif vim.bo.ft == "javascript" or vim.bo.ft == "typescript" then
		if line:find("^%s*if.+{$") then line = line:gsub("^(%s*)if", "%1} else if") end
	elseif vim.bo.ft == "lua" then
		if line:find("^%s*if.+then%s*$") then line = line:gsub("^(%s*)if", "%1elseif") end
	elseif vim.bo.ft == "zsh" or vim.bo.ft == "bash" then
		if line:find("^%s*if.+then$") then line = line:gsub("^(%s*)if", "%1elif") end
	elseif vim.bo.ft == "python" then
		if line:find("^%s*if.+:$") then line = line:gsub("^(%s*)if", "%1elif") end
	end

	-- INSERT DUPLICATED LINE
	vim.api.nvim_buf_set_lines(0, row, row, false, { line })

	-- MOVE CURSOR DOWN, AND POTENTIALLY TO VALUE/FIELD
	local luadocFieldPos = vim.bo.ft == "lua" and select(3, line:find("%-%-%-@%w+ ()")) or nil
	local _, valuePos = line:find("[:=] %S")
	local newCol = luadocFieldPos or valuePos
	local targetCol = newCol and newCol - 1 or col
	vim.api.nvim_win_set_cursor(0, { row + 1, targetCol })
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
		vim.notify("Already at only changed file.", nil, notifyOpts)
	else
		vim.cmd.edit(targetFile)
	end
end

---Cycles files in folder in alphabetical order.
---If snacks.nvim is installed, adds cycling notification.
---@param direction "next"|"prev"
function M.nextFileInFolder(direction)
	local curPath = vim.api.nvim_buf_get_name(0)
	local curFile = vim.fs.basename(curPath)
	local curFolder = vim.fs.dirname(curPath)
	local ignoreExt = { "png", "svg", "webp", "jpg", "jpeg", "gif", "pdf", "zip" }

	local notifyOpts = {
		title = direction:sub(1, 1):upper() .. direction:sub(2) .. " file",
		icon = direction == "next" and "󰖽" or "󰖿",
		id = "next-in-folder", -- replace notifications when quickly cycling
		ft = "markdown", -- so h1 is highlighted
	}

	-- get list of files
	local itemsInFolder = vim.fs.dir(curFolder) -- INFO `fs.dir` already returns them sorted
	local filesInFolder = vim.iter(itemsInFolder):fold({}, function(acc, name, type)
		local ext = name:match("%.(%w+)$")
		if type ~= "file" or name:find("^%.") or vim.tbl_contains(ignoreExt, ext) then return acc end
		table.insert(acc, name) -- select only name
		return acc
	end)

	-- GUARD edge cases like if currently at a hidden file and there are only
	-- hidden files in the directory
	if #filesInFolder == 0 then
		local msg = "No valid files found in folder."
		vim.notify(msg, vim.log.levels.ERROR, notifyOpts)
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
	if not package.loaded["snacks"] then return end
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

--------------------------------------------------------------------------------

--- @param opts? vim.lsp.buf.format.Opts
function M.formatWithFallback(opts)
	local bufnr = (opts and opts.bufnr) or 0
	local formattingLsps = #vim.lsp.get_clients { method = "textDocument/formatting", bufnr = bufnr }

	if formattingLsps > 0 then
		if vim.bo[bufnr].ft == "markdown" then -- for efm-formatters that don't use stdin
			vim.api.nvim_buf_call(bufnr, function() vim.cmd("silent update") end)
		end
		vim.lsp.buf.format(opts)
	else
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd([[% substitute_\s\+$__e]]) -- remove trailing spaces
			vim.cmd([[% substitute _\(\n\n\)\n\+_\1_e]]) -- remove duplicate blank lines
			vim.cmd([[silent! /^\%(\n*.\)\@!/,$ delete]]) -- remove blanks at end of file
		end)
	end
end

--------------------------------------------------------------------------------
return M
