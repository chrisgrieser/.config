
local timelogStart = os.clock() -- 🟣

vim.opt.clipboard = "unnamedplus"

local durationSecs = os.clock() - timelogStart -- 🟣
vim.notify(("🟣: %.3fs"):format(durationSecs))
