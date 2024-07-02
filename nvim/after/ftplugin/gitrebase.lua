vim.opt_local.listchars:remove("multispace")
local keymap = require("config.utils").bufKeymap

-- KEYMAPS
keymap("n", "<CR>", "ZZ", { desc = "Confirm" })
keymap("n", "q", vim.cmd.cquit, { desc = "Abort" })
keymap("n", "<Tab>", vim.cmd.Cycle, { desc = "Cycle Action" }) -- `:Cycle` is vim ftplugin

-- leave out auto-formatting via `==`, since buggy
keymap("n", "<Down>", [[<cmd>. move +1<CR>]], { desc = "󰜮 Move line down" })
keymap("n", "<Up>", [[<cmd>. move -2<CR>]], { desc = "󰜷 Move line up" })
keymap("x", "<Down>", [[:move '>+1<CR>gv]], { desc = "󰜮 Move selection down" })
keymap("x", "<Up>", [[:move '<-2<CR>gv]], { desc = "󰜷 Move selection up" })

-- HIGHLIGHTING
-- apply to whole window, but sinc that window is closed anyway, it's not a problem
local ok, tinygit = pcall(require, "tinygit.shared.utils")
if ok and tinygit then tinygit.commitMsgHighlighting() end

vim.fn.matchadd("NonText", [[^drop .*]])
