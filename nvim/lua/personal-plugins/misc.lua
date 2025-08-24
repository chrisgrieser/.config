-- INFO A bunch of commands that are too small to be published as plugins, but
-- too big to put in the main config, where they would crowd the actual config.
-- Every function is self-contained and should be bound to a keymap.
local M = {}
--------------------------------------------------------------------------------

--- inspired by ultimate-autopair's fastWarp function
---@param dir "forward"|"backward"
function M.fastWarp(dir)
	local config = {
		warpChars = { ")", "]", "}", '"', "'", "`", "*" },
		patterns = {
			word = "[%w_]+",
			punctuationButNotBackslash = "[^\\%w_%s]+",
			escapedChar = "\\%w",
		},
	}
	-----------------------------------------------------------------------------

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local nextChar = line:sub(col + 1, col + 1)
	if not vim.tbl_contains(config.warpChars, nextChar) then return end

	---@param text string
	---@param patterns table<string, string> -- key is irrelevant, just for readability
	---@return number?
	local function findClosest(text, patterns)
		local distances = {}
		for _, pattern in pairs(patterns) do
			local _, stop = text:find(pattern)
			table.insert(distances, stop or math.huge)
		end
		local closest = math.min(unpack(distances))
		if closest == math.huge then return end
		return closest
	end

	local lineBefore, lineAfter = line:sub(1, col), line:sub(col + 2)
	local shift
	if dir == "forward" then
		shift = findClosest(lineAfter, config.patterns)
		if not shift then return end
		lineAfter = lineAfter:sub(1, shift) .. nextChar .. lineAfter:sub(shift + 1)
	elseif dir == "backward" then
		shift = findClosest(lineBefore:reverse(), config.patterns)
		if not shift then return end
		lineBefore = (
			lineBefore:reverse():sub(1, shift)
			.. nextChar
			.. lineBefore:reverse():sub(shift + 1)
		)
		lineBefore = lineBefore:reverse()
		shift = shift * -1
	end

	vim.api.nvim_set_current_line(lineBefore .. lineAfter)
	vim.api.nvim_win_set_cursor(0, { row, col + shift })
end

--------------------------------------------------------------------------------

