print("hi")

local numbers = { 1, 2, 3, 4, 5, 6 }
local usedNumbers = {}
local sum = 10

for _, v in ipairs(numbers) do
	sum = sum + v
	sum = sum / 2
	table.insert(usedNumbers, v * 2)

	local temp = vim.inspect(usedNumbers)
	print(temp)
end
