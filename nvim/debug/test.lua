

local path = "/Users/chrisgrieser/.config/nvim/debug/dddd"
local success = vim.fn.mkdir(path, "p")
vim.notify("🪚 success: " .. tostring(success))
