-- alternative: `:h :redir`
local out = vim.fn.execute("messages")
vim.notify(--[[🖨️]] vim.inspect(out), nil, { ft = "lua", title = "out" })
