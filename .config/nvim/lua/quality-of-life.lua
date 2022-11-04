---@diagnostic disable: param-type-mismatch, undefined-field
local getline = vim.fn.getline
local setline = vim.fn.setline
local lineNo = vim.fn.line
local append = vim.fn.append
local bo = vim.bo
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor

local ret = {}

--------------------------------------------------------------------------------

function ret.duplicateLine()
	local line = getline(".")
	append(".", line)
	local lineNum = getCursor(0)[1] + 1 -- line down
	local colNum = getCursor(0)[2]
	setCursor(0, {lineNum, colNum})
end

function ret.duplicateVisual()
	local prevReg = vim.fn.getreg("z")
	cmd [[silent! normal!"zy`]"zp]]
	vim.fn.setreg("z", prevReg)
end

function ret.smartDuplicateLine()
	local line = getline(".")
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
	append(".", line)

	-- cursor movement
	local lineNum = getCursor(0)[1] + 1 -- line down
	local colNum = getCursor(0)[2]
	local _, valuePos = line:find(": ?")
	if valuePos then -- if line was changed, move cursor to value of the property
		colNum = valuePos
	end
	api.nvim_win_set_cursor(0, {lineNum, colNum})
end

-- construct hr considering textwidth, commentstring, and indent
---@param linechar? string Character used for horizontal divider. Default: "─"
function ret.hr(linechar)
	local indent = vim.fn.indent(".")
	local textwidth = bo.textwidth
	local comstr = bo.commentstring
	local comStrLength = #comstr:gsub("%%s", ""):gsub(" ", "")

	if not (linechar) then linechar = "─" end
	if #linechar > 1 then linechar:sub(1, 1) end

	if comstr:find("-") then linechar = "-" end
	local linelength = textwidth - indent - comStrLength
	local fullLine = string.rep(linechar, linelength)
	local hr = comstr:gsub(" ?%%s ?", fullLine)

	append(".", {hr, ""})
	cmd [[normal! j==]] -- move down and indent

	-- fix for blank lines inside indentations
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

function ret.switcher()
	-- ignore 'iskeyword' option when retrieving word under cursor
	local wordUnderCursor
	local wordchar = bo.iskeyword
	dashIsKeyword = wordchar:find(",%-$") or wordchar:find(",%-,") or wordchar:find("^%-,")
	if dashIsKeyword then
		bo.iskeyword = wordchar:gsub("%-,?", ""):gsub(",?%-", "")
		wordUnderCursor = fn.expand("<cword>")
		bo.iskeyword = wordchar
	else
		wordUnderCursor = fn.expand("<cword>")
	end

	local col = getCursor(0)[2] + 1
	local char = getline("."):sub(col, col) ---@diagnostic disable-line: param-type-mismatch, undefined-field

	-- toggle words
	local opposite = ""
	if wordUnderCursor == "true" then opposite = "false"
	elseif wordUnderCursor == "false" then opposite = "true"
	end

	if bo.filetype == "css" then
		if wordUnderCursor == "top" then opposite = "bottom"
		elseif wordUnderCursor == "bottom" then opposite = "top"
		elseif wordUnderCursor == "left" then opposite = "right"
		elseif wordUnderCursor == "right" then opposite = "left"
		elseif wordUnderCursor == "width" then opposite = "height"
		elseif wordUnderCursor == "height" then opposite = "width"
		end
	end
	if bo.filetype == "lua" then
		if wordUnderCursor == "and" then opposite = "or"
		elseif wordUnderCursor == "or" then opposite = "and"
		end
	end
	if bo.filetype == "javascript" or bo.filetype == "typescript" then
		if wordUnderCursor == "const" then opposite = "let"
		elseif wordUnderCursor == "let" then opposite = "const"
		end
	end
	if opposite ~= "" then
		cmd('normal! "_ciw' .. opposite)
		return
	end

	-- toggle case (regular ~)
	local isLetter = char:upper() ~= char:lower()
	if isLetter then
		cmd [[normal! ~]]
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
	end
end

function ret.overscroll(action) ---@param action string The motion to be executed when not at EOF
	local curLine = lineNo(".")
	local lastLine = lineNo("$")
	if (lastLine - curLine - 1) < vim.wo.scrolloff then
		cmd [[normal! zz]]
	end
	cmd("normal! " .. action)
end

-- log statement for variable under cursor, similar to the 'turbo console log'
-- supported: lua, js/ts, zsh/bash, and applescript (sic!)
function ret.quicklog()
	local wordUnderCursor = fn.expand("<cword>")
	local logStatement
	local ft = bo.filetype

	if ft == "lua" then
		logStatement = 'print("'..wordUnderCursor..': "..'..wordUnderCursor..')'
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log({ '..wordUnderCursor..' });'
	elseif ft == "zsh" or ft == "bash" then
	elseif ft == "applescript" then
		logStatement = 'log "'..wordUnderCursor..'": & '..wordUnderCursor
	else
		print("Quicklog does not yet support "..ft..".")
	end

	append(".", logStatement)
	cmd [[normal! j==]] -- move down and indent
end

--------------------------------------------------------------------------------

return ret
