local i = 1
local total = 3

local next = math.fmod(i - 1 - total, total) + total
vim.notify("❗ next: " .. tostring(next))
