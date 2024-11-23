local str = nil
local a = str and str .. "x" or nil
vim.notify(--[[🖨️]] vim.inspect(a), nil, { title = "🖨️ a", ft = "lua" })
