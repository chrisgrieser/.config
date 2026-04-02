-- config used for the `pass` cli
vim.keymap.set("n", "L", "$")
vim.keymap.set("n", "H", "0^")

vim.keymap.set("n", "ss", "VP", { desc = "Substitute line" })
vim.keymap.set("n", "S", "v$hP", { desc = "Substitute to EoL" })

vim.keymap.set("n", "<CR>", "ZZ", { desc = "Save and exit" })

vim.keymap.set("n", "<Space>", "ciw")
