vim.opt_local.listchars:remove("multispace")

-- KEYMAPS
vim.keymap.set("n", "<CR>", "ZZ", { desc = "Confirm", buffer = true })
vim.keymap.set("n", "q", vim.cmd.cquit, { desc = "Abort", buffer = true, nowait = true })
vim.keymap.set("n", "<Tab>", "<C-a>", { desc = "Cycle Action", buffer = true, remap = true })
vim.keymap.set("n", "<S-Tab>", "<C-x>", { desc = "Cycle Action", buffer = true, remap = true })

-- HIGHLIGHTING
-- apply to whole window, but sinc that window is closed anyway, it's not a problem
local ok, tinygit = pcall(require, "tinygit.shared.utils")
if ok and tinygit then tinygit.commitMsgHighlighting() end

vim.fn.matchadd("NonText", [[^drop .*]])
