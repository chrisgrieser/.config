local servers = require("lspconfig").util.available_servers()
vim.notify("🖨️ servers: " .. vim.inspect(#servers))
