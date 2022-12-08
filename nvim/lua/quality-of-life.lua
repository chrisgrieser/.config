---@diagnostic disable: param-type-mismatch, assign-type-mismatch
local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local b = vim.b
local fn = vim.fn
local cmd = vim.cmd
local getline = vim.fn.getline
local lineNo = vim.fn.line
local colNo = vim.fn.col
local append = vim.fn.append
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local logWarn = vim.log.levels.WARN
local function wordUnderCursor()
	return vim.fn.expand("<cword>")
end

local function leaveVisualMode()
	-- https://github.com/neovim/neovim/issues/17735#issuecomment-1068525617
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

---trims whitespace from string
---@param str string
---@return string
function trim(str)
	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------

---Copy Last Command
function M.copyLastCommand()
	local reg = '"'
	local clipboardOpt = vim.opt.clipboard:get();
	local useSystemClipb = #clipboardOpt > 0 and clipboardOpt[1]:find("unnamed")
	if useSystemClipb then reg = "+" end

	local lastCommand = fn.getreg(":")
	if not (lastCommand) then
		vim.notify(" No Command has been run yet. ", logWarn)
		return
	end
	fn.setreg(reg, lastCommand)
	vim.notify(" COPIED\n " .. lastCommand)
end

---Run Last Command Again
function M.runLastCommandAgain()
	local lastCommand = fn.getreg(":")
	if not (lastCommand) then
		vim.notify(" No Command has been run yet. ", logWarn)
		return
	end
	cmd(lastCommand)
end

--------------------------------------------------------------------------------

-- Duplicate line under cursor, and change occurences of certain words to their
-- opposite, e.g., "right" to "left". Intended for languages like CSS.
---@param opts? table available: reverse, moveTo = key|value|none, increment
function M.duplicateLine(opts)
	if not (opts) then
		opts = {reverse = false, moveTo = "key", increment = false}
	end

	local line = getline(".") ---@type string
	if opts.reverse then
		if line:find("top") then
			line = line:gsub("top", "bottom")
		elseif line:find("bottom") then
			line = line:gsub("bottom", "top")
		elseif line:find("right") then
			line = line:gsub("right", "left")
		elseif line:find("left") then
			line = line:gsub("left", "right")
		elseif line:find("height") and not (line:find("line-height")) then
			line = line:gsub("height", "width")
		elseif line:find("width") and not (line:find("border-width")) and not (line:find("outline-width")) then
			line = line:gsub("width", "height")
		end
	end

	if opts.increment then
		local digits = line:match("%d+")
		if digits then
			digits = tostring(tonumber(digits) + 1)
			line = line:gsub("%d+", digits, 1)
		end
	end

	append(".", line)

	-- cursor movement
	local lineNum = getCursor(0)[1] + 1 -- line down
	local colNum = getCursor(0)[2]
	local keyPos, valuePos = line:find(".%w+ ?[:=] ?")
	if opts.moveTo == "value" and valuePos then
		colNum = valuePos
	elseif opts.moveTo == "key" and keyPos then
		colNum = keyPos
	end
	setCursor(0, {lineNum, colNum})
end

function M.duplicateSelection()
	local prevReg = fn.getreg("z")
	cmd [[noautocmd silent! normal!"zy`]"zp]] -- `noautocmd` to not trigger highlighted-yank
	fn.setreg("z", prevReg)
end

--------------------------------------------------------------------------------
-- UNDO
-- Save
augroup("undoTimeMarker", {})
autocmd("BufReadPost", {
	group = "undoTimeMarker",
	callback = function() b.timeOpened = os.time() end,
})

---select between undoing the last 1h, 4h, or 24h
---@param opts table
function M.undoDuration(opts)
	if not (opts) then opts = {selection = {"buffer opening", "15m", "1h", "4h", "24h"}} end

	vim.ui.select(opts.selection, {prompt = "Undo the last…"}, function(choice)
		if not (choice) then return end
		if choice == "buffer opening" then
			local now = os.time()
			local secsPassed = now - b.timeOpened
			cmd("earlier " .. secsPassed .. "s")
			return
		end
		cmd("earlier " .. choice)
		vim.notify(" Restored to " .. choice .. " earlier. ")
	end)
end

--------------------------------------------------------------------------------

