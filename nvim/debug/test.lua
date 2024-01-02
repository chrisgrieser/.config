
local a, b, c

c = "c"
b = "bb"

local out = a or b or c
vim.notify("🪚 out: " .. tostring(out))
