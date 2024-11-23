local out = "tst"
local timelogStart1 = os.clock() -- 🖨️
vim.notify(("#1 🖨️: %%.3fs"):format(os.clock() - timelogStart1))
vim.notify("🖨️ 🔵")
