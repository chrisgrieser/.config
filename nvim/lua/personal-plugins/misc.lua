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
			local msg = vim.fn.keytrans(macro)
			vim.notify(msg, vim.log.levels.TRACE, { title = "Recorded", icon = "󰕧" })
		else
			vim.notify("Aborted.", vim.log.levels.TRACE, { title = "Recording", icon = "󰕧" })
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
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1
	local start, ending
	while true do
		start, ending = line:find(cword, ending or 1, true)
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

--------------------------------------------------------------------------------

function M.smartLineDuplicate()
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
	elseif vim.bo.ft == "sh" then
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
	-- get list of changed files
	local gitResponse = vim.system({ "git", "diff", "--numstat", "." }):wait()
	if gitResponse.code ~= 0 then
		vim.notify("Not in git repo.", vim.log.levels.WARN, { title = "Git" })
		return
	end
	local changedFiles = vim.split(gitResponse.stdout, "\n", { trimempty = true })
	local gitroot = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout)
	if #changedFiles == 0 then
		vim.notify("No files with changes found.", nil, { title = "Git" })
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
		vim.notify("Already at only changed file.", nil, { title = "Git" })
	else
		vim.cmd.edit(targetFile)
	end
end

---Cycles files in folder in alphabetical order.
---If snacks.nvim is installed, adds cycling notification.
---@param direction "Next"|"Prev"
function M.nextFileInFolder(direction)
	local curPath = vim.api.nvim_buf_get_name(0)
	local curFile = vim.fs.basename(curPath)
	local curFolder = vim.fs.dirname(curPath)
	local ignoreExt = { "png", "svg", "webp", "jpg", "jpeg", "gif", "pdf", "zip" }

	-- get list of files
	local itemsInFolder = vim.fs.dir(curFolder)
	local filesInFolder = vim.iter(itemsInFolder):fold({}, function(acc, name, type)
		local ext = name:match("%.(%w+)$")
		if type ~= "file" or name:find("^%.") or vim.tbl_contains(ignoreExt, ext) then return acc end
		table.insert(acc, name) -- select only name
		return acc
	end)
	-- INFO no need for sorting, since `fs.dir` already returns them sorted

	-- GUARD edge cases like if currently at a hidden file and there are only
	-- hidden files in the directory
	if #filesInFolder == 0 then
		local msg = "No valid files found in folder."
		vim.notify(msg, vim.log.levels.ERROR, { title = direction .. " file" })
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
	local nextIdx = curIdx + (direction == "Next" and 1 or -1)
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
	vim.notify(msg, nil, {
		title = direction .. (" (%d/%d)"):format(nextIdx, #filesInFolder),
		icon = direction == "Next" and "󰖽" or "󰖿",
		id = "next-in-folder", -- replace notifications when quickly cycling
		ft = "markdown", -- so h1 is highlighted
	})
end

--------------------------------------------------------------------------------

--- if cut off, requires higher notification height setting
function M.bufferInfo()
	local ok, node = pcall(vim.treesitter.get_node)
	local pseudoTilde = "∼" -- `U+223C` instead of real `~` to prevent md-strikethrough
	local lsps = vim.tbl_map(function(client)
		local pad = (" "):rep(math.min(10 - #client.name))
		local root = client.root_dir and client.root_dir:gsub("/Users/%w+", pseudoTilde)
			or "*Single file mode*"
		return ("[%s]%s%s"):format(client.name, pad, root)
	end, vim.lsp.get_clients { bufnr = 0 })

	local out = {
		"[filetype]  " .. vim.bo.filetype,
		"[buftype]   " .. (vim.bo.buftype == "" and '""' or vim.bo.buftype),
		("[indent]    %s (%s)"):format(vim.bo.expandtab and "spaces" or "tabs", vim.bo.tabstop),
		"[cwd]       " .. (vim.uv.cwd() or "nil"):gsub("/Users/%w+", "~"),
		"",
		"**At cursor**",
		"[word]      " .. vim.fn.expand("<cword>"),
		(ok and node) and ("[node-type] " .. node:type()) or nil,
		"",
		"**Attached LSPs with root**",
		unpack(lsps),
	}
	local opts = { title = "Buffer info", icon = "󰽙", timeout = false }
	vim.notify(table.concat(out, "\n"), vim.log.levels.DEBUG, opts)
end

--------------------------------------------------------------------------------
return M
