
---@param lines string[]
---@param max_width number
---@return string[]
local function customWrap(lines, max_width)
	local function split_length(line, width)
		local text = {}
		local next_line
		while true do
			if #line == 0 then return text end
			next_line, line = line:sub(1, width), line:sub(width)
			text[#text + 1] = next_line
		end
	end

	local wrappedLines = {}
	for _, line in pairs(lines) do
		local new_lines = split_length(line, max_width)
		new_lines = new_lines
		for _, nl in ipairs(new_lines) do
			nl = nl:gsub("^%s*", ""):gsub("%s*$", "")
			table.insert(wrappedLines, " " .. nl .. " ")
		end
	end

	return wrappedLines
end

local out = customWrap({ "Lorem ipsum dolor sit amet" }, 10)
vim.notify(table.concat(out, "\n"))

--------------------------------------------------------------------------------

-- local foo = 5
-- local result = assert(foo, "🪚 foo not 5   ")
-- print(result + 10)

--------------------------------------------------------------------------------

-- local numbers = { 1, 2, 3, 4, 5, 6 }
-- local usedNumbers = {}
-- local sum = 10
-- local temp
-- for _, v in ipairs(numbers) do
-- 	sum = sum + v
-- 	sum = sum / 2
-- 	table.insert(usedNumbers, v * 2)
-- 	temp = vim.inspect(usedNumbers)
-- 	print(temp)
-- 	print("hi" .. tostring(v))
-- end
