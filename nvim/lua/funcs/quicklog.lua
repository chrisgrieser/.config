local M = {}
--------------------------------------------------------------------------------
local fn = vim.fn
local append = vim.fn.append
local bo = vim.bo
local expand = vim.fn.expand
local logWarn = vim.log.levels.WARN

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

--------------------------------------------------------------------------------

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.quicklog()
	local varname
	if fn.mode() == "n" then
		varname = expand("<cword>")
	else
		local prevReg = fn.getreg("z")
		normal('"zy')
		varname = fn.getreg("z")
		fn.setreg("z", prevReg)
	end

	local logStatement
	local ft = bo.filetype

	if ft == "lua" and expand("%:p:h"):find("/hammerspoon/") then
		logStatement = 'notify("' .. varname .. ':", ' .. varname .. ")"
	elseif ft == "lua" then
		logStatement = 'print("' .. varname .. ':", ' .. varname .. ")"
	elseif ft == "python" then
		logStatement = 'print("' .. varname .. ': " + ' .. varname .. ")"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("' .. varname .. ': " + ' .. varname .. ");"
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logStatement = 'echo "(log) ' .. varname .. ": $" .. varname .. '"'
	elseif ft == "applescript" then
		logStatement = 'log "' .. varname .. ': " & ' .. varname
	else
		vim.notify("Quicklog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(".", logStatement) ---@diagnostic disable-line: param-type-mismatch
	normal("j==")
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
		-- JXA for example does not support console.time()
		logStatement1 = {
			'console.log("timelog start")',
			"const timelogStart = new Date()",
		}
		logStatement2 = {
			"const duration = (new Date() - timelogStart) / 1000",
			'console.log("timelog: ", duration, "s")',
		}
	elseif ft == "typescript" then
		logStatement1 = { 'console.time("timelog")' }
		logStatement2 = { 'console.timeEnd("timelog")' }
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

	append(".", logToAdd) ---@diagnostic disable-line: param-type-mismatch
	for _ = 1, #logToAdd, 1 do
		normal("j==")
	end
	g.timelogStart = not g.timelogStart
end

---adds simple "beep" log statement to check whether conditionals have been
---entered. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.beeplog()
	local logStatement
	local ft = bo.filetype

	if ft == "lua" and expand("%:p:h"):find("/hammerspoon/") then
		logStatement = 'notify("beep")'
	elseif ft == "lua" or ft == "python" then
		logStatement = 'print("beep")'
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("beep");'
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logStatement = 'echo "(beep)"'
	elseif ft == "applescript" then
		logStatement = 'log "beep"'
	else
		vim.notify("Beeplog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(".", logStatement) ---@diagnostic disable-line: param-type-mismatch
	normal("j==")
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

	append(".", logStatement) ---@diagnostic disable-line: param-type-mismatch
	normal("j==")
end

---Remove all log statements in the current buffer
---Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.removelogs()
	g.timelogCount = 0 -- reset timelog
	local ft = bo.filetype
	local logCommand
	local linesBefore = fn.line("$")
	if ft == "lua" and expand("%:p:h"):find("/hammerspoon/") then
		logCommand = "print"
		vim.notify("Only removing 'print' statements, not 'notify' statements.")
	elseif ft == "lua" or ft == "python" then
		logCommand = "print"
	elseif ft == "javascript" or ft == "typescript" then
		logCommand = "console."
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		cmd([[g/echo "(beep)"/d]]) -- keywords in () needed to ensure that other echos are not deleted
		cmd([[g/echo "(log)/d]])
		cmd([[g/echo "(time)/d]])
		return
	elseif ft == "applescript" then
		logCommand = "log"
	else
		vim.notify("Removelog does not support " .. ft .. " yet.", logWarn)
	end

	cmd([[g/^\s*]] .. logCommand .. [[/d]])
	cmd.nohlsearch()

	local linesRemoved = linesBefore - fn.line("$")
	local msg = "Cleared " .. tostring(linesRemoved) .. " log statements."
	if linesRemoved == 1 then msg = msg:gsub("s%.$", ".") end -- remove plural
	vim.notify(msg)
end

--------------------------------------------------------------------------------

return M
