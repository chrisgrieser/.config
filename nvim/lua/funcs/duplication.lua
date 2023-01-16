local M = {}

local append = vim.fn.append
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor

---equivalent to fn.getline(), but using more efficient nvim api
---@param lnum integer|string
---@return string
local function getline(lnum)
	local arg
	if type(lnum) == "number" then
		arg = lnum
	elseif lnum == "." then
		local curRow = getCursor(0)[1]
		arg = curRow
	else
		return ""
	end
	local lineContent = vim.api.nvim_buf_get_lines(0, arg - 1, arg, true)
	return lineContent[1]
end

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

--------------------------------------------------------------------------------

function M.duplicateSelection()
	local prevReg = fn.getreg("z")
	cmd([[noautocmd silent! normal!"zy`]"zp]]) -- `noautocmd` to not trigger highlighted-yank
	fn.setreg("z", prevReg)
end

-- Duplicate line under cursor, change occurrences of certain words to their
-- opposite, e.g., "right" to "left", and move cursor to key is there is one
function M.cssDuplicateLine()
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
	elseif
		line:find("width")
		and not (line:find("border-width"))
		and not (line:find("outline-width"))
	then
		line = line:gsub("width", "height")
	end

	append(".", line) ---@diagnostic disable-line: param-type-mismatch

	-- cursor moved to key if there is one
	local lineNum, colNum = unpack(getCursor(0))
	lineNum = lineNum + 1 -- line down
	local keyPos = line:find(".%w+ ?: ?")
	if keyPos then colNum = keyPos end
	setCursor(0, { lineNum, colNum })
end

-- Duplicate line under cursor, smartly change words like "if" to "elseif",
-- and if there is a variable assignment with a numbered variable like "item1",
-- then increment the number. If there is a variable assignment or key-value
-- pair, move to the key
function M.smartDuplicateLine()
	local line = getline(".")
	local ft = bo.filetype

	-- smart switching of conditionals
	if ft == "lua" and line:find("^%s*if.+then$") then
		line = line:gsub("^(%s*)if", "%1elseif")
	elseif (ft == "bash" or ft == "zsh" or ft == "sh") and line:find("^%s*if.+then$") then
		line = line:gsub("^(%s*)if", "%1elif")
	elseif (ft == "javascript" or ft == "typescript") and line:find("^%s*if.+{$") then
		line = line:gsub("^(%s*)if", "%1} else if")
	end

	-- increment numbered vars
	local lineHasNumberedVarAssignment, _, num = line:find("(%d+).*=")
	if lineHasNumberedVarAssignment then
		local nextNum = tostring(tonumber(num) + 1)
		line = line:gsub("%d+(.*=)", nextNum .. "%1")
	end

	append(".", line) ---@diagnostic disable-line: param-type-mismatch

	-- cursor movement to value if there is one
	local lineNum, colNum = unpack(getCursor(0))
	lineNum = lineNum + 1 -- line down
	local _, valuePos = line:find(".%w+ ?[:=] ?")
	if valuePos then colNum = valuePos end
	setCursor(0, { lineNum, colNum })
end

--------------------------------------------------------------------------------
-- `:h :map-operator`
function g.duplicationOperator(motionType)
	if motionType == "block" then
		vim.notify("Blockwise is not supported", vim.log.levels.WARN)
		return
	end
	normal([['[V']"zy']"zp]])
end

function M.duplicateLines()
	opt.opfunc = "v:lua.duplicationOperator"
	return "g@"
end

--------------------------------------------------------------------------------

return M
