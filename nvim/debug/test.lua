
require("dressing").setup { input = { trim_prompt = true } }
vim.ui.input({ prompt = "Input: " }, function () end)

require("dressing").setup { input = { trim_prompt = false } }
vim.ui.input({ prompt = "Input: " }, function () end)
