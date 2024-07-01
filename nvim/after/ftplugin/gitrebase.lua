vim.opt_local.listchars:remove("multispace")

local function bufKeymap(mode, key, cmd, opts)
	opts = vim.tbl_extend("force", { buffer = true, silent = true, nowait = true }, opts or {})
	vim.keymap.set(mode, key, cmd, opts)
end

-- KEYMAPS
bufKeymap("n", "<CR>", "ZZ", { desc = "Confirm" })
bufKeymap("n", "q", vim.cmd.cquit, { desc = "Abort" })
bufKeymap("n", "<Tab>", "<C-a>", { desc = "Cycle Action" })

-- leave out auto-formatting via `==`, since buggy
bufKeymap("n", "<Down>", [[<cmd>. move +1<CR>]], { desc = "󰜮 Move line down" })
bufKeymap("n", "<Up>", [[<cmd>. move -2<CR>]], { desc = "󰜷 Move line up" })
bufKeymap("x", "<Down>", [[:move '>+1<CR>gv]], { desc = "󰜮 Move selection down" })
bufKeymap("x", "<Up>", [[:move '<-2<CR>gv]], { desc = "󰜷 Move selection up" })

-- HIGHLIGHTING
-- apply to whole window, but sinc that window is closed anyway, it's not a problem
local ok, tinygit = pcall(require, "tinygit.shared.utils")
if ok and tinygit then tinygit.commitMsgHighlighting() end

vim.fn.matchadd("NonText", [[^drop .*]])
