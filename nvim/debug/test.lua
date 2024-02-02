

local path = "/Users/chrisgrieser/.config/nvim/debug/test.lua"
local _, count = path:gsub("z", "")
vim.notify("👽 count: " .. tostring(count))
