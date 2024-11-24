-- local specRoot = require("lazy.core.config").options.spec.import
-- local specPath = vim.fn.stdpath("config") .. "/lua/" .. specRoot
-- local specFiles = {}
-- for name, type in vim.fs.dir(specPath) do
-- 	if type == "file" then table.insert(specFiles, name) end
-- end
local thisfile = vim.api.nvim_buf_get_name(0)
local stats = vim.uv.fs_stat(thisfile)
vim.notify(vim.inspect(stats), nil, { title = "🖨️ stats", ft = "lua" })
