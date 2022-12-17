local normal = vim.cmd.normal
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local cmd = vim.cmd
local bo = vim.bo
local fn = vim.fn
local opt = vim.opt
local logWarn = vim.log.levels.WARN

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

local M = {}

--------------------------------------------------------------------------------

local lookForwardLines = 5
--------------------------------------------------------------------------------

---Subword (word with "-_" as delimiters)
function M.subword()
	local iskeywBefore = opt.iskeyword:get()
	opt.iskeyword:remove { "_", "-", "." }
	if not isVisualMode() then normal { "v", bang = true } end
	normal { "iw", bang = true }
	opt.iskeyword = iskeywBefore
end

---near end of the line
function M.nearEoL()
	if not isVisualMode() then normal { "v", bang = true } end
	normal { "$hh", bang = true }
end

---rest of paragraph (linewise)
function M.restOfParagraph()
	if not isVisualLineMode() then normal { "V", bang = true } end
	normal { "}", bang = true }
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
	if not (isVisualLineMode()) then cmd.normal { "V", bang = true } end
	cmd.normal { "o", bang = true }
	setCursor(0, { nextLnum, 0 })
end

--------------------------------------------------------------------------------

-- VALUE TEXT OBJECT
---@param inner boolean
function M.valueTextObj(inner)
	---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
	local lineContent = fn.getline(".") ---@type string

	local _, valueStart = lineContent:find("[=:] ?")
	if not valueStart then
		vim.notify("No value found in current line.", logWarn)
		return
	end

	-- valueEnd either comment or end of line
	local comStrPattern = bo
		.commentstring
		:gsub(" ?%%s.*", "") -- remove placeholder and backside of commentstring
		:gsub("(.)", "%%%1") -- escape commentstring so it's a valid lua pattern
	local valueEnd, _ = lineContent:find(".. ?" .. comStrPattern)
	if not valueEnd or comStrPattern == "" then valueEnd = #lineContent - 1 end

	-- inner value = without trailing comma/semicolon
	local lastChar = lineContent:sub(valueEnd + 1, valueEnd + 1)
	if inner and lastChar:find("[,;]") then valueEnd = valueEnd - 1 end

	-- set selection
	local currentRow = fn.line(".")
	setCursor(0, { currentRow, valueStart })
	if isVisualMode() then
		cmd.normal { "o", bang = true }
	else
		cmd.normal { "v", bang = true }
	end
	setCursor(0, { currentRow, valueEnd })
end

--------------------------------------------------------------------------------
-- FILETYPE SPECIFIC TEXTOBJS

---md links textobj
---@param inner boolean inner or outer link
function M.mdlinkTextobj(inner)
	---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
	local lineContent = fn.getline(".") ---@type string
	local curRow, curCol = unpack(getCursor(0))
	local start, ending, barelink, hasLink
	local i = -1

	normal { "F[", bang = true } -- go to beginning of link so it can be found when standing on it

	-- determine next row with link
	local mdLinkPattern = "(%b[])%b()"
	while not hasLink do
		i = i + 1
		---@diagnostic disable-next-line: assign-type-mismatch
		lineContent = fn.getline(curRow + i) ---@type string
		hasLink = lineContent:find(mdLinkPattern)
		if i > lookForwardLines then
			setCursor(0, { curRow, curCol }) -- restore pevious mouse location
			return
		end
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

	setCursor(0, { curRow, start })
	if isVisualMode() then
		normal { "o", bang = true }
	else
		normal { "v", bang = true }
	end
	setCursor(0, { curRow, ending })
end

---CSS Selector Textobj
---@param inner boolean inner selector
function M.cssSelectorTextobj(inner)
	---@diagnostic disable-next-line: param-type-mismatch, assign-type-mismatch
	local lineContent = fn.getline(".") ---@type string
	local curRow, curCol = unpack(getCursor(0))
	local i = -1

	normal { "F.", bang = true } -- go to beginning of selector

	-- determine next row with selector
	local selectorPattern = "%.[%w-_]+"
	while not hasSelector do
		i = i + 1
		---@diagnostic disable-next-line: assign-type-mismatch
		lineContent = fn.getline(curRow + i) ---@type string
		hasSelector = lineContent:find(selectorPattern)
		if i > lookForwardLines then
			setCursor(0, { curRow, curCol }) -- restore pevious mouse location
			return
		end
	end
	curRow = curRow + i

	-- determine location of selector in row
	local start, ending = lineContent:find(selectorPattern, curCol)
	ending = ending - 1
	if not inner then start = start - 1 end

	setCursor(0, { curRow, start })
	if isVisualMode() then
		normal { "o", bang = true }
	else
		normal { "v", bang = true }
	end
	setCursor(0, { curRow, ending })
end

--------------------------------------------------------------------------------
return M
