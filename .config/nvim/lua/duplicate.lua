local fn = vim.fn
local api = vim.api
local getCursor = vim.api.nvim_win_get_cursor(0)
--------------------------------------------------------------------------------

function duplicate()
	local line = fn.getline(".") ---@diagnostic disable-line: param-type-mismatch
	fn.append(".", line) ---@diagnostic disable-line: param-type-mismatch
	local lineNum = getCursor(0)[1] + 1 -- line down
	local colNum = getCursor(0)[2]
	api.nvim_win_set_cursor(0, {lineNum, colNum})
end
