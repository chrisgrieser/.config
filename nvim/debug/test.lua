--------------------------------------------------------
-- nvim-scissors demo
--------------------------------------------------------

vim.keymap.set("n", "lhs", "rhs")

vim.keymap.set("n", "lhs", "rhs", { desc = "description" })


local a = "1 + 2222" .. "1111 + 2"
local b = (1 + 2222) .. (1111 + 2)
