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

---get the minimum of the three numbers, considering that any may be nil
---@param pos1 number|nil
---@param pos2 number|nil
---@param pos3 number|nil
---@return number|nil returns nil of all numbers are nil
local function minimum(pos1, pos2, pos3)
	if not (pos1 or pos2 or pos3) then
		return nil
	end
	pos1 = pos1 or math.huge -- math.huge will never be the smallest number
	pos2 = pos2 or math.huge
	pos3 = pos3 or math.huge
	return = math.min(pos1, pos2, pos3)
	return closestPos - 1 -- cause `:find` is off by one
end

--------------------------------------------------------------------------------

---search for the next item to move to
---@param mode string e|w|b (currently only e and w)
function M.search(mode)
	local row, col = unpack(getCursor(0))
	col = col + 1 -- to only find the next position, not the position the cursor is stand on
	local line = getline(row)
	local lowerPos, upperPos, punctPos

	-- find
	if mode == "w" then
		_, lowerPos = line:find(lowerWordPattern, col)
		_, upperPos = line:find(upperWordPattern, col)
		_, punctPos = line:find(lowerWordPattern, col)
		lowerPos = line:find(lowerWordPattern, lowerPos)
		upperPos = line:find(upperWordPattern, upperPos)
		punctPos = line:find(punctPattern, punctPos)
	elseif mode == "e" then
		_, lowerPos = line:find(lowerWordPattern, col)
		_, upperPos = line:find(upperWordPattern, col)
		_, punctPos = line:find(punctPattern, col)
	end

	-- determine closest
	if not (lowerPos or upperPos or punctPos) then
		vim.notify("None found in this line", vim.log.levels.WARN)
		return	
	end
	lowerPos = lowerPos or math.huge -- math.huge will never be the smallest number
	upperPos = upperPos or math.huge
	punctPos = punctPos or math.huge
	local closestPos = math.min(lowerPos, upperPos, punctPos)
	closestPos = closestPos - 1 -- cause `:find` is off by one

	-- move to new location
	setCursor(0, {row, closestPos})	
end

--------------------------------------------------------------------------------
return M