---start/stop with just one keypress & add notifications
---@param toggleKey string key used to trigger this function
---@param reg string vim register (single letter)
function M.startOrStopRecording(toggleKey, reg)
	local notRecording = vim.fn.reg_recording() == ""
	if notRecording then
		vim.cmd.normal { "q" .. reg, bang = true } -- start recording to register
		return
	end

	local prevMacro = vim.fn.getreg(reg)
	vim.cmd.normal { "q", bang = true }
	local macro = vim.fn.getreg(reg):sub(1, -(#toggleKey + 1)) -- since the key itself is also recorded
	if macro ~= "" then
		vim.fn.setreg(reg, macro)
		local msg = vim.fn.keytrans(macro)
		vim.notify(msg, vim.log.levels.TRACE, { title = "Recorded", icon = "󰃽" })
	else
		vim.fn.setreg(reg, prevMacro) -- prevent `toggleKey` filling the register
		vim.notify("Aborted.", vim.log.levels.TRACE, { title = "Recording", icon = "󰃾" })
	end
end

---@param reg string vim register (single letter)
function M.playRecording(reg)
	local hasRecording = vim.fn.getreg(reg) ~= ""
	if hasRecording then
		vim.cmd.normal { "@" .. reg, bang = true }
	else
		local msg = "There is no recording."
		vim.notify(msg, vim.log.levels.WARN, { title = "Recording", icon = "󰃾" })
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
		local snake_cased = cword:gsub(camelPattern, "%1_%2"):lower()
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
		["start"] = "end",
		["backward"] = "forward",
		["true"] = "false",
		["light"] = "dark",
		["right"] = "left",
		["top"] = "bottom",
		["enable"] = "disable",
		["enabled"] = "disabled",
		["open"] = "close",
		["yes"] = "no",
		["on"] = "off",
		["and"] = "or",
		["=="] = "!=",
		[">"] = "<",
		[">="] = "<=",
	}
	if vim.bo.ft == "javascript" or vim.bo.ft == "typescript" then
		toggles["if"] = "else if" -- only one-way, due to the space in there
		toggles["const"] = "let"
		toggles["==="] = "!=="
		toggles["||"] = "&&"
	elseif vim.bo.ft == "python" then
		toggles["True"] = "False"
	elseif vim.bo.ft == "swift" then
		toggles["var"] = "let"
	elseif vim.bo.ft == "zsh" or vim.bo.ft == "bash" or vim.bo.ft == "sh" then
		toggles["if"] = "elif"
		toggles["echo"] = "print"
		toggles["||"] = "&&"
	elseif vim.bo.ft == "lua" then
		toggles["if"] = "elseif"
		toggles["=="] = "~="
	end
	-----------------------------------------------------------------------------

	-- get cursor word
	local iskeywordPrev = vim.opt.iskeyword:get()
	vim.opt.iskeyword:remove { "_", "-" } -- so parts of words are picked up
	-- cword does not include punctuation-only words, so checking `cWORD` for that
	local cword = vim.fn.expand("<cWORD>"):find("^%p+$") and vim.fn.expand("<cWORD>")
		or vim.fn.expand("<cword>")

	-- insert new word OR increment
	local newWord
	for word, opposite in pairs(toggles) do
		if cword == word then newWord = opposite end
		if cword == opposite then newWord = word end
	end
	if newWord then
		local prevCursor = vim.api.nvim_win_get_cursor(0)
		-- `iw` textobj does also work on punctuation only
		vim.cmd.normal { '"_ciw' .. newWord, bang = true }
		pcall(vim.api.nvim_win_set_cursor, 1, prevCursor)
	else
		-- needs `:execute` to escape `<C-a>`
		vim.cmd.execute([["normal! ]] .. vim.v.count1 .. [[\<C-a>"]])
	end

	vim.opt.iskeyword = iskeywordPrev
end

--------------------------------------------------------------------------------

function M.openUrlInBuffer()
	local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	local urls = {}
	for url in text:gmatch([[%l%l%l+://[^%s)%]}"'`>]+]]) do
		urls[#urls + 1] = url
	end

	if #urls == 0 then return vim.notify("No URL found in file.", vim.log.levels.WARN) end
	if #urls == 1 then return vim.ui.open(urls[1]) end

	vim.ui.select(urls, { prompt = " Open URL:" }, function(url)
		if url then vim.ui.open(url) end
	end)
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
	elseif ft == "javascript" or ft == "typescript" or ft == "swift" then
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

	-- MOVE CURSOR DOWN, AND TO VALUE/FIELD (IF THERE IS ANY)
	local _, luadocFieldPos = line:find("%-%-%-@%w+ ")
	local _, valuePos = line:find("[:=] ")
	local targetCol = luadocFieldPos or valuePos or col
	vim.api.nvim_win_set_cursor(0, { row + 1, targetCol })
end

--------------------------------------------------------------------------------

function M.openWorkflowInAlfredPrefs()
	local workflowUid =
		vim.api.nvim_buf_get_name(0):match("Alfred%.alfredpreferences/workflows/(.-)/")
	if not workflowUid then return vim.notify("Not in an Alfred directory.", vim.log.levels.WARN) end

	-- https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local jxa = ('Application("com.runningwithcrayons.Alfred").revealWorkflow(%q)'):format(
		workflowUid
	)
	vim.system { "osascript", "-l", "JavaScript", "-e", jxa }
end

--------------------------------------------------------------------------------

function M.inspectBuffer()
	local pseudoTilde = "∼" -- HACK `U+223C` instead of real `~` to prevent markdown-strikethrough

	local clients = vim.lsp.get_clients { bufnr = 0 }
	local longestName = vim.iter(clients)
		:fold(0, function(acc, client) return math.max(acc, #client.name) end)
	local lsps = vim.tbl_map(function(client)
		local pad = (" "):rep(math.min(longestName - #client.name) --[[@as integer]]) .. " "
		local root = client.root_dir and client.root_dir:gsub(vim.env.HOME, pseudoTilde)
			or "*Single file mode*"
		return ("[%s]%s%s"):format(client.name, pad, root)
	end, clients)

	local indentType = vim.bo.expandtab and "spaces" or "tabs"
	local indentAmount = vim.bo.expandtab and vim.bo.shiftwidth or vim.bo.tabstop
	local foldprovider = vim.wo.foldmethod ---@type string
	if vim.wo.foldexpr:find("lsp") then foldprovider = "LSP" end
	if vim.wo.foldexpr:find("treesitter") then foldprovider = "Treesitter" end
	local indentExpr = (vim.bo.indentexpr and vim.bo.indentexpr:find("treesitter")) and "Treesitter"
		or "Vim"

	local out = {
		"[bufnr]       " .. vim.api.nvim_get_current_buf(),
		"[winid]       " .. vim.api.nvim_get_current_win(),
		"[filetype]    " .. (vim.bo.filetype == "" and '""' or vim.bo.filetype),
		"[buftype]     " .. (vim.bo.buftype == "" and '""' or vim.bo.buftype),
		"[indent]      " .. ("%s (%d)"):format(indentType, indentAmount),
		"[folds]       " .. ("%s (level %d)"):format(foldprovider, vim.wo.foldlevel),
		"[indentexpr]  " .. indentExpr,
		"[cwd]         " .. (vim.uv.cwd() or "nil"):gsub(vim.env.HOME, pseudoTilde),
		"",
	}
	if #lsps > 0 then
		vim.list_extend(out, { "**Attached LSPs**", unpack(lsps) })
	else
		vim.list_extend(out, { "*No LSPs attached.*" })
	end
	local opts = { title = "Inspect buffer", icon = "󰽙", timeout = 10000 }
	vim.notify(table.concat(out, "\n"), vim.log.levels.DEBUG, opts)
end

--------------------------------------------------------------------------------

function M.lspCapabilities()
	local clients = vim.lsp.get_clients { bufnr = 0 }
	if #clients == 0 then
		vim.notify("No LSPs attached.", vim.log.levels.WARN, { icon = "󱈄" })
		return
	end
	vim.ui.select(clients, {
		prompt = "󱈄 Select LSP:",
		format_item = function(client) return client.name end,
	}, function(client)
		if not client then return end
		vim.notify(
			vim.inspect(vim.lsp.config[client.name]),
			vim.log.levels.DEBUG,
			{ icon = "󱈄", title = client.name .. " capabilities", ft = "lua" }
		)
	end)
end

--------------------------------------------------------------------------------
return M
