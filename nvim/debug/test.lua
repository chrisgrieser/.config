local client = vim.lsp.get_clients({ bufnr = 0 })[1]
vim.notify("⭕ client: " .. vim.inspect(client))
