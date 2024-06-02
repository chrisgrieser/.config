
local buffers = vim.api.nvim_list_bufs()

vim.notify("⭕ buffers: " .. vim.inspect(buffers))
