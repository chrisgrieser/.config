local client = vim.lsp.get_clients({ bufnr = 0 })[1]
vim.notify("⭕ client: " .. vim.inspect(client))
local progress = client.messages.progress
vim.notify("⭕ progress: " .. vim.inspect(progress))
