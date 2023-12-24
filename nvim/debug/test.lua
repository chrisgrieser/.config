
local bufPath = vim.api.nvim_buf_get_name(0)
local rootFile = vim.fs.find({".git", "Makefile"}, { upward = true, path = bufPath })[1]
local rootFolder = vim.fs.dirname(rootFile)
vim.notify("🪚 rootFolder: " .. tostring(rootFolder))
