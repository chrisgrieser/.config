local M = {}
--------------------------------------------------------------------------------

-- Decode one UTF-8 codepoint starting from position `i`
--- @param str string The UTF-8 encoded string
--- @param i number The starting byte index
--- @return number? cp The decoded codepoint
--- @return number? next_i The next byte index
local function utf8Decode(str, i)
	local c = str:byte(i)

	if not c then return end
	if c < 0x80 then
		return c, i + 1
	elseif c < 0xE0 then
		local c2 = str:byte(i + 1)
		return ((c % 0x20) * 0x40 + (c2 % 0x40)), i + 2
	elseif c < 0xF0 then
		local c2, c3 = str:byte(i + 1, i + 2)
		return ((c % 0x10) * 0x1000 + (c2 % 0x40) * 0x40 + (c3 % 0x40)), i + 3
	elseif c < 0xF8 then
		local c2, c3, c4 = str:byte(i + 1, i + 3)
		return ((c % 0x08) * 0x40000 + (c2 % 0x40) * 0x1000 + (c3 % 0x40) * 0x40 + (c4 % 0x40)), i + 4
	end
end

---Check if a codepoint is likely an emoji
---@param cp number The Unicode codepoint
---@return boolean -- True if the codepoint is an emoji
local function isEmoji(cp)
	return (
		(cp >= 0x1F600 and cp <= 0x1F64F) -- Emoticons
		or (cp >= 0x1F300 and cp <= 0x1F5FF) -- Misc Symbols and Pictographs
		or (cp >= 0x1F680 and cp <= 0x1F6FF) -- Transport and Map
		or (cp >= 0x1F900 and cp <= 0x1F9FF) -- Supplemental Symbols and Pictographs
		or (cp >= 0x1FA70 and cp <= 0x1FAFF) -- Extended-A
		or (cp >= 0x2600 and cp <= 0x26FF) -- Misc symbols
		or (cp >= 0x2700 and cp <= 0x27BF) -- Dingbats
	)
end

---Find the first emoji in a string and return its position
---@param text string The input string
---@param offset number? Optional starting byte index (defaults to 1)
---@return number? startPos The byte index of the start of the emoji
---@return number? endPos The byte index of the end of the emoji
---@return string? emoji The emoji found
local function findEmoji(text, offset)
	local i = offset or 1

	while i <= #text do
		local cp, nextI = utf8Decode(text, i)
		if not (cp and nextI) then break end

		if isEmoji(cp) then return i, nextI - 1, text:sub(i, nextI - 1) end

		i = nextI
	end

	return nil
end

--------------------------------------------------------------------------------

function M.emojiTextobj()
	local function getLine(lnum) return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local lastLine = vim.api.nvim_buf_line_count(0)

	local startPos, endPos
	while true do
		local line = getLine(row)
		startPos, endPos = findEmoji(line, col)
		if startPos then break end
		col = 1 -- only seek partial line for first line
		row = row + 1
		if row > lastLine then return end
	end
		
	Chainsaw(startPos) -- 🪚
	Chainsaw(endPos) -- 🪚
end

--------------------------------------------------------------------------------
return M
