local a, b = pcall(vim.treesitter.query.parse, "lua", [[((return_statement) @keyword.return)]])
vim.notify(vim.inspect(a), nil, { title = "🪚 a", ft = "lua" })
vim.notify(vim.inspect(b), nil, { title = "🪚 b", ft = "lua" })
