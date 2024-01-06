--------------------------------------------------------
-- nvim-scissors demo
--------------------------------------------------------

vim.keymap.set("n", "lhs", "rhs")

vim.keymap.set("n", "lhs", "rhs", { desc = "description" })


local a = "foobar"
local c = "hello"
local b = (("%s bla %%s bla %s"):format(a, c))
vim.notify("🪚 b: " .. tostring(b))


