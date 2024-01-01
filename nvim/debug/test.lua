--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local record = vim.notify("test", vim.log.levels.INFO, { timeout = false })
vim.notify("🪚 record: " .. vim.inspect(record))

require("notify").dismiss({ silent = true })
