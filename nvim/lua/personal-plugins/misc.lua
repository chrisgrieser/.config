-- INFO A collection of commands that are too small to publish as plugins, but
-- too large to place in the main config, where they would clutter the actual
-- config. Each function is self-contained and should be bound to a keymap.
local M = {}
--------------------------------------------------------------------------------

-- Increment or toggle if cursor is on a "toggle-word" like true/false
-- (simplified version of dial.nvim)
function M.toggleOrIncrement()
	local toggles = {
		["true"] = "false",
		["yes"] = "no",
		["on"] = "off",
		["enable"] = "disable",
		["enabled"] = "disabled",

		["up"] = "down",
		["top"] = "bottom",
		["light"] = "dark",
		["right"] = "left",
		["width"] = "height",

		["min"] = "max",
		["next"] = "previous",
		["before"] = "after",
		["above"] = "below",
		["start"] = "end",
		["backward"] = "forward",
		["open"] = "close",
		["inner"] = "outer",
		["encode"] = "decode",
		["input"] = "output",

		["and"] = "or",
		["=="] = "!=",
		[">"] = "<",
		[">="] = "<=",
		["||"] = "&&",
	}
	if vim.bo.ft == "javascript" or vim.bo.ft == "typescript" then
		toggles["if"] = "else if" -- only one-way, due to the space in there
		toggles["const"] = "let"
		toggles["==="] = "!=="
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

	-- get cursor word
	local iskeywordPrev = vim.opt.iskeyword:get()
	vim.opt.iskeyword:remove { "_", "-" } -- so parts of words are picked up
	-- cword does not include punctuation-only words, so checking `cWORD` for that
	local cword = vim.fn.expand("<cWORD>"):find("^%p+$") and vim.fn.expand("<cWORD>")
		or vim.fn.expand("<cword>")

	-- toggle or increment
	local newWord
	for left, right in pairs(toggles) do
		if cword == left then newWord = right end
		if cword == right then newWord = left end
	end
	if newWord then -- a) toggle the word
		local prevCursor = vim.api.nvim_win_get_cursor(0)
		-- `iw` textobj does also work on punctuation only
		vim.cmd.normal { '"_ciw' .. newWord, bang = true }
		pcall(vim.api.nvim_win_set_cursor, 1, prevCursor)
	else -- b) increment
		-- needs `:execute` to escape `<C-a>`
		vim.cmd.execute([["normal! ]] .. vim.v.count1 .. [[\<C-a>"]])
	end

	vim.opt.iskeyword = iskeywordPrev
end

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

--------------------------------------------------------------------------------

function M.restartNeovide()
	assert(vim.g.neovide, "Requires neovide.")
	local script = [=[
		while pgrep -xq "neovide" ; do
			sleep 0.05
			i=$((i+1)) ; [[ $i -gt 50 ]] && return 1 # timeout
		done
		sleep 0.1
		[[ "$OSTYPE" =~ "darwin" ]] && open -a "neovide" || neovide # on macOS, use `open -a`
	]=]
	vim.system({ "zsh", "-c", script }, { detach = true }) -- detach to run after nvim quit
	vim.defer_fn(vim.cmd.wqall, 1)
end

function M.openCwdInTerminal()
	assert(jit.os == "OSX", "requires macOS' `open`")
	local cdCommand = (" cd -q %q && clear"):format(vim.uv.cwd() or "")
	local script = ([=[
		open -a "WezTerm" # focus/launch
		while ! pgrep -xq "wezterm-gui" ; do
			sleep 0.1
			i=$((i+1)) ; [[ $i -gt 20 ]] && return 1 # timeout
		done
		sleep 0.4
		echo %q | wezterm cli send-text --no-paste
	]=]):format(cdCommand)
	vim.system { "zsh", "-c", script }
end

