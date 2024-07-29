local M = {}

local function isVisualLineMode()
	local modeWithV = vim.fn.mode():find("V")
	return modeWithV ~= nil
end
local function normal(cmd) vim.cmd.normal { cmd, bang = true } end
local function isCommentedLine(lnum)
	local commentStringRegex = "^%s*"
		.. vim.pesc(vim.bo.commentstring):gsub(" ?%%%%s ?", ".*")
		.. "%s*$"
	return vim.fn.getline(lnum):find(commentStringRegex) ~= nil
end
local function setLinewiseSelection(startline, endline)
	vim.api.nvim_win_set_cursor(0, { startline, 0 })
	if not isVisualLineMode() then normal("V") end
	normal("o")
	vim.api.nvim_win_set_cursor(0, { endline, 0 })
end

---@param lookForwL integer number of lines to look forward for the textobj
function M.multiCommentedLines(lookForwL)
	if vim.bo.commentstring == "" then
		vim.notify("Buffer has no commentstring set.")
		return
	end

	local curLnum = vim.api.nvim_win_get_cursor(0)[1]
	local startLnum = curLnum
	local lastLine = vim.api.nvim_buf_line_count(0)

	while not isCommentedLine(curLnum) do -- when on blank line, use next line
		if curLnum == lastLine or curLnum > startLnum + lookForwL then
			vim.notify("No commented line found.")
			return
		end
		curLnum = curLnum + 1
	end

	local prevLnum = curLnum
	local nextLnum = curLnum
	while prevLnum > 0 and isCommentedLine(prevLnum) do
		prevLnum = prevLnum - 1
	end
	while nextLnum <= lastLine and isCommentedLine(nextLnum) do
		nextLnum = nextLnum + 1
	end

	setLinewiseSelection(prevLnum + 1, nextLnum - 1)
end

return M
