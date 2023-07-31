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
local marker = "[QL]"

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

---append string below current line, if text is array of strings, append each
---element as separate line
---@param text string
local function append(text)
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, ln, ln, false, {text})
	normal("j==")
end

--------------------------------------------------------------------------------

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.log()
	local varname = getVar()
	local templateStr
	local ft = bo.filetype

	if ft == "lua" then
		templateStr = 'print("%s %s: ".. %s)'
	elseif ft == "python" then
		templateStr = 'print("%s %s:", %s)'
	elseif ft == "javascript" or ft == "typescript" then
		templateStr = 'console.log("%s:", %s);'
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		templateStr = 'echo "%s %s: $%s"'
	elseif ft == "applescript" then
		templateStr = 'log "%s %s:" & %s'
	elseif ft == "css" or ft == "scss" then
		templateStr = "outline: 2px solid red !important;"
	else
		vim.notify("Quicklog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = string.format(templateStr, marker, varname, varname)
	append(logStatement)
end

function M.objectlog()
	local varname = getVar()
	local templateStr
	local ft = bo.filetype

	if ft == "javascript" then
		templateStr = 'console.log("%s %s:", JSON.stringify(%s))'
	else
		vim.notify("Objectlog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = templateStr:format(marker, varname, varname)
	append(logStatement)
end

---adds simple "beep" log statement to check whether conditionals have been
---triggered. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.beeplog()
	local templateStr
	local ft = bo.filetype

	local emojis = { "🤖", "👽", "👾", "💣" }
	local randomEmoji = emojis[math.random(1, #emojis)]

	if ft == "lua" or ft == "python" then
		templateStr = 'print("%s %s beep")'
	elseif ft == "javascript" or ft == "typescript" then
		templateStr = 'console.log("%s %s beep");'
	elseif ft == "zsh" or ft == "bash" or ft == "sh" then
		templateStr = 'echo "%s %s beep"'
	elseif ft == "applescript" then
		templateStr = "beep"
	elseif ft == "css" or ft == "scss" then
		templateStr = "outline: 2px solid red !important;"
	else
		vim.notify("Beeplog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = string.format(marker, templateStr, randomEmoji)
	append(logStatement)
end

function M.timelog()
	if g.timelogStart == nil then g.timelogStart = true end
	local logStatement1, logStatement2
	local ft = bo.filetype

	if ft == "lua" then
		logStatement1 = {
			'print("%s timelog start")',
			"local timelogStart = os.time()",
		}
		logStatement2 = {
			"local duration = os.difftime(os.time(), timelogStart)",
			'print("%s timelog:", duration, "s")',
		}
	elseif ft == "javascript" then
		-- JXA does not support console.time()
		logStatement1 = {
			'console.log("%s timelog start")',
			"const timelogStart = +new Date()",
		}
		logStatement2 = {
			"const duration = (+new Date() - timelogStart) / 1000",
			'console.log("%s timelog:", duration, "s")',
		}
	elseif ft == "typescript" then
		logStatement1 = {
			'console.time("timelog")',
		}
		logStatement2 = {
			'console.timeEnd("timelog")',
		}
	elseif ft == "bash" or ft == "zsh" or ft == "sh" or ft == "fish" then
		logStatement1 = {
			"timelogStart=$(date +%s)",
			'echo "%s time start"',
		}
		logStatement2 = {
			"timelogEnd=$(date +%s) && runtime = $((timelogEnd - timelogStart))",
			'echo "%s time ${runtime}s"',
		}
	else
		vim.notify("Timelog does not support " .. ft .. " yet.", logWarn)
		return
	end
	if g.timelogStart then
		for _, line in pairs(logStatement1) do
			append(line:format(marker))
		end
	else
		for _, line in pairs(logStatement2) do
			append(line:format(marker))
		end
	end

	g.timelogStart = not g.timelogStart
end

-- simple debug statement
function M.debuglog()
	local logStatement
	local ft = bo.filetype

	if ft == "javascript" or ft == "typescript" then
		logStatement = "debugger"
	else
		vim.notify("Debuglog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(logStatement)
end

---Remove all log statements in the current buffer
---Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.removelogs()
	local ft = bo.filetype
	local logStatements
	local numOfLinesBefore = fn.line("$")

	if ft == "lua" or ft == "python" or ft == "sh" then
		logStatements = {marker}
	elseif ft == "javascript" or ft == "typescript" then
		logStatements = { marker, "debugger" }
	elseif ft == "applescript" then
		logStatements = { marker, "beep" }
	elseif ft == "css" or ft == "scss" then
		logStatements = {"outline: 2px solid red !important;"}
	else
		vim.notify("Removelog does not support " .. ft .. " yet.", logWarn)
	end

	for _, statement in pairs(logStatements) do
		statement = statement:gsub("%]", "\\]"):gsub("%[", "\\[")
		cmd(("g/%s/d"):format(statement))
	end
	cmd.nohlsearch()

	local linesRemoved = numOfLinesBefore - fn.line("$")
	local msg = "Removed " .. tostring(linesRemoved) .. " log statements."
	if linesRemoved == 1 then msg = msg:gsub("s%.$", ".") end -- remove plural
	vim.notify(msg)

	g.timelogCount = 0 -- reset timelog
end

--------------------------------------------------------------------------------

return M
