local path = "/Users/chrisgrieser/.config/nvim/debug/repro.lua"
local bufnr = vim.fn.bufadd(path)
vim.notify("🖨️ bufnr: " .. tostring(bufnr))
vim.fn.bufload(bufnr)
vim.cmd.buffers{ bang = true }