---enables overscrolling for that action when close to the last line, depending
--on 'scrolloff' option
---@param action string The motion to be executed when not at the EOF
function M.overscroll(action)
	if bo.filetype ~= "DressingSelect" then
		local curLine = lineNo(".")
		local lastLine = lineNo("$")
		if (lastLine - curLine - 1) < vim.wo.scrolloff then
			cmd [[normal! zz]]
		end
	end
	cmd("normal! " .. tostring(vim.v.count1) .. action)
end

---Force pasting a linewise register characterwise and vice versa
---@param opts? table
function M.pasteDifferently(opts) -- paste as characterwise
	if not (opts) then opts = {reg = "+"} end
	local reg = opts.reg

	local isLinewise = fn.getregtype(reg) == "V"
	local isCharwise = fn.getregtype(reg) == "v"
	local regContent = fn.getreg(reg)
	regContent = trim(regContent)
	local targetRegType

	if isLinewise then
		targetRegType = "v"
	elseif isCharwise then
		targetRegType = "V"
	else
		vim.notify(" This paste command does not work with blockwise registers.", logWarn)
		return
	end

	fn.setreg(reg, regContent, targetRegType)
	cmd('normal! "' .. reg .. "p")
	if targetRegType == "V" then cmd [[normal!==]] end -- indent the new paste
end

--------------------------------------------------------------------------------

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
---@param opts? table
function M.quicklog(opts)
	if not (opts) then opts = {addLineNumber = false} end

	local varname = wordUnderCursor()
	local logStatement
	local ft = bo.filetype
	local lnStr = ""
	if opts.addLineNumber then
		lnStr = "L" .. tostring(lineNo(".")) .. " "
	end

	if ft == "lua" then
		logStatement = 'print("' .. lnStr .. varname .. ': ", ' .. varname .. ")"
	elseif ft == "python" then
		logStatement = 'print("' .. lnStr .. varname .. ': " + ' .. varname .. ")"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("' .. lnStr .. varname .. ': " + ' .. varname .. ");"
	elseif ft == "zsh" or ft == "bash" or ft == "fish" then
		logStatement = 'echo "' .. lnStr .. varname .. ": $" .. varname .. '"'
	elseif ft == "applescript" then
		logStatement = 'log "' .. lnStr .. varname .. ': " & ' .. varname
	else
		vim.notify(" Quicklog does not support " .. ft .. " yet.", logWarn)
	end

	append(".", logStatement)
	cmd [[normal! j==]] -- move down and indent
end

---Remove all log statements in the current buffer
---Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.removeLog()
	local ft = bo.filetype
	local logCommand
	if ft == "lua" or ft == "python" then
		logCommand = "print"
	elseif ft == "javascript" or ft == "typescript" then
		logCommand = "console."
	elseif ft == "zsh" or ft == "bash" or ft == "fish" then
		vim.notify(" Shell 'echo' cannot be removed since indistinguishable from other echos. ", logWarn)
	elseif ft == "applescript" then
		logCommand = "log"
	else
		vim.notify(" Quicklog does not support " .. ft .. " yet.")
	end
	local logsStatementsNum = fn.search([[^\s*]] .. logCommand, "nw")
	cmd([[g/^\s*]] .. logCommand .. [[/d]])

	vim.notify(" Cleared " .. tostring(logsStatementsNum) .. " log statements. ")
	cmd("nohl")
end

--------------------------------------------------------------------------------
-- MOVEMENT
-- performed via `:normal` makes them less glitchy

function M.moveLineDown()
	if lineNo(".") == lineNo("$") then return end
	cmd [[. move +1]]
	if bo.filetype ~= "yaml" then cmd [[normal! ==]] end
end

function M.moveLineUp()
	if lineNo(".") == 1 then return end
	cmd [[. move -2]]
	if bo.filetype ~= "yaml" then cmd [[normal! ==]] end
end

function M.moveCharRight()
	if colNo(".") >= colNo("$") - 1 then return end
	cmd [[:normal! xp]]
end

function M.moveCharLeft()
	if colNo(".") == 1 then return end
	cmd [[:normal! xhP]]
end

function M.moveSelectionDown()
	leaveVisualMode()
	cmd [['<,'> move '>+1]]
	cmd [[normal! gv=gv]]
end

function M.moveSelectionUp()
	leaveVisualMode()
	cmd [['<,'> move '<-2]]
	cmd [[normal! gv=gv]]
end

function M.moveSelectionRight()
	cmd [[normal! xpgvlolo]]
end

function M.moveSelectionLeft()
	cmd [[normal! xhPgvhoho]]
end

--------------------------------------------------------------------------------

return M
