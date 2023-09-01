
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
end
