-- INFO A bunch of commands that are too small to be published as plugins, but
-- too big to put in the main config, where they would crowd the actual config.
-- Every function is self-contained and should be bound to a keymap.
local M = {}
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
		[">"] = "<",
		[">="] = "<=",
	}
	if vim.bo.ft == "javascript" or vim.bo.ft == "typescript" then
		toggles["if"] = "else if" -- only one-way, due to the space in there
		toggles["const"] = "let"
		toggles["==="] = "!=="
	elseif vim.bo.ft == "python" then
		toggles["True"] = "False"
		toggles["true"] = nil
	elseif vim.bo.ft == "swift" then
		toggles["var"] = "let"
	elseif vim.bo.ft == "zsh" or vim.bo.ft == "bash" or vim.bo.ft == "sh" then
		toggles["if"] = "elif"
		toggles["echo"] = "print"
	elseif vim.bo.ft == "lua" then
		toggles["if"] = "elseif"
		toggles["=="] = "~="
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
		local prevCursor = vim.api.nvim_win_get_cursor(0)
		-- `iw` textobj does also work on punctuation only
		vim.cmd.normal { '"_ciw' .. newWord, bang = true }
		vim.api.nvim_win_set_cursor(0, prevCursor)
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

	-- MOVE CURSOR DOWN, AND TO VALUE/FIELD (IF THERE IS ANY)
	local _, luadocFieldPos = line:find("%-%-%-@%w+ ")
	local _, valuePos = line:find("[:=] ")
	local targetCol = luadocFieldPos or valuePos or col
	vim.api.nvim_win_set_cursor(0, { row + 1, targetCol })
end

--------------------------------------------------------------------------------

function M.spellSuggest()
	local suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
	suggestions = vim.list_slice(suggestions, 1, 9)

	vim.ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" }, function(selection)
		if not selection then return end
		vim.cmd.normal { '"_ciw' .. selection, bang = true }
	end)
end

--------------------------------------------------------------------------------

function M.openWorkflowInAlfredPrefs()
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

function M.bufferInfo()
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
	local foldexpr = vim.wo.foldexpr:find("lsp") and "LSP" or "Treesitter"
	local indentExpr = (vim.bo.indentexpr and vim.bo.indentexpr:find("treesitter")) and "Treesitter"
		or "Vim"

	local out = {
		"[bufnr]       " .. vim.api.nvim_get_current_buf(),
		"[winid]       " .. vim.api.nvim_get_current_win(),
		"[filetype]    " .. (vim.bo.filetype == "" and '""' or vim.bo.filetype),
		"[buftype]     " .. (vim.bo.buftype == "" and '""' or vim.bo.buftype),
		"[indent]      " .. ("%s (%d)"):format(indentType, indentAmount),
		"[folds]       " .. ("%s (level %d)"):format(foldexpr, vim.wo.foldlevel),
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

function M.formatWithFallback()
	local formattingLsps = vim.lsp.get_clients { method = "textDocument/formatting", bufnr = 0 }
	local notifyOpts = { title = "Format", icon = "󱉯" }

	if #formattingLsps > 0 then
		-- save for efm-formatters that don't use stdin
		if vim.bo.ft == "markdown" then
			-- saving with explicit name prevents issues when changing `cwd`
			-- `:update!` suppresses "The file has been changed since reading it!!!"
			local vimCmd = ("silent update! %q"):format(vim.api.nvim_buf_get_name(0))
			vim.cmd(vimCmd)
		end
		vim.lsp.buf.format()

		-- FIX some LSPs trigger folding after formatting?
		vim.schedule(function() vim.cmd.normal { "zv", bang = true } end)
	else
		vim.cmd([[% substitute_\s\+$__e]]) -- remove trailing spaces
		vim.cmd([[% substitute _\(\n\n\)\n\+_\1_e]]) -- remove duplicate blank lines
		vim.cmd([[silent! /^\%(\n*.\)\@!/,$ delete]]) -- remove blanks at end of file

		vim.notify_once("Formatting with fallback.", nil, notifyOpts)
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
			config = client.config,
		}
		local opts = { icon = "󱈄", title = client.name .. " capabilities", ft = "lua" }
		local header = "-- For a full view, open in notification history.\n"
		vim.notify(header .. vim.inspect(info), vim.log.levels.DEBUG, opts)
	end)
end

--------------------------------------------------------------------------------
return M
