
local list = {
	"one",
	"two",
	"three",
	"four",
	"five",
} 
local splitAt = 1

local part1 = vim.list_slice(list, 1, splitAt)
vim.notify("🪚 part1: " .. vim.inspect(part1))
local part2 = vim.list_slice(list, splitAt + 1, #list)
vim.notify("🪚 part2: " .. vim.inspect(part2))
