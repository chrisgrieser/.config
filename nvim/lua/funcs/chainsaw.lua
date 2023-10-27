local M = {}
--------------------------------------------------------------------------------
local fn = vim.fn
local bo = vim.bo
local cmd = vim.cmd

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---send notification
---@param funcname string
local function noSupportNotif(funcname)
	local msg = funcname .. " does not support " .. bo.filetype .. " yet."
	vim.notify(msg, vim.log.levels.WARN, { title = "Chainsaw" })
end

local function isNvimLua()
	return vim.fn.expand("%:p"):find("nvim")
end

--------------------------------------------------------------------------------

-- CONFIG
local config = {
	marker = "🪚",
	beepEmojis = { "🤖", "👽", "👾", "💣" }
} 

--------------------------------------------------------------------------------

---in normal mode, returns word under cursor, in visual mode, returns selection
---@return string?
local function getVar()
	local varname
	local isVisualMode = fn.mode():find("[Vv]")
	if isVisualMode then
		local prevReg = fn.getreg("z")
		normal('"zy')
		varname = fn.getreg("z"):gsub('"', '//"')
		fn.setreg("z", prevReg)
	else
		local node = vim.treesitter.get_node()
		if not node then return "" end
		varname = vim.treesitter.get_node_text(node, 0)
	end
	return varname
end

---append string below current line
---@param text string
local function append(text)
	local ln = vim.api.nvim_win_get_cursor(0)[1]

	if vim.bo.ft == "python" then
		local indent = vim.api.nvim_get_current_line():match("^%s*")
		text = indent .. text
		vim.api.nvim_buf_set_lines(0, ln, ln, false, { text })
	else
		vim.api.nvim_buf_set_lines(0, ln, ln, false, { text })
		normal("j==")
	end
end

--------------------------------------------------------------------------------

function M.messageLog()
	local ft = bo.filetype
	local templateStr

	if ft == "lua" then
		templateStr = 'print("%s ")'
		-- FIX for noice.nvim print-bug: https://github.com/folke/noice.nvim/issues/556
		if isNvimLua() then templateStr = 'vim.notify("%s ")' end
	elseif ft == "python" then
		templateStr = 'print("%s ")'
	elseif ft == "javascript" or ft == "typescript" then
		templateStr = 'console.log("%s ");'
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		templateStr = 'echo "%s "'
	elseif ft == "applescript" then
		templateStr = 'log "%s "'
	else
		noSupportNotif("Message Log")
		return
	end

	local logStatement = templateStr:format(config.marker)
	append(logStatement)
	-- goto insert mode at correct location
	normal('f";') -- goto second `"`
	cmd.startinsert()
end

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.variableLog()
	local varname = getVar()
	local templateStr
	local ft = bo.filetype

	if ft == "lua" then
		templateStr = 'print("%s %s: ".. %s)'
		-- FIX for noice.nvim print-bug: https://github.com/folke/noice.nvim/issues/556
		if isNvimLua() then templateStr = 'vim.notify("%s %s: " .. tostring(%s))' end
	elseif ft == "python" then
		templateStr = 'print(f"%s {%s = }")'
	elseif ft == "javascript" or ft == "typescript" then
		templateStr = 'console.log("%s %s:", %s);'
	elseif ft == "zsh" or ft == "bash" or ft == "sh" then
		templateStr = 'echo "%s %s: $%s"'
	elseif ft == "applescript" then
		templateStr = 'log "%s %s:" & %s'
	elseif ft == "css" or ft == "scss" then
		templateStr = "outline: 2px solid red !important; /* %s */"
	else
		noSupportNotif("Variable Log")
		return
	end

	local logStatement = templateStr:format(config.marker, varname, varname)
	append(logStatement)
end

function M.assertLog()
	local templateStr
	local varname = getVar()

	local ft = bo.filetype
	if ft == "lua" then
		templateStr = 'assert(%s, "%s %s")'
	elseif ft == "python" then
		templateStr = 'assert %s, "%s %s"'
	else
		noSupportNotif("Assert Log")
		return
	end

	local logStatement = templateStr:format(varname, config.marker, varname)
	append(logStatement)
	normal("f,") -- goto the comma to edit the condition
end

function M.objectLog()
	local varname = getVar()
	local templateStr
	local ft = bo.filetype

	if ft == "lua" and isNvimLua() then
		templateStr = 'vim.notify("%s %s: " .. vim.inspect(%s))'
	elseif ft == "javascript" then
		templateStr = 'console.log("%s %s:", JSON.stringify(%s))'
	else
		noSupportNotif("Object Log")
		return
	end

	local logStatement = templateStr:format(config.marker, varname, varname)
	append(logStatement)
