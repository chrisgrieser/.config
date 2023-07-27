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
---@param text string|string[]
local function append(text)
	if type(text) == "string" then text = { text } end

	local ln = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, ln, ln, false, text)
	for _ = 1, #text, 1 do
		normal("j==")
	end
end

--------------------------------------------------------------------------------

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.log()
	local varname = getVar()
	local templateStr
	local ft = bo.filetype

	if ft == "lua" or ft == "python" then
		templateStr = 'print("%s:", %s)'
	elseif ft == "javascript" or ft == "typescript" then
		templateStr = 'console.log("%s:", %s);'
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		templateStr = 'echo "[log] %s: $%s"'
	elseif ft == "applescript" then
		templateStr = 'log "%s:" & %s'
	elseif ft == "css" or ft == "scss" then
		templateStr = "outline: 2px solid red !important;"
	else
		vim.notify("Quicklog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = string.format(templateStr, varname, varname)
	append(logStatement)
end

function M.objectlog()
	local varname = getVar()
	local templateStr
	local ft = bo.filetype

	if ft == "javascript" then
		templateStr = 'console.log("%s:", JSON.stringify(%s))'
	else
		vim.notify("Objectlog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = string.format(templateStr, varname, varname)
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
		templateStr = 'print("%s beep")'
	elseif ft == "javascript" or ft == "typescript" then
		templateStr = 'console.log("%s beep");'
	elseif ft == "zsh" or ft == "bash" or ft == "sh" then
		templateStr = 'echo "%s [beep]"'
	elseif ft == "applescript" then
		templateStr = "beep"
	elseif ft == "css" or ft == "scss" then
		templateStr = "outline: 2px solid red !important;"
	else
		vim.notify("Beeplog does not support " .. ft .. " yet.", logWarn)
		return
	end

	local logStatement = string.format(templateStr, randomEmoji)
	append(logStatement)
end

function M.timelog()
	if g.timelogStart == nil then g.timelogStart = true end
	local logStatement1, logStatement2
	local ft = bo.filetype

	if ft == "lua" then
		logStatement1 = {
			'print("timelog start")',
			"local timelogStart = os.time()",
		}
		logStatement2 = {
			"local duration = os.difftime(os.time(), timelogStart)",
			'print("timelog:", duration, "s")',
		}
	elseif ft == "javascript" then
		-- JXA, for example, does not support console.time()
		logStatement1 = {
			'console.log("timelog start")',
			"const timelogStart = +new Date()",
		}
		logStatement2 = {
			"const duration = (+new Date() - timelogStart) / 1000",
			'console.log("timelog:", duration, "s")',
		}
	elseif ft == "typescript" then
		logStatement1 = 'console.time("timelog")'
		logStatement2 = 'console.timeEnd("timelog")'
	elseif ft == "bash" or ft == "zsh" or ft == "sh" or ft == "fish" then
		logStatement1 = {
			"timelogStart=$(date +%s)",
			'echo "[time] start"',
		}
		logStatement2 = {
			"timelogEnd=$(date +%s) && runtime = $((timelogEnd - timelogStart))",
			'echo "[time] ${runtime}s"',
		}
	else
		vim.notify("Timelog does not support " .. ft .. " yet.", logWarn)
		return
	end
	local logToAdd = g.timelogStart and logStatement1 or logStatement2

	append(logToAdd)
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
	local logStatement
	local numOfLinesBefore = fn.line("$")

	if ft == "lua" and expand("%:p:h"):find("hammerspoon") then
		logStatement = 'print(".*beep")'
		vim.notify("Only removing beep logs for hammmerspoon, since prints are kept.")
	elseif ft == "lua" or ft == "python" then
		logStatement = "print"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = {
			"console.log",
			"debugger",
		}
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logStatement = {
			'echo "[beep]', -- no closing " to catch full log statement
			'echo "[log]',
			'echo "[time]',
		}
	elseif ft == "applescript" then
		logStatement = { "log", "beep" }
	elseif ft == "css" or ft == "scss" then
		logStatement = "outline: 2px solid red !important;"
	else
		vim.notify("Removelog does not support " .. ft .. " yet.", logWarn)
	end

	if type(logStatement) == "string" then logStatement = { logStatement } end
	for _, logCom in pairs(logStatement) do
		cmd([[silent g/^\s*]] .. logCom .. [[/d]])
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
