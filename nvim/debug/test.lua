
local ns = vim.api.nvim_create_namespace("rebase-extmarks")
vim.api.nvim_buf_set_extmark(0, ns, 0, 0, { virt_text = { { "REBASE", "Comment" } } })
