local out = vim.iter({ nil, "two" }):join(" ")
vim.notify(--[[🖨️]] vim.inspect(out), nil, { title = "🖨️ out", ft = "lua" })
