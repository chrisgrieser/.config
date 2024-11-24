local out = vim.iter({ 1, 2, 3, 4 }):take(2):totable()
vim.notify(vim.inspect(out), nil, { title = "oufffffft", ft = "lua", footer = "fff", style = "fancy" })
