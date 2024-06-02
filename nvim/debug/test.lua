local line = 5
local ns = vim.api.nvim_create_namespace("ysi")

vim.highlight.range(0, ns, "IncSearch", { line - 1, 0 }, { line - 0, 0 })
vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end, 1000)
-- test
-- test
-- test
