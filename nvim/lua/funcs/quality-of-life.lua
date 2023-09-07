local M = {}
local u = require("config.utils")

local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

--------------------------------------------------------------------------------
-- CONFIG
local commentChar = "─"
local commentWidth = tostring(vim.opt_local.colorcolumn:get()[1]) - 1
local toggleSigns = {
	["|"] = "&",
	[","] = ";",
	["'"] = '"',
	["^"] = "$",
	["/"] = "*",
	["+"] = "-",
	["("] = ")",
	["["] = "]",
	["{"] = "}",
	["<"] = ">",
}
--------------------------------------------------------------------------------

function M.commentHr()
	local wasOnBlank = vim.api.nvim_get_current_line() == ""
	local indent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch
	local comStr = vim.bo.commentstring
	local ft = vim.bo.filetype
	local comStrLength = #(comStr:gsub(" ?%%s ?", ""))

	if comStr == "" then
		u.notify("No commentstring for this filetype available.", "warn")
		return
	end
	if comStr:find("-") then commentChar = "-" end

	local linelength = commentWidth - indent - comStrLength

	-- the common formatters (black and stylelint) demand extra spaces
	local fullLine
	if ft == "css" then
		fullLine = " " .. commentChar:rep(linelength - 2) .. " "
	elseif ft == "python" then
		fullLine = " " .. commentChar:rep(linelength - 1)
	else
		fullLine = commentChar:rep(linelength)
	end

	-----------------------------------------------------------------------------
	-- set HR
	local hr = comStr:gsub(" ?%%s ?", fullLine)
	if ft == "markdown" then hr = "---" end

	-----------------------------------------------------------------------------

	local linesToAppend = { "", hr, "" }
	if wasOnBlank then linesToAppend = { hr, "" } end

	vim.fn.append(".", linesToAppend) ---@diagnostic disable-line: param-type-mismatch

	-- shorten if it was on blank line, since fn.indent() does not return indent
	-- line would have if it has content
	if wasOnBlank then
		vim.cmd.normal { "j==", bang = true }
		local hrIndent = vim.fn.indent(".") ---@diagnostic disable-line: param-type-mismatch

		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = vim.api.nvim_get_current_line()
		hrLine = hrLine:gsub(commentChar, "", hrIndent)
		vim.api.nvim_set_current_line(hrLine)
	else
		vim.cmd.normal { "jj==", bang = true }
	end
end

function M.toggleCase()
	local col = vim.fn.col(".") -- fn.col correctly considers tab-indentation
	local charUnderCursor = vim.api.nvim_get_current_line():sub(col, col)
	local isLetter = charUnderCursor:find("^%a$")
	if isLetter then
		normal("~h")
		return
	end
	for left, right in pairs(toggleSigns) do
		if charUnderCursor == left then normal("r" .. right) end
		if charUnderCursor == right then normal("r" .. left) end
	end
end

function M.openNewScope()
	local line = vim.api.nvim_get_current_line()
	local trailComma = line:match(",?$")
	line = line:gsub("[, ]+$", "") .. " {" -- edit current line
	vim.api.nvim_set_current_line(line)
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	local indent = line:match("^%s*")
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. "\t", indent .. "}" .. trailComma })
	vim.api.nvim_win_set_cursor(0, { ln + 1, 1 }) -- go line down
	vim.cmd.startinsert { bang = true }
end

--------------------------------------------------------------------------------

function M.scrollHoverWin(direction)
	local a = vim.api
	local scrollCmd = (direction == "down" and "5j" or "5k")
	local winIds = a.nvim_tabpage_list_wins(0)
	for _, winId in ipairs(winIds) do
		local isHover = a.nvim_win_get_config(winId).relative ~= ""
			and a.nvim_win_get_config(winId).focusable
		if isHover then
			a.nvim_set_current_win(winId)
			normal(scrollCmd)
			return
		end
	end
	u.notify("No floating windows found. ", "warn")
end

---@param direction "up"|"down"
function M.gotoNextIndentChange(direction)
	local isBlankLine = function(lnum) return vim.fn.getline(lnum):find("^%s*$") end

	local lastLineNum = vim.api.nvim_buf_line_count(0)
	local increment = direction == "up" and -1 or 1
	local stopAtLine = direction == "up" and 1 or lastLineNum
	local lineNum, colNum = unpack(vim.api.nvim_win_get_cursor(0))

	-- blank lines always have indent 0, so we go to the next non-blank to
	-- determine the "true" indent
	local currentIndent
	while true do
		currentIndent = vim.fn.indent(lineNum)
		if not isBlankLine(lineNum) then break end
		lineNum = lineNum + increment
	end

	local targetLineNum
	for i = lineNum, stopAtLine, increment do
		targetLineNum = i
		local indent = vim.fn.indent(i)
		if indent ~= currentIndent and not isBlankLine(i) then break end
	end
	vim.api.nvim_win_set_cursor(0, { targetLineNum, colNum })
end

--------------------------------------------------------------------------------

return M
