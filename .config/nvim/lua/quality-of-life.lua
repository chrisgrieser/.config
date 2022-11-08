---@diagnostic disable: param-type-mismatch, undefined-field
local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local fn = vim.fn
local getline = vim.fn.getline
local setline = vim.fn.setline
local lineNo = vim.fn.line
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

--------------------------------------------------------------------------------

---Helper Function performing common file operation tasks
---@param operation string rename|duplicate|new
local function fileOp(operation)
	local oldName = fn.expand("%:t")
	local oldExt = fn.expand("%:e")

	local promptStr
	if operation == "duplicate" then promptStr = "Duplicate File as: "
	elseif operation == "rename" then promptStr = "Rename File to: "
	elseif operation == "new" then promptStr = "New File: "
	end

	vim.ui.input({prompt = promptStr}, function(newName)
		if not (newName) then return end -- cancel
		if newName:find("^%s*$") or newName:find("/") or newName:find(":") or newName:find("\\") then
			vim.notify("Invalid Filename.", error)
			return
		end
		local extProvided = newName:find("%.")
		if not (extProvided) then
			newName = newName .. "." .. oldExt
		end
		if operation == "duplicate" then
			cmd("saveas " .. newName)
			cmd("edit " .. newName)
			vim.notify("Duplicated '" .. oldName .. "' as '" .. newName .. "'.")
		elseif operation == "rename" then
			os.rename(oldName, newName)
			cmd("edit " .. newName)
			cmd("bdelete #")
			vim.notify("Renamed '" .. oldName .. "' to '" .. newName .. "'.")
		elseif operation == "new" then
			cmd("edit " .. newName)
			cmd("write " .. newName)
		end
	end)
end

---Rename Current File
-- - if no extension is provided, the current extensions will be kept
-- - uses vim.ui.input and vim.notify, so plugins like dressing.nvim or
--   notify.nvim are automatically supported
function M.renameFile() fileOp("rename") end

---Duplicate Current File
-- - if no extension is provided, the current extensions will be kept
-- - uses vim.ui.input and vim.notify, so plugins like dressing.nvim or
--   notify.nvim are automatically supported
function M.duplicateFile() fileOp("duplicate") end

---Create New File
-- - if no extension is provided, the extensions of the current file will be used
-- - uses vim.ui.input and vim.notify, so plugins like dressing.nvim or
--   notify.nvim are automatically supported
function M.createNewFile() fileOp("new") end

---run `chmod +x` on the current file
function M.chmodx()
	local currentFile = fn.expand("%:p")
	os.execute("chmod +x " .. "'" .. currentFile .. "'")
	vim.notify("Execution permission granted.")
end

---Helper for copying file information
---@param operation string filename|filepath
---@param reg? string register to copy to
local function copyOp (operation, reg)
	if not (reg) then reg = "+" end
	local toCopy
	if operation == "filename" then
		toCopy = fn.expand("%:t")
	elseif operation == "filepath" then
		toCopy = fn.expand("%:p")
	end
	fn.setreg(reg, toCopy)
	vim.notify("COPIED\n"..toCopy)
end

---Copy full path of current file
---@param reg? string The register to copy the last command to. Default: "+"
function M.copyFilepath(reg)
	copyOp("filepath", reg)
end

---Copy name of current file
---@param reg? string The register to copy the last command to. Default: "+"
function M.copyFilename(reg)
	copyOp("filename", reg)
end

---Trash the Current File. Requires `mv`.
---@param trashLocation string Trash directory. Default: "$HOME/.Trash/" 
function M.trashFile(trashLocation)
	if not (trashLocation) then trashLocation = "$HOME/.Trash/" end
	local currentFile = fn.expand("%:p")
	local filename = fn.expand("%:t")
	cmd[[update!]]
	os.execute('mv -f "'..currentFile..'" "'..trashLocation..'"')
	cmd[[bdelete]]
	vim.notify("'"..filename.."' deleted.")
end

--------------------------------------------------------------------------------

