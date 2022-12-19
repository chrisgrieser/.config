local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local bo = vim.bo
local fn = vim.fn
local opt = vim.opt

local M = {}
--------------------------------------------------------------------------------

-- TODO setup function with some configs
local lookForwardLines = 8
--------------------------------------------------------------------------------

---runs :normal natively with bang
---@param cmdStr any
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---@return boolean
local function isVisualMode()
	local modeWithV = fn.mode():find("v")
	return (modeWithV ~= nil and modeWithV ~= false)
end

---@return boolean
local function isVisualLineMode()
	local modeWithV = fn.mode():find("V")
	return (modeWithV ~= nil and modeWithV ~= false)
end

---sets the selection for the textobj (characterwise)
---@param startLine integer
---@param endLine integer
---@param startCol integer
---@param endCol integer
local function setSelection(startLine, endLine, startCol, endCol)
	setCursor(0, { startLine, startCol })
	if isVisualMode() then
		normal("o")
	else
		normal("v")
	end
	setCursor(0, { endLine, endCol })
end

---seek forwards for pattern
---@param pattern string lua pattern
---@return nil|integer line pattern was found, or integer
local function seekForward(pattern)
	local i = -1
	local lineContent, hasPattern
	---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
	local lastLine = fn.getline("$") ---@type string
	local startRow, startCol = unpack(getCursor(0))

	repeat
		i = i + 1
		---@diagnostic disable-next-line: assign-type-mismatch
		lineContent = fn.getline(startRow + i) ---@type string
		hasPattern = lineContent:find(pattern, startCol)
		startCol = 1 -- after the current row, pattern can occur everywhere in the line
		if i > lookForwardLines or startRow + i > lastLine then
			vim.notify("Textobject not found within " .. tostring(lookForwardLines) .. ".", vim.log.levels.WARN)
			return nil
		end
	until hasPattern

	return startRow + i
end

--------------------------------------------------------------------------------

---Subword (word with "-_" as delimiters)
function M.subword()
	local iskeywBefore = opt.iskeyword:get()
	opt.iskeyword:remove { "_", "-", "." }
	if not isVisualMode() then normal("v") end
	normal("iw")
	opt.iskeyword = iskeywBefore
end

---near end of the line, ignoring trailing whitespace (relevant for markdown)
function M.nearEoL()
	if not isVisualMode() then normal("v") end
	normal("$")

	-- loop ensure trailing whitespace is not counted
	---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
	local lineContent = fn.getline(".") ---@type string
	local col = fn.col("$")
	repeat
		normal("h")
		col = col - 1
		local lastChar = lineContent:sub(col, col)
	until not lastChar:find("%s") or col == 1

	normal("h")
end

---rest of paragraph (linewise)
function M.restOfParagraph()
	if not isVisualLineMode() then normal("V") end
	normal("}k")
end

---DIAGNOSTIC TEXT OBJECT
---similar to https://github.com/andrewferrier/textobj-diagnostic.nvim
---requires builtin LSP
function M.diagnosticTextobj()
	local diag = vim.diagnostic.get_next { wrap = false }
	if not diag then return end
	local curLine = fn.line(".")
	if curLine + lookForwardLines > diag.lnum then return end
	setSelection(diag.lnum + 1, diag.end_lnum + 1, diag.col, diag.end_col)
end

--------------------------------------------------------------------------------

-- INDENTATION OBJECT
---indentation textobj, based on https://thevaluable.dev/vim-create-text-objects/
---@param startBorder boolean
---@param endBorder boolean
function M.indentTextObj(startBorder, endBorder)
	local function isBlankLine(lineNr)
		---@diagnostic disable-next-line: assign-type-mismatch
		local lineContent = fn.getline(lineNr) ---@type string
		return string.find(lineContent, "^%s*$") == 1
	end

	if isBlankLine(fn.line(".")) then return end -- abort on blank line

	local indentofStart = fn.indent(fn.line("."))
	if indentofStart == 0 then return end -- do not select whole file

	local prevLnum = fn.line(".") - 1 -- line before cursor
	while prevLnum > 0 and (isBlankLine(prevLnum) or fn.indent(prevLnum) >= indentofStart) do
		prevLnum = prevLnum - 1
	end
	local nextLnum = fn.line(".") + 1 -- line after cursor
	local lastLine = fn.line("$")
	while nextLnum <= lastLine and (isBlankLine(nextLnum) or fn.indent(nextLnum) >= indentofStart) do
		nextLnum = nextLnum + 1
	end

	-- differentiate ai and ii
	if not startBorder then prevLnum = prevLnum + 1 end
	if not endBorder then nextLnum = nextLnum - 1 end

	-- set selection
	setCursor(0, { prevLnum, 0 })
	if not (isVisualLineMode()) then normal("V") end
	normal("o")
	setCursor(0, { nextLnum, 0 })
