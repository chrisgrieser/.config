local normal = vim.cmd.normal
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local cmd = vim.cmd
local fn = vim.fn
local M = {}
local lookForwardLines = 5
local bo = vim.bo
local logWarn = vim.log.levels.WARN
--------------------------------------------------------------------------------

-- <Space>: Subword (-_ as delimiters)
function M.subword()
	local iskeywBefore = vim.opt.iskeyword:get()
	vim.opt.iskeyword:remove { "_", "-", "." }
	cmd.normal { "viw", bang = true }
	vim.opt.iskeyword = iskeywBefore
end

-- n: [n]ear end of the line
function M.nearEoL() 
	normal { "v$hh", bang = true }
end

-- r: [r]est of paragraph (linewise)
function M.restOfParagraph() 
	cmd.normal { "V}", bang = true }
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
	cmd.normal { "Vo", bang = true }
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
	if fn.mode():find("v") then
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
	local linkStart, linkEnd, barelink, hasLink
	local i = -1

	normal { "F[", bang = true } -- go to beginning of link so it can be found when standing on it

	-- determine next row with link
	local mdLinkPattern = "(%b[])%b()"
	print("beep")
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
		linkStart, _, barelink = lineContent:find(mdLinkPattern, curCol)
		linkEnd = linkStart + #barelink - 3
	else
		linkStart, linkEnd = lineContent:find(mdLinkPattern, curCol)
		linkStart = linkStart - 1
		linkEnd = linkEnd - 1
	end

	setCursor(0, { curRow, linkStart })
	if fn.mode():find("v") then
		normal { "o", bang = true }
	else
		normal { "v", bang = true }
	end
	setCursor(0, { curRow, linkEnd })
end

---CSS Selector Textobj
---@param inner boolean inner selector?
function M.cssSelectorTextobj(inner)
	--ensure "-" is keyword for kebabcase
	local dashNotKeyword = not (bo.iskeyword:find(",-"))
	if dashNotKeyword then
		bo.iskeyword = bo.iskeyword .. ",-"
	end

	if not (fn.mode():find("[Vv]")) then
		cmd.normal {"v", bang = true}
	end
	cmd.normal {"iwo", bang = true}
	local _, col = unpack(getCursor(0))

	-- include the "." with outer selector
	---@diagnostic disable-next-line: param-type-mismatch, undefined-field
	local charBefore = fn.getline("."):sub(col, col)
	if charBefore == "." and not (inner) then
		cmd.normal {"h", bang = true}
	end

	-- restore previous iskeyword option
	if dashNotKeyword then
		bo.iskeyword = bo.iskeyword:sub(0, -2)
	end

end

--------------------------------------------------------------------------------
return M