end

---adds simple "beep" log statement to check whether conditionals have been
---triggered. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.beepLog()
	local templateStr
	local ft = bo.filetype
	local randomEmoji = config.beepEmojis[math.random(1, #config.beepEmojis)]

	if isNvimLua() and ft == "lua" then
		-- FIX for noice.nvim print-bug: https://github.com/folke/noice.nvim/issues/556
		templateStr = 'vim.notify("%s beep %s")'
	elseif ft == "lua" or ft == "python" then
		templateStr = 'print("%s beep %s")'
	elseif ft == "javascript" or ft == "typescript" then
		templateStr = 'console.log("%s beep %s");'
	elseif ft == "zsh" or ft == "bash" or ft == "sh" then
		templateStr = 'echo "%s beep %s"'
	elseif ft == "applescript" then
		templateStr = "beep -- %s"
	elseif ft == "css" or ft == "scss" then
		templateStr = "outline: 2px solid red !important; /* %s */"
	else
		noSupportNotif("Beep Log")
		return
	end

	local logStatement = templateStr:format(config.marker, randomEmoji)
	append(logStatement)
end

--------------------------------------------------------------------------------

function M.timeLog()
	if vim.b.timelogStart == nil then vim.b.timelogStart = true end ---@diagnostic disable-line: inject-field
	local start, stop
	local ft = bo.filetype

	if ft == "lua" then
		start = { "local timelogStart = os.time() -- %s" }
		stop = {
			"local durationSecs = os.difftime(os.time(), timelogStart) -- %s",
			'print("%s:", durationSecs, "s")',
		}
	elseif ft == "python" then
		start = { "timelogStart = time.perf_counter()  # %s" }
		stop = {
			"durationSecs = round(time.perf_counter() - timelogStart, 3)  # %s",
			'print(f"%s: {durationSecs}s")',
		}
	elseif ft == "javascript" then
		-- JXA does not support console.time()
		start = { "const timelogStart = +new Date(); // %s" }
		stop = {
			"const durationSecs = (+new Date() - timelogStart) / 1000; // %s",
			'console.log(`%s: ${durationSecs}s`);',
		}
	elseif ft == "typescript" then
		start = { 'console.time("timelog"); // %s' }
		stop = { 'console.timeEnd("timelog"); // %s' }
	elseif ft == "bash" or ft == "zsh" or ft == "sh" or ft == "fish" then
		start = { "timelogStart=$(date +%s) # %s" }
		stop = {
			"timelogEnd=$(date +%s) && durationSecs = $((timelogEnd - timelogStart)) # %s",
			'echo "%s time ${durationSecs}s"',
		}
	else
		noSupportNotif("Time Log")
		return
	end
	local statementToUse = vim.b.timelogStart and start or stop
	for _, line in pairs(statementToUse) do
		append(line:format(config.marker))
	end
	vim.b.timelogStart = not vim.b.timelogStart ---@diagnostic disable-line: inject-field
end

-- simple debug statement
function M.debugLog()
	local logStatement
	local ft = bo.filetype

	if ft == "javascript" or ft == "typescript" then
		logStatement = "debugger; // %s"
	elseif ft == "python" then
		logStatement = "breakpoint()  # %s"
	else
		noSupportNotif("Debug Log")
		return
	end

	append(logStatement:format(config.marker))
end

---Remove all log statements in the current buffer
function M.removeLogs()
	local numOfLinesBefore = vim.api.nvim_buf_line_count(0)

	-- escape for vim regex, in case `[]` are used in the marker
	local toRemove = config.marker:gsub("%]", "\\]"):gsub("%[", "\\[")
	cmd(("silent g/%s/d"):format(toRemove))
	cmd.nohlsearch()

	local linesRemoved = numOfLinesBefore - vim.api.nvim_buf_line_count(0)
	local msg = ("Removed %s log statements."):format(linesRemoved)
	if linesRemoved == 1 then msg = msg:sub(1, -3) .. "." end -- 1 = singular
	vim.notify(msg, vim.log.levels.INFO, { title = "Chainsaw" })

	---@diagnostic disable-next-line: inject-field
	vim.b.timelogStart = false -- reset timelog
end

--------------------------------------------------------------------------------

return M
