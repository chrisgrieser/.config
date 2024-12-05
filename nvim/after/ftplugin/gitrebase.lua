vim.opt_local.listchars:remove("multispace")
--------------------------------------------------------------------------------

-- KEYMAPS
local bkeymap = require("config.utils").bufKeymap
bkeymap("n", "<CR>", "ZZ", { desc = " Confirm" })
bkeymap("n", "q", vim.cmd.cquit, { desc = " Abort" })

-- `:Cycle` is vim ftplugin
bkeymap("n", "<Tab>", vim.cmd.Cycle, { desc = " Next conv. commit type" })
bkeymap("n", "<S-Tab>", "<cmd>Cycle!<CR>", { desc = " Prev conv. commit type" })

-- FIX leave out auto-formatting via `==`, since buggy
bkeymap("n", "<Down>", [[<cmd>. move +1<CR>]], { desc = "󰜮 Move line down" })
bkeymap("n", "<Up>", [[<cmd>. move -2<CR>]], { desc = "󰜷 Move line up" })
bkeymap("x", "<Down>", [[:move '>+1<CR>gv]], { desc = "󰜮 Move selection down" })
bkeymap("x", "<Up>", [[:move '<-2<CR>gv]], { desc = "󰜷 Move selection up" })
--------------------------------------------------------------------------------

-- HIGHLIGHTING
-- applies to whole window, but sinc that window is closed anyway, it's not a problem
local ok, tinygit = pcall(require, "tinygit.shared.highlights")
if ok and tinygit then tinygit.commitMsg() end

vim.fn.matchadd("NonText", [[^drop .*]])