end

--------------------------------------------------------------------------------

---VALUE TEXT OBJECT
---@param inner boolean
function M.valueTextObj(inner)
	---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
	local lineContent = fn.getline(".") ---@type string
	local i = 0
	local pattern = "[=:] ?"

	local row = seekForward(pattern)
	if not row then return end

	local _, start = lineContent:find(pattern)

	-- valueEnd either comment or end of line
	local comStrPattern = bo
		.commentstring
		:gsub(" ?%%s.*", "") -- remove placeholder and backside of commentstring
		:gsub("(.)", "%%%1") -- escape commentstring so it's a valid lua pattern
	local ending, _ = lineContent:find(".. ?" .. comStrPattern)
	if not valueEnd or comStrPattern == "" then valueEnd = #lineContent - 1 end

	-- inner value = without trailing comma/semicolon
	local lastChar = lineContent:sub(ending + 1, ending + 1)
	if inner and lastChar:find("[,;]") then valueEnd = valueEnd - 1 end

	setSelection(row, row, start, ending)
end

--------------------------------------------------------------------------------
-- FILETYPE SPECIFIC TEXTOBJS

---md links textobj
---@param inner boolean inner or outer link
function M.mdlinkTextobj(inner)
	---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
	local lineContent = fn.getline(".") ---@type string
	normal("F[") -- go to beginning of link so it can be found when standing on it
	local curRow, curCol = unpack(getCursor(0))
	local start, ending, barelink
	local i = 0

	-- determine next row with link
	local mdLinkPattern = "(%b[])%b()"
	local hasLink = lineContent:find(mdLinkPattern, curCol)
	while not hasLink do
		i = i + 1
		---@diagnostic disable-next-line: assign-type-mismatch
		lineContent = fn.getline(curRow + i) ---@type string
		hasLink = lineContent:find(mdLinkPattern, curCol)
		curCol = 1 -- after the current row, pattern can occur everywhere in the line
		if i > lookForwardLines then return end
	end
	curRow = curRow + i

	-- determine location of link in row
	if inner then
		start, _, barelink = lineContent:find(mdLinkPattern, curCol)
		ending = start + #barelink - 3
	else
		start, ending = lineContent:find(mdLinkPattern, curCol)
		start = start - 1
		ending = ending - 1
	end

	setSelection(curRow, curRow, start, ending)
end

---JS Regex
---@param inner boolean inner regex
function M.jsRegexTextobj(inner)
	---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
	local lineContent = fn.getline(".") ---@type string
	normal("F/") -- go to beginning of regex
	local curRow, curCol = unpack(getCursor(0))
	local i = 0

	-- determine next row with selector
	local pattern = [[/.-[^\]/]] -- to not match escaped slash in regex
	local hasPattern = lineContent:find(pattern)
	while not hasPattern do
		i = i + 1
		---@diagnostic disable-next-line: assign-type-mismatch
		lineContent = fn.getline(curRow + i) ---@type string
		hasPattern = lineContent:find(pattern)
		curCol = 1 -- after the current row, pattern can occur everywhere in the line
		if i > lookForwardLines then return end
	end
	curRow = curRow + i

	-- determine location in row
	local start, ending = lineContent:find(pattern, curCol)
	if inner then
		ending = ending - 2
	else
		ending = ending - 1
		start = start - 1
	end

	setSelection(curRow, curRow, start, ending)
end

---CSS Selector Textobj
---@param inner boolean inner selector
function M.cssSelectorTextobj(inner)
	---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
	local lineContent = fn.getline(".") ---@type string
	normal("F.") -- go to beginning of selector
	local curRow, curCol = unpack(getCursor(0))
	local i = 0

	-- determine next row with selector
	local pattern = "%.[%w-_]+"
	local hasPattern = lineContent:find(pattern)
	while not hasPattern do
		i = i + 1
		---@diagnostic disable-next-line: assign-type-mismatch
		lineContent = fn.getline(curRow + i) ---@type string
		hasPattern = lineContent:find(pattern)
		curCol = 1 -- after the current row, pattern can occur everywhere in the line
		if i > lookForwardLines then return end
	end
	curRow = curRow + i

	-- determine location of selector in row
	local start, ending = lineContent:find(pattern, curCol)
	ending = ending - 1
	if not inner then start = start - 1 end

	setSelection(curRow, curRow, start, ending)
end

--------------------------------------------------------------------------------
return M
