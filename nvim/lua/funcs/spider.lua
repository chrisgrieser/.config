local M = {}

local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor

---equivalent to fn.getline(), but using more efficient nvim api
---@param lnum integer
---@return string
local function getline(lnum)
	local lineContent = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, true)
	return lineContent[1]
end

local lowerWordPattern = "[%a%d][%l%d]+" -- at least two, first may be uppercase for CamelCase
local upperWordPattern = "[%u%d][%u%d]+" -- at least two, needed for SCREAMING_SNAKE_CASE
local punctPattern = "[%p][%p][%p]+" -- at least three

--------------------------------------------------------------------------------

---search for the next item to move to
---@param mode string e|w|b (currently only e)
function M.search(mode)
	local cursorRow, cursorCol = unpack(getCursor(0))
	local line = getline(cursorRow)
	local lowerPos, upperPos, punctPos

	if mode == "w" then
		lowerPos, _ = line:find(lowerWordPattern, cursorCol)
		upperPos, _ = line:find(upperWordPattern, cursorCol)
		punctPos, _ = line:find(punctPattern, cursorCol)
	elseif mode == "e" then
		_, lowerPos = line:find(lowerWordPattern, cursorCol)
		_, upperPos = line:find(upperWordPattern, cursorCol)
		_, punctPos = line:find(punctPattern, cursorCol)
		lowerPos = lowerPos - 1
		upperPos = 
		punctPos = 
	end
	if not (lowerPos or upperPos or punctPos) then
		vim.notify("None found in this line", vim.log.levels.WARN)
		return	
	end
	lowerPos = lowerPos or math.huge -- math.huge will never be the smallest number
	upperPos = upperPos or math.huge
	punctPos = punctPos or math.huge

	local closestPos = math.min(lowerPos, upperPos, punctPos)
	setCursor(0, {cursorRow, closestPos})	
end

--------------------------------------------------------------------------------
return M
