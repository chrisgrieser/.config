---@diagnostic disable: assign-type-mismatch, param-type-mismatch
local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local fn = vim.fn
local getline = vim.fn.getline
local setline = vim.fn.setline
local lineNo = vim.fn.line
local colNo = vim.fn.col
local append = vim.fn.append
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local error = vim.log.levels.ERROR
local warn = vim.log.levels.WARN
local function wordUnderCursor() return vim.fn.expand("<cword>") end

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
		vim.notify(" No Command has been run yet. ", error)
		return
	end
	fn.setreg(reg, lastCommand)
	vim.notify(" COPIED\n " .. lastCommand)
end

---Run Last Command Again
function M.runLastCommandAgain()
	local lastCommand = fn.getreg(":")
	if not (lastCommand) then
		vim.notify(" No Command has been run yet.", error)
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
	cmd [[noautocmd silent! normal!"zy`]"zp]] -- `noautocmd` to not trigger highlighted yank
	fn.setreg("z", prevReg)
end

-- insert horizontal divider considering textwidth, commentstring, and indent
---@param opts? table
function M.hr(opts)
	if not (opts) then
		opts = {linechar = "─"}
	end
	local linechar = opts.linechar
	local wasOnBlank = getline(".") == ""
	local indent = fn.indent(".")
	local textwidth = bo.textwidth
	local comstr = bo.commentstring
	local comStrLength = #(comstr:gsub("%%s", ""):gsub(" ", ""))

	if comstr == "" then
		vim.notify(" No commentstring for this filetype available.", warn)
		return
	end
	if comstr:find("-") then linechar = "-" end

	local linelength = textwidth - indent - comStrLength
	local fullLine = string.rep(linechar, linelength)
	local hr = comstr:gsub(" ?%%s ?", fullLine)
	if bo.filetype == "markdown" then hr = "---" end

	local linesToAppend = {"", hr, ""}
	if wasOnBlank then linesToAppend = {hr, ""} end

	append(".", linesToAppend)

	-- shorten if it was on blank line, since fn.indent() does not return indent
	-- line would have if it has content
	if wasOnBlank then
		cmd [[normal! j==]] -- move down and indent
		local hrIndent = fn.indent(".")
		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = getline(".") ---@type string
		hrLine = hrLine:gsub(linechar, "", hrIndent)
		setline(".", hrLine)
	else
		cmd [[normal! jj==]]
	end
end

-- Drop-in replacement for vim's `~` command.
-- - If the word under cursor has a reasonable opposite in the current language
--   (e.g., "top" and "bottom" in css), then the word will be toggled.
-- - Otherwise will check character under cursor. If it is a "reversible"
--   character, the character will be switched, e.g. "(" to ")".
-- - If the character is a letter, falls back to the default `~` behavior of
--   toggling between upper and lower case.
function M.reverse()
	local word
	local wordchar = bo.iskeyword
	dashIsKeyword = wordchar:find(",%-$") or wordchar:find(",%-,") or wordchar:find("^%-,")
	if dashIsKeyword then
		bo.iskeyword = wordchar:gsub("%-,", ""):gsub(",%-", "")
		word = wordUnderCursor()
		bo.iskeyword = wordchar
	else
		word = wordUnderCursor()
	end

	local col = getCursor(0)[2] + 1
	local char = getline(".") ---@type string
	char = char:sub(col, col)

	-- toggle words
	local opposite = ""
	if word == "true" then opposite = "false"
	elseif word == "false" then opposite = "true"
	end

	if bo.filetype == "css" then
		if word == "top" then opposite = "bottom"
		elseif word == "bottom" then opposite = "top"
		elseif word == "left" then opposite = "right"
		elseif word == "right" then opposite = "left"
		elseif word == "width" then opposite = "height"
		elseif word == "height" then opposite = "width"
		elseif word == "absolute" then opposite = "relative"
		elseif word == "relative" then opposite = "absolute"
		end
	elseif bo.filetype == "lua" then
		if word == "and" then opposite = "or"
		elseif word == "or" then opposite = "and"
		end
	elseif bo.filetype == "python" then
		if word == "True" then opposite = "False"
		elseif word == "False" then opposite = "True"
		end
	elseif bo.filetype == "javascript" or bo.filetype == "typescript" then
		if word == "const" then opposite = "let"
		elseif word == "let" then opposite = "const"
		end
	end

	if opposite ~= "" then
		cmd('normal! "_ciw' .. opposite)
		return
	end

	-- toggle case (regular ~)
	local isLetter = char:lower() ~= char:upper()
	if isLetter then
		cmd [[normal! ~h]]
		return
	end

	-- switch punctuation
	local switched = ""
	if char == "<" then switched = ">"
	elseif char == ">" then switched = "<"
	elseif char == "(" then switched = ")"
	elseif char == ")" then switched = "("
	elseif char == "]" then switched = "["
	elseif char == "[" then switched = "]"
	elseif char == "{" then switched = "}"
	elseif char == "}" then switched = "{"
	elseif char == "/" then switched = "\\"
	elseif char == "\\" then switched = "/"
	elseif char == "'" then switched = '"'
	elseif char == '"' then switched = "'"
	elseif char == "," then switched = ";"
	elseif char == ";" then switched = ","
	end
	if switched ~= "" then
		cmd("normal! r" .. switched)
		return
	end

	vim.notify(" Nothing under the cursor can be switched.", warn)
end

---select between undoing the last 1h, 4h, or 24h
---@param opts table
function M.undoDuration(opts)
	if not (opts) then opts = {selection = {"15m", "1h", "4h", "24h"}} end

	vim.ui.select(opts.selection, {prompt = "Undo the last…"}, function(choice)
		if not (choice) then return end
		cmd("earlier " .. choice)
		vim.notify("Restored to " .. choice .. " earlier")
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
	local regContent = fn.getreg(reg):gsub("\n$", "")
	local targetRegType

	if isLinewise then
		targetRegType = "v"
	elseif isCharwise then
		targetRegType = "V"
		regContent = trim(regContent)
	else
		vim.notify(" This paste command does not work with blockwise registers.", warn)
		return
	end

	fn.setreg(reg, regContent, targetRegType)
	cmd('normal! "' .. reg .. "p")
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
		vim.notify(" Quicklog does not support " .. ft .. " yet.", warn)
	end

	append(".", logStatement)
	cmd [[normal! j==]] -- move down and indent
end

---Remove all log statements in the current buffer
---Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.removeLog()
	local ft = bo.filetype
	if ft == "lua" or ft == "python" then
		logCommand = "print"
	elseif ft == "javascript" or ft == "typescript" then
		logCommand = "console."
	elseif ft == "zsh" or ft == "bash" or ft == "fish" then
		vim.notify(" Shell 'echo' cannot be removed since indistinguishable from other echos. ", warn)
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
-- performed as command makes them less glitchy

function M.moveLineDown()
	if lineNo(".") == lineNo("$") then return end
	cmd [[. move +1]]
	cmd [[normal! ==]]
end

function M.moveLineUp()
	if lineNo(".") == 1 then return end
	cmd [[. move -2]]
	cmd [[normal! ==]]
end

function M.moveCharRight()
	if colNo(".") >= colNo("$") - 2 then return end
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
