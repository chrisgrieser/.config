--------------------------------------------------------------------------------

local glob = "**/*.lua"
local path = vim.fn.expand("%:p")
local pattern = vim.glob.to_lpeg(glob):match(path)

vim.notify("👾 pattern: " .. vim.inspect(pattern))
