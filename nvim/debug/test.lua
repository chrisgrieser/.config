local info = vim.fn.getbufinfo(0)
vim.notify("⭕ info: " .. vim.inspect(info))
