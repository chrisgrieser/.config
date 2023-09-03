-- local foo = 5
-- local result = assert(foo, "🪚 foo not 5   ")
-- print(result + 10)

---@param lines string[]
---@return string[] dedentedLines
local function dedent(lines)
	local indentAmounts = vim.tbl_map(function(line) return #(line:match("^%s*")) end, lines)
	local smallestIndent = math.min(unpack(indentAmounts))
	local dedentedLines = vim.tbl_map(function(line) return line:sub(smallestIndent + 1) end, lines)
	return dedentedLines
end

local result = dedent({ "  foo", "   bar", "  baz" })
vim.notify("🪚 result: " .. vim.inspect(result))