---Copy Last Command
---@param reg? string The register to copy the last command to. Default: "+"
function M.copyLastCommand(reg)
	if not (reg) then reg = "+" end
	local lastCommand = fn.getreg(":")
	if not(lastCommand) then
		vim.notify("No Command has been run yet.", error)
		return
	end
	fn.setreg(reg, lastCommand)
	vim.notify("COPIED\n"..lastCommand)
end

---Run Last Command Again
function M.runLastCommandAgain()
	local lastCommand = fn.getreg(":")
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

	local line = getline(".")
	if opts.smart then
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
	cmd [[silent! normal!"zy`]"zp]]
	fn.setreg("z", prevReg)
end

-- insert horizontal divider considering textwidth, commentstring, and indent
---@param linechar? string Character used for horizontal divider. Default: "─"
function M.hr(linechar)
	local indent = vim.fn.indent(".")
	local textwidth = bo.textwidth
	local comstr = bo.commentstring
	local comStrLength = #(comstr:gsub("%%s", ""):gsub(" ", ""))

	if not (linechar) then
		if comstr:find("-") then
			linechar = "-"
		else
			linechar = "─"
		end
	elseif #linechar > 1 then
		linechar:sub(1, 1)
	end

	local linelength = textwidth - indent - comStrLength
	local fullLine = string.rep(linechar, linelength)
	local hr = comstr:gsub(" ?%%s ?", fullLine)

	append(".", {hr, ""})
	cmd [[normal! j==]] -- move down and indent

	-- fix for blank lines inside indented blocks
	local line = getline(".")
	if bo.expandtab then
		line = line:sub(1, textwidth)
	else
		local spacesPerTab = string.rep(" ", bo.tabstop)
		line = line
			:gsub("\t", spacesPerTab)
			:sub(1, textwidth)
			:gsub(spacesPerTab, "\t")
	end
	setline(".", line)

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
	local char = getline("."):sub(col, col) ---@diagnostic disable-line: param-type-mismatch, undefined-field

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
	local isLetter = char:upper() ~= char:lower()
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

	vim.notify("Nothing under the cursor that can be switched", warn)
end

---enables overscrolling for that action when close to the last line, depending
--on 'scrolloff' option
---@param action string The motion to be executed when not at EOF
function M.overscroll(action)
	local curLine = lineNo(".")
	local lastLine = lineNo("$")
	if (lastLine - curLine - 1) < vim.wo.scrolloff then
		cmd [[normal! zz]]
	end
	cmd("normal! " .. action)
end

-- log statement for variable under cursor, similar to the 'turbo console log'
-- popular VS Code plugin
-- supported: lua, js/ts, zsh/bash/fish, and applescript
---@param addLineNumber? boolean Whether to add the line number. Default: false
function M.quicklog(addLineNumber)
	local varname = wordUnderCursor()
	local logStatement
	local ft = bo.filetype
	local lnStr = ""
	if addLineNumber then
		lnStr = "L" .. tostring(lineNo(".")) .. " "
	end

	if ft == "lua" then
		logStatement = 'print("' .. lnStr .. varname .. ': ", ' .. varname .. ")"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("' .. lnStr .. varname .. ': " + ' .. varname .. ")"
	elseif ft == "zsh" or ft == "bash" or ft == "fish" then
		logStatement = 'echo "' .. lnStr .. varname .. ": $" .. varname .. '"'
	elseif ft == "applescript" then
		logStatement = 'log "' .. lnStr .. varname .. ': " & ' .. varname
	else
		vim.notify("Quicklog does not support " .. ft .. " yet.", warn)
	end

	append(".", logStatement)
	cmd [[normal! j==]] -- move down and indent
end

--------------------------------------------------------------------------------
-- MOVEMENT
-- performed as command makes them less glitchy

function M.moveLineDown()
	cmd [[. move +1]]
	cmd [[normal! ==]]
end

function M.moveLineUp()
	cmd [[. move -2]]
	cmd [[normal! ==]]
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

function M.moveCharRight()
	cmd [[:normal! xp]]
end

function M.moveCharLeft()
	cmd [[:normal! xhP]]
end

--------------------------------------------------------------------------------

return M
