--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local lastLine = "R100	nvim/lua/plugins/linter-formatter.lua	nvim/lua/plugins/formatter-tooling-installation.lua"
-- local lastLine = "M       nvim/lua/plugins/linter-formatter.lua"

local filenameAtCommit = lastLine:match("^M%s+(.+)") or lastLine:match("^R%d+%s+(.+)  ")

vim.notify("🪚 " .. tostring(filenameAtCommit))
