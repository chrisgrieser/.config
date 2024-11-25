
local ns = vim.api.nvim_create_namespace("chainsaw.markers")
local extmarks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true })

