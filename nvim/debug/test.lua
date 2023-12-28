
local list = {
	"one",
	"two",
	"three",
	"four",
	"five",
} 
local splitAt = 2

local part1 = vim.list_slice(list, 1, splitAt)
local part2 = vim.list_slice(list, splitAt + 1, #list)
