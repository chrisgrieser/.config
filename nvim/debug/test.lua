
local nums = { 1, 4, 6, 5, 100, 0, 2 }
table.sort(nums, function(a, b) return a > b end)
vim.notify("🖨️ nums: " .. vim.inspect(nums))
