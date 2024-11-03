-- local out = require("lspconfig").util.available_servers()

local allOps = {}
vim.list_extend(allOps, vim.tbl_keys(require("genghis.operations.file")))
vim.list_extend(allOps, vim.tbl_keys(require("genghis.operations.copy")))
vim.list_extend(allOps, vim.tbl_keys(require("genghis.operations.other")))

vim.notify("🖨️ allOps: " .. vim.inspect(allOps))
