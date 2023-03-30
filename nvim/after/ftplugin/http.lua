require("config.utils")
--------------------------------------------------------------------------------

Keymap("n", "<leader>r", "<Plug>RestNvim", { desc = "Run Request under cursor", buffer = true })
Keymap("n", "<D-r>", "<Plug>RestNvimPreview", { desc = "Preview request curl", buffer = true })
Keymap("n", "<leader>la", "<Plug>RestNvimLast", { desc = "re-run the last request", buffer = true })

-- INFO https://github.com/rest-nvim/rest.nvim
-- see test files here https://github.com/rest-nvim/rest.nvim/tree/main/tests
