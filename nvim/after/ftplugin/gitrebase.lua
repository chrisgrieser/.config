vim.opt_local.listchars:remove("multispace")
--------------------------------------------------------------------------------

-- KEYMAPS
Bufmap { "<CR>", "ZZ", desc = " Confirm" } -- quit with saving = confirm
Bufmap { "q", vim.cmd.cquit, desc = " Abort" } -- quit with error = aborting

-- `:Cycle` is vim ftplugin
Bufmap { "<Tab>", vim.cmd.Cycle, desc = " Next conv. commit type" }
Bufmap { "<S-Tab>", "<cmd>Cycle!<CR>", desc = " Prev conv. commit type" }

-- FIX leave out auto-formatting via `==`, since buggy
Bufmap { "<Down>", [[<cmd>. move +1<CR>]], desc = "󰜮 Move line down" }
Bufmap { "<Up>", [[<cmd>. move -2<CR>]], desc = "󰜷 Move line up" }
Bufmap { "<Down>", [[:move '>+1<CR>gv]], mode = "x", desc = "󰜮 Move selection down" }
Bufmap { "<Up>", [[:move '<-2<CR>gv]], mode = "x", desc = "󰜷 Move selection up" }
--------------------------------------------------------------------------------

-- HIGHLIGHTS
-- applies to whole window, but since that window is closed anyway, it's not a problem
vim.fn.matchadd("Number", [[#\d\+]]) -- issue numbers
vim.fn.matchadd("@markup.raw.markdown_inline", [[`.\{-}`]]) -- inline code, `.\{-}` = non-greedy quantifier
vim.fn.matchadd("NonText", [[\v^d(rop)? .*]]) -- `drop` action (or short form `d`)
