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
		["=="] = "!=",
		["||"] = "&&",
	}
	if vim.bo.ft == "javascript" or vim.bo.ft == "typescript" then
		toggles["const"] = "let"
		toggles["==="] = "!=="
	elseif vim.bo.ft == "python" then
		toggles["True"] = "False"
		toggles["true"] = nil
		toggles["and"] = "or"
	elseif vim.bo.ft == "swift" then
		toggles["var"] = "let"
	elseif vim.bo.ft == "lua" then
		toggles["=="] = "~="
		toggles["and"] = "or"
	end

	-- cword does not include punctuation-only words, so checking `cWORD` for that
	local cword = vim.fn.expand("<cWORD>"):find("^%p+$") and vim.fn.expand("<cWORD>")
		or vim.fn.expand("<cword>")
	local newWord
	for word, opposite in pairs(toggles) do
		if cword == word then newWord = opposite end
		if cword == opposite then newWord = word end
	end
	if newWord then
		-- `iw` textobj does also work on punctuation only
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

	-- MOVE CURSOR DOWN, AND TO VALUE/FIELD (IF EXISTS)
	local _, luadocFieldPos = line:find("%-%-%-@%w+ ")
	local _, valuePos = line:find("[:=][:=]? ")
	local targetCol = luadocFieldPos or valuePos or col
	vim.api.nvim_win_set_cursor(0, { row + 1, targetCol })
end

--------------------------------------------------------------------------------

function M.spellSuggest()
	local limit = 9
	local suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
	suggestions = vim.list_slice(suggestions, 1, limit)

	vim.ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" }, function(selection)
		if selection then return end
		vim.cmd.normal { '"_ciw' .. selection, bang = true }
	end)
end

--------------------------------------------------------------------------------

function M.bufferInfo()
	local pseudoTilde = "∼" -- HACK `U+223C` instead of real `~` to prevent md-strikethrough

	local clients = vim.lsp.get_clients { bufnr = 0 }
	local longestName = vim.iter(clients)
		:fold(0, function(acc, client) return math.max(acc, #client.name) end)
	local lsps = vim.tbl_map(function(client)
		local pad = (" "):rep(math.min(longestName - #client.name)) .. " "
		local root = client.root_dir and client.root_dir:gsub("/Users/%w+", pseudoTilde)
			or "*Single file mode*"
		return ("[%s]%s%s"):format(client.name, pad, root)
	end, clients)

	local indentType = vim.bo.expandtab and "spaces" or "tabs"
	local indentAmount = vim.bo.expandtab and vim.bo.shiftwidth or vim.bo.tabstop
	local foldexpr = vim.wo.foldexpr:find("lsp") and "LSP" or "TS"

	local out = {
		"[bufnr]     " .. vim.api.nvim_get_current_buf(),
		"[winid]     " .. vim.api.nvim_get_current_win(),
		"[filetype]  " .. (vim.bo.filetype == "" and '""' or vim.bo.filetype),
		"[buftype]   " .. (vim.bo.buftype == "" and '""' or vim.bo.buftype),
		"[indent]    " .. ("%s (%d)"):format(indentType, indentAmount),
		"[folds]     " .. ("%s (%d)"):format(foldexpr, vim.wo.foldlevel),
		"[cwd]       " .. (vim.uv.cwd() or "nil"):gsub("/Users/%w+", pseudoTilde),
		"",
	}
	if #lsps > 0 then
		vim.list_extend(out, { "**Attached LSPs with root**", unpack(lsps) })
	else
		vim.list_extend(out, { "*No LSPs attached.*" })
	end
	local opts = { title = "Inspect buffer", icon = "󰽙", timeout = 10000 }
	vim.notify(table.concat(out, "\n"), vim.log.levels.DEBUG, opts)
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
		vim.notify("Formatting with fallback.", nil, { title = "Format", icon = "󱉯" })
	end
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
		local info = {
			capabilities = client.capabilities,
			server_capabilities = client.server_capabilities,
		}
		local opts = { icon = "󱈄", title = client.name .. " capabilities", ft = "lua" }
		local header = "-- For a full view, open in notification history.\n"
		vim.notify(header .. vim.inspect(info), vim.log.levels.DEBUG, opts)
	end)
end

--------------------------------------------------------------------------------

---@param direction "up"|"down"
function M.goIndent(direction)
	local function getLine(lnum) return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] end

	local row = vim.api.nvim_win_get_cursor(0)[1]
	local curIndent = vim.fn.indent(row)
	local lastLine = vim.api.nvim_buf_line_count(0)
	if curIndent == 0 then return end

	-- find next row above with lower indent
	local upIndent
	local upLineText
	repeat
		row = row + (direction == "up" and -1 or 1)
		if row == 0 or row > lastLine then return end
		upIndent = vim.fn.indent(row)
		upLineText = getLine(row)
		local notBlank = upLineText:find("%S")
	until upIndent < curIndent and notBlank

	local col = upLineText:find("%S") - 1
	vim.api.nvim_win_set_cursor(0, { row, col })
end

--------------------------------------------------------------------------------

---silence `E486: pattern not found` when pressing `CR` in cmdline
do
	local function notFoundMsg(query)
		local msg = ("[%s] not found."):format(query)
		vim.notify(msg, vim.log.levels.TRACE, { icon = " ", style = "minimal" })
	end

	---@param key "n"|"N"
	function M.silentN(key)
		local searchQuery = vim.fn.getreg("/")
		local found = vim.fn.search(searchQuery, "n") > 0 -- `n` = no movement
		if found then
			vim.cmd.normal { key, bang = true }
		else
			notFoundMsg(searchQuery)
		end
	end

	---needs to be bound to `cmap`
	function M.silentCR()
		local function feedkey(k)
			local esc = vim.api.nvim_replace_termcodes(k, true, true, true)
			vim.api.nvim_feedkeys(esc, "n", false)
		end
		if vim.fn.getcmdtype() ~= "/" then
			feedkey("<CR>")
			return
		end

		local searchQuery = vim.fn.getcmdline()
		local found = vim.fn.search(searchQuery, "n") > 0 -- `n` = no movement

		if found then
			feedkey("<CR>")
		else
			feedkey("<C-c>") -- leaving cmdline via `Esc` somehow does not work
			notFoundMsg(searchQuery)
		end
	end
end

function M.countLspRefs()
	local count = { file = {}, workspace = {} }
	local params = vim.lsp.util.make_position_params(0, "utf-32")
	local thisFileUri = params.textDocument.uri

	local ids = vim.lsp.buf_request(0, "textDocument/references", params, function(error, refs)
		if error then
			vim.notify(error.message, vim.log.levels.ERROR)
			return
		end
		if not refs then return end
		count.workspace.references = #refs
		count.file.references = vim.iter(refs):fold(0, function(acc, ref)
			if thisFileUri == ref.uri then acc = acc + 1 end
			return thisFileUri == ref.uri and acc or acc + 1
		end)
	end)
	Chainsaw(ids) -- 🪚
	-- vim.lsp.buf_request(0, "textDocument/definition", params, function(error, defs)
	-- 	if error then
	-- 		vim.notify(error.message, vim.log.levels.ERROR)
	-- 		return
	-- 	end
	-- 	if not defs then return end
	-- 	count.file.definitions = vim.iter(defs):fold(0, function(acc, def)
	-- 		if thisFileUri == def.uri then acc = acc + 1 end
	-- 		return thisFileUri == def.uri and acc or acc + 1
	-- 	end)
	-- end)
end

--------------------------------------------------------------------------------
return M
