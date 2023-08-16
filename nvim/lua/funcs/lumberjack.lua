local M = {}
--------------------------------------------------------------------------------
local fn = vim.fn
local bo = vim.bo
local g = vim.g
local cmd = vim.cmd
local expand = vim.fn.expand
local logWarn = vim.log.levels.WARN

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

--------------------------------------------------------------------------------

-- CONFIG
local marker = "🪓"
local beepEmojis = { "🤖", "👽", "👾", "💣" }

--------------------------------------------------------------------------------

---in normal mode, returns word under cursor, in visual mode, returns selection
---@return string?
local function getVar()
	local varname
	if fn.mode() == "n" then
		local node = vim.treesitter.get_node()
		if node then
			varname = vim.treesitter.get_node_text(node, 0):gsub("[\n\r].*", "")
		else
			varname = expand("<cword>")
		end
	elseif fn.mode():find("[Vv]") then
		local prevReg = fn.getreg("z")
		normal('"zy')
		varname = fn.getreg("z"):gsub('"', '//"')
		fn.setreg("z", prevReg)
	end
	return varname
end

---append string below current line
---@param text string
local function append(text)
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { text })
	normal("j==")
end

--------------------------------------------------------------------------------

function M.messageLog()
	local ft = bo.filetype
	local templateStr

	if ft == "lua" then
		templateStr = 'print("%s ")'
		-- FIX for noice.nvim print-bug: https://github.com/folke/noice.nvim/issues/556
		if expand("%:p"):find("nvim") then templateStr = 'vim.notify("%s ")' end
	elseif ft == "python" then
		templateStr = 'print("%s ")'
	elseif ft == "javascript" or ft == "typescript" then
		templateStr = 'console.log("%s ");'
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		templateStr = 'echo "%s "'
	elseif ft == "applescript" then
		templateStr = 'log "%s "'
	else
		vim.notify("🪓 MessageLog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = templateStr:format(marker)
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
		if expand("%:p"):find("nvim") then templateStr = 'vim.notify("%s %s: ".. %s)' end
	elseif ft == "python" then
		templateStr = 'print("%s %s:", %s)'
	elseif ft == "javascript" or ft == "typescript" then
		templateStr = 'console.log("%s %s:", %s);'
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		templateStr = 'echo "%s %s: $%s"'
	elseif ft == "applescript" then
		templateStr = 'log "%s %s:" & %s'
	elseif ft == "css" or ft == "scss" then
		templateStr = "outline: 2px solid red !important; /* %s */"
	else
		vim.notify("🪓 VariableLog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = templateStr:format(marker, varname, varname)
	append(logStatement)
end

function M.objectLog()
	local varname = getVar()
	local templateStr
	local ft = bo.filetype

	if ft == "lua" and expand("%:p"):find("nvim") then
		 templateStr = 'vim.notify("%s %s: " .. vim.inspect(%s))'
	elseif ft == "javascript" then
		templateStr = 'console.log("%s %s:", JSON.stringify(%s))'
	else
		vim.notify("🪓 Objectlog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = templateStr:format(marker, varname, varname)
	append(logStatement)
end

---adds simple "beep" log statement to check whether conditionals have been
---triggered. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.beepLog()
	local templateStr
	local ft = bo.filetype

	local randomEmoji = beepEmojis[math.random(1, #beepEmojis)]

	if ft == "lua" or ft == "python" then
		-- FIX for noice.nvim print-bug: https://github.com/folke/noice.nvim/issues/556
		if expand("%:p"):find("nvim") and ft == "lua" then templateStr = 'vim.notify("%s %s: ".. %s)' end
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
		vim.notify("🪓 Beeplog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = templateStr:format(marker, randomEmoji)
	append(logStatement)
end

function M.timeLog()
	if g.timelogStart == nil then g.timelogStart = true end
	local logStatement1, logStatement2
	local ft = bo.filetype

	if ft == "lua" then
		logStatement1 = {
			'print("%s timelog start")',
			"local timelogStart = os.time() -- %s",
		}
		logStatement2 = {
			"local durationSecs = os.difftime(os.time(), timelogStart) -- %s",
			'print("%s timelog:", durationSecs, "s")',
		}
	elseif ft == "javascript" then
		-- JXA does not support console.time()
		logStatement1 = {
			'console.log("%s timelog start");',
			"const timelogStart = +new Date(); // %s",
		}
		logStatement2 = {
			"const durationSecs = (+new Date() - timelogStart) / 1000; // %s",
			'console.log("%s timelog:", durationSecs, "s");',
		}
	elseif ft == "typescript" then
		logStatement1 = {
			'console.time("timelog");',
		}
		logStatement2 = {
			'console.timeEnd("timelog");',
		}
	elseif ft == "bash" or ft == "zsh" or ft == "sh" or ft == "fish" then
		logStatement1 = {
			"timelogStart=$(date +%s) # %s",
			'echo "%s time start"',
		}
		logStatement2 = {
			"timelogEnd=$(date +%s) && durationSecs = $((timelogEnd - timelogStart)) # %s",
			'echo "%s time ${durationSecs}s"',
		}
	else
		vim.notify("🪓 Timelog does not support " .. ft .. " yet.", logWarn)
		return
	end
	local statementToUse = g.timelogStart and logStatement1 or logStatement2
	for _, line in pairs(statementToUse) do
		append(line:format(marker))
	end
	g.timelogStart = not g.timelogStart
end

-- simple debug statement
function M.debugLog()
	local logStatement
	local ft = bo.filetype

	if ft == "javascript" or ft == "typescript" then
		logStatement = "debugger // %s"
	else
		vim.notify("Debuglog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(logStatement:format(marker))
end

---Remove all log statements in the current buffer
---Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.removeLogs()
	local numOfLinesBefore = fn.line("$")

	-- escape for vim regex, in case `[]` are used in the marker
	local toRemove = marker:gsub("%]", "\\]"):gsub("%[", "\\[")
	cmd(("silent g/%s/d"):format(toRemove))
	cmd.nohlsearch()

	local linesRemoved = numOfLinesBefore - fn.line("$")
	local msg = ("󰣈  Removed %s log statements."):format(linesRemoved)
	if linesRemoved == 1 then msg = msg:sub(1, -3) .. "." end
	vim.notify(msg)

	g.timelogCount = 0 -- reset timelog
end

--------------------------------------------------------------------------------

return M
