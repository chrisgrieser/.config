-- vim.fn.matchadd("WarningMsg", [[\w\+\.lua:\d\+\ze:]]) -- \ze: lookahead
-- vim.fn.matchadd("WarningMsg", [[\w\+\.lua:\d\+\ze:]]) -- \ze: lookahead

-- .../nvim-data/lazy/nvim-chainsaw/lua/chainsaw/init.lua:31: attempt to call field 'normal' (a nil value)

vim.notify(".../nvim-chainsaw/lua/chainsaw/init.lua:31: attempt to call field 'normal' (a nil value)")

vim.notify("aaa")