---start/stop with just one keypress & add notifications
---@param toggleKey string key used to trigger this function
---@param reg string vim register (single letter)
function M.startOrStopRecording(toggleKey, reg)
	assert(#toggleKey == 1, "toggleKey must be a single character")
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

function M.openFirstUrlInBuffer()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for _, line in ipairs(lines) do
		local url = line:match("%l+://[^%s%)%]}\"'`>]+")
		if url then return vim.ui.open(url) end
	end
	vim.notify("No URL found in file.", vim.log.levels.WARN)
end

function M.smartDuplicate()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local ft = vim.bo.filetype

	-- filetype-specific tweaks
	if ft == "css" then
		-- stylua: ignore
		line = line:gsub("(%a+):", {
			top = "bottom", bottom = "top",
			right = "left", left = "right",
			light = "dark", dark = "light",
			width = "height", height = "width",
		})
	elseif ft == "javascript" or ft == "typescript" or ft == "swift" then
		line = line:gsub("^(%s*)if(.+{)$", "%1} else if%2")
	elseif ft == "lua" then
		line = line:gsub("^(%s*)if( .* then)$", "%1elseif%2")
	elseif ft == "zsh" or ft == "bash" then
		line = line:gsub("^(%s*)if( .* then)$", "%1elif%2")
	elseif ft == "python" then
		line = line:gsub("^(%s*)if( .*:)$", "%1elif%2")
	elseif ft == "markdown" then -- increment numbered list
		line = line:gsub("^(%s*)(%d+)%. ", function(indent, num)
			local increment = tonumber(num) + 1
			return indent .. increment .. ". "
		end)
	end

	-- insert duplicated line
	vim.api.nvim_buf_set_lines(0, row, row, false, { line })

	-- move cursor down, and to value/field (if any)
	local _, luadocFieldPos = line:find("%-%-%-@%w+ ")
	local _, valuePos = line:find("[:=] ")
	local targetCol = luadocFieldPos or valuePos or col
	vim.api.nvim_win_set_cursor(0, { row + 1, targetCol })
end

function M.openWorkflowInAlfredPrefs()
	local workflowUid =
		vim.api.nvim_buf_get_name(0):match("Alfred%.alfredpreferences/workflows/(.-)/")
	if not workflowUid then return vim.notify("Not in an Alfred directory.", vim.log.levels.WARN) end

	-- https://www.alfredforum.com/topic/18390-get-currently-edited-workflow-uri/
	local jxa = "Application('com.runningwithcrayons.Alfred')"
		.. (".revealWorkflow(%q)"):format(workflowUid)
	vim.system { "osascript", "-l", "JavaScript", "-e", jxa }
end

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

---@param lines integer
function M.scrollLspOrOtherWin(lines)
	-- 1. prio: LSP win
	local winid = vim.b.lsp_floating_preview --> stores id of last `vim.lsp`-generated win

	-- 2. prio: other win
	if not winid then
		local otherWin = vim.iter(vim.api.nvim_tabpage_list_wins(0)):find(function(win)
			local notFloating = vim.api.nvim_win_get_config(win).relative == ""
			local notThisWin = vim.api.nvim_get_current_win() ~= win
			return notFloating and notThisWin
		end)
		winid = otherWin
	end

	if not winid then
		vim.notify("No other window found.", vim.log.levels.WARN)
		return
	end
	vim.api.nvim_win_call(winid, function()
		local topline = vim.fn.winsaveview().topline
		vim.fn.winrestview { topline = topline + lines }
	end)
end

---1. works with negative numbers or floats, with `,` or `.` as decimal separator
---2. does support thousands separators
function M.sumOfAllNumbersInBuf()
	local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	local sum = 0
	for digits in text:gmatch("%-?%d+[,.]?%d*") do
		local num = digits:gsub(",", ".") -- `tonumber` expects `.` as decimal separator
		sum = sum + tonumber(num)
	end
	vim.notify(sum, nil, { title = "Sum", icon = "∑" })
end

--------------------------------------------------------------------------------
return M
