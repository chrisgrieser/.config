
-- goodbye
-- goodbye

local bufsInQf = vim.tbl_map(function (item) return item.bufnr end, vim.fn.getqflist())
local uniqueFiles = #vim.fn.uniq(bufsInQf)
vim.notify("🪚 uniqueFiles: " .. vim.inspect(uniqueFiles))
