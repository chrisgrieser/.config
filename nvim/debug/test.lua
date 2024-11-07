-- local out = require("lspconfig").util.available_servers()

local success, snacks = pcall(require, "snacks")
local snacksFt = success and snacks.config.get("styles", {}).notification.bo.filetype or nil
vim.notify("🖨️ snacksFt: " .. vim.inspect(snacksFt))

