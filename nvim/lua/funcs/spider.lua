local M = {}
--------------------------------------------------------------------------------
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor

---equivalent to fn.getline(), but using more efficient nvim api
---@param lnum integer
---@return string
local function getline(lnum)
	local lineContent = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, true)
	return lineContent[1]
end

local wordPattern = "[%l%d]+"
local punctuationPattern = "[%p][%p]"

--------------------------------------------------------------------------------

function M.e ()
	local cursorRow, cursorCol = unpack(getCursor(0))
	local line = getline(cursorRow)
end

--------------------------------------------------------------------------------
return M


