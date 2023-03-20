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

local lowerWord = "[%a%d][%l%d]+" -- at least two, first may be uppercase for CamelCase
local upperWord = "[%u%d][%u%d]+" -- at least two, needed for SCREAMING_SNAKE_CASE
local singleLetter = "%f[%w]%w[^%w]" -- single alphanumeric character
local punctuation = "[%p][%p][%p]+" -- at least three

---get the minimum of the three numbers, considering that any may be nil
---@param pos1 number|nil
---@param pos2 number|nil
---@param pos3 number|nil
---@param pos4 number|nil
---@return number|nil returns nil of all numbers are nil
local function minimum(pos1, pos2, pos3, pos4)
	if not (pos1 or pos2 or pos3) then return nil end
	pos1 = pos1 or math.huge -- math.huge will never be the smallest number
	pos2 = pos2 or math.huge
	pos3 = pos3 or math.huge
	pos4 = pos4 or math.huge
	return math.min(pos1, pos2, pos3, pos4)
end

--------------------------------------------------------------------------------

---search for the next item to move to
---@param key string e|w|b (currently only e and w)
function M.search(key)
	local row, col = unpack(getCursor(0))
	col = col +a 1 -- force moving to the next position
	local line = getline(row)
	local closestPos

	-- determine end of word
	local _, lowerPos = line:find(lowerWord, col)
	local _, upperPos = line:find(upperWord, col)
	local _, punctPos = line:find(punctuation, col)
	local singlePos, _ = line:find(singleLetter, col + 1)
	local endOfWord = minimum(lowerPos, upperPos, punctPos, singlePos)
	if not endOfWord then return end

	if key == "w" then
		-- determine start of next word
		lowerPos, _ = line:find(lowerWord, endOfWord)
		upperPos, _ = line:find(upperWord, endOfWord)
		punctPos, _ = line:find(punctuation, endOfWord)
		singlePos, _ = line:find(singleLetter, endOfWord)
		closestPos = minimum(lowerPos, upperPos, punctPos, singlePos)
		if not closestPos then return end
	elseif key == "e" then
		closestPos = endOfWord
	end
	closestPos = closestPos - 1

	-- move to new location
	if vim.fn.mode() == "o" then vim.cmd.normal{"v", bang = true} end
	setCursor(0, { row, closestPos })
end

--------------------------------------------------------------------------------
return M
