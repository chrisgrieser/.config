local gitsigns = vim.b.gitsigns_status
local u = require("config.utils")
u.notify("", "👾 gitsigns: " .. vim.inspect(gitsigns), "warn")
