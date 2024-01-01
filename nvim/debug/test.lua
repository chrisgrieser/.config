--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local bufText = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")

local numbers = {}
local tokenPattern = "${?(%d+)[:|]" -- match `$1`, `${2:word}`, or `${3|word|}`
for token in bufText:gmatch(tokenPattern) do
	table.insert(numbers, tonumber(token))
end

local highestToken = math.max(unpack(numbers))
vim.notify("🪚 highest: " .. tostring(highestToken))

