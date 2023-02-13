local M = {}
--------------------------------------------------------------------------------
local fn = vim.fn
local bo = vim.bo
local expand = vim.fn.expand
local logWarn = vim.log.levels.WARN

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---in normal mode, returns word under cursor, in visual mode, returns selection
---@return string
local function getVar()
	local varname
	if fn.mode() == "n" then
		varname = expand("<cword>")
	elseif fn.mode():find("[Vv]") then
		local prevReg = fn.getreg("z")
		normal('"zy')
		varname = fn.getreg("z")
		fn.setreg("z", prevReg)
	end
	return varname
end

---append string below current line, if text is array of strings, append each
---element as separate line
---@param text string|string[]
local function append(text)
	if type(text) == "string" then text = { text } end

	vim.fn.append(".", text) ---@diagnostic disable-line: param-type-mismatch
	for _ = 1, #text, 1 do
		normal("j==")
	end
end

--------------------------------------------------------------------------------

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.log()
	local varname = getVar()
	local logStatement
	local ft = bo.filetype

	if ft == "lua" and expand("%:p:h"):find("hammerspoon") then
		logStatement = 'notify("' .. varname .. ':", ' .. varname .. ")"
	elseif ft == "lua" or ft == "python" then
		logStatement = 'print("' .. varname .. ': ", ' .. varname .. ")"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("' .. varname .. ':", ' .. varname .. ");"
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logStatement = 'echo "(log) ' .. varname .. ": $" .. varname .. '"'
	elseif ft == "applescript" then
		logStatement = 'log "' .. varname .. ': " & ' .. varname
	else
		vim.notify("Quicklog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(logStatement)
end

function M.objectlog()
	local varname = getVar()
	local logStatement
	local ft = bo.filetype

	if ft == "lua" and expand("%:p:h"):find("hammerspoon") then
		logStatement {
			'print("' .. varname .. '")',
			"hs.inspect(" .. varname .. ")",
		}
	elseif ft == "lua" and expand("%:p:h"):find("nvim") then
		logStatement = 'vim.pretty_print("' .. varname .. ':", ' .. varname .. ")"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.dir("' .. varname .. ':", ' .. varname .. ");"
	else
		vim.notify("Objectlog does not support " .. ft .. " yet.", logWarn)
		return
	end

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
			'print("timelog: ", duration, "s")',
		}
	elseif ft == "javascript" then
		-- JXA, for example, does not support console.time()
		logStatement1 = {
			'console.log("timelog start")',
			"const timelogStart = new Date()",
		}
		logStatement2 = {
			"const duration = (new Date() - timelogStart) / 1000",
			'console.log("timelog: ", duration, "s")',
		}
	elseif ft == "typescript" then
		logStatement1 = 'console.time("timelog")'
		logStatement2 = 'console.timeEnd("timelog")'
	elseif ft == "bash" or ft == "zsh" or ft == "sh" or ft == "fish" then
		logStatement1 = {
			"timelogStart=$(date +%s)",
			'echo "(time) start"',
		}
		logStatement2 = {
			"timelogEnd=$(date +%s) && runtime = $((timelogEnd - timelogStart))",
			'echo "(time) ${runtime}s"',
		}
	else
		vim.notify("Timelog does not support " .. ft .. " yet.", logWarn)
		return
	end
	local logToAdd = g.timelogStart and logStatement1 or logStatement2

	append(logToAdd)
	g.timelogStart = not g.timelogStart
end

---adds simple "beep" log statement to check whether conditionals have been
---triggered. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.beeplog()
	local logStatement
	local ft = bo.filetype

	if ft == "lua" and expand("%:p:h"):find("hammerspoon") then
		logStatement = 'notify("beep")'
	elseif ft == "lua" or ft == "python" then
		logStatement = 'print("beep")'
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("beep");'
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logStatement = 'echo "(beep)"'
	elseif ft == "applescript" then
		logStatement = "beep"
	else
		vim.notify("Beeplog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(logStatement)
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
	g.timelogCount = 0 -- reset timelog
	local ft = bo.filetype
	local logCommand
	local numOfLinesBefore = fn.line("$")

	if ft == "lua" and expand("%:p:h"):find("hammerspoon") then
		logCommand = 'notify("beep")'
		vim.notify("Only removing log statements for ham")
	elseif ft == "lua" or ft == "python" then
		logCommand = "print"
	elseif ft == "javascript" or ft == "typescript" then
		logCommand = "console.log"
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logCommand = {

		}
		cmd([[g/^\secho "(beep)"/d]]) -- keywords in () needed to ensure that other echos are not deleted
		cmd([[g/^\secho "(log)/d]])
		cmd([[g/^\secho "(time)/d]])
		return
	elseif ft == "applescript" then
		cmd([[g/^\slog/d]])
		cmd([[g/^\sbeep/d]])
		return
	else
		vim.notify("Removelog does not support " .. ft .. " yet.", logWarn)
	end

	cmd([[g/^\s*]] .. logCommand .. [[/d]])
	cmd.nohlsearch()

	local linesRemoved = numOfLinesBefore - fn.line("$")
	local msg = "Cleared " .. tostring(linesRemoved) .. " log statements."
	if linesRemoved == 1 then msg = msg:gsub("s%.$", ".") end -- remove plural
	vim.notify(msg)
end

--------------------------------------------------------------------------------

return M
