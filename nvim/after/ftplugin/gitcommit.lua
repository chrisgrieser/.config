-- confirm commit with `<CR>`
vim.keymap.set("n", "<CR>", "<cmd>wq<CR>", { desc = "󰊢 Confirm commit" })

-- off, since using vale & ltex here
vim.opt_local.spell = false
