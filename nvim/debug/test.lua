-- local foo = 5
-- local result = assert(foo, "🪚 foo not 5   ")
-- print(result + 10)

--------------------------------------------------------------------------------

---@param lines string[]
---@return string[] dedentedLines
local function dedent(lines)
	local indents = {}
	for _, line in ipairs(lines) do
		local indent = line:match("^%s*")
		table.insert(indents, #indent)
	end
	local smallestIndent = math.min(unpack(indents))
	local dedentedLines = vim.tbl_map(function(line) return line:sub(smallestIndent + 1) end, lines)
	return dedentedLines
end

local result = dedent({ "  foo", "   bar", "  baz" })
vim.notify("🪚 result: " .. vim.inspect(result))


--------------------------------------------------------------------------------


local numbers = { 1, 2, 3, 4, 5, 6 }
local usedNumbers = {}
local sum = 10
local temp

for _, v in ipairs(numbers) do
	sum = sum + v
	sum = sum / 2
	table.insert(usedNumbers, v * 2)

	temp = vim.inspect(usedNumbers)
	print(temp)
	print("hi" .. tostring(v))
end
