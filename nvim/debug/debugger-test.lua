local numbers = { 1, 2, 3, 4, 5, 6 }
local usedNumbers = {}
local sum = 10
local temp

for _, num in ipairs(numbers) do
	sum = sum + num
	table.insert(usedNumbers, num * 2)

	temp = vim.inspect(usedNumbers)
end
