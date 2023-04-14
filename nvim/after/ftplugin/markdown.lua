local cmd = vim.cmd
local keymap = vim.keymap.set
--------------------------------------------------------------------------------

-- Rnable wrapping lines
-- HACK needs to be wrapped in a condition, probably due to some recursion thing
if not vim.opt_local.wrap:get() then cmd.normal(",ow") end

-- decrease line length without zen mode plugins
vim.opt_local.signcolumn = "yes:9"

-- do not auto-wrap text
vim.opt_local.formatoptions:remove("t")

--------------------------------------------------------------------------------

-- Build / Preview
keymap("n", "<D-r>", "<Plug>MarkdownPreview", { desc = "  Preview", buffer = true })
keymap("n", "<leader>r", "<Plug>MarkdownPreview", { desc = "  Preview", buffer = true })

-- stylua: ignore start
-- link textobj
keymap({ "o", "x" }, "il", "<cmd>lua require('various-textobjs').mdlink(true)<CR>", { desc = "inner md link textobj", buffer = true })
keymap({ "o", "x" }, "al", "<cmd>lua require('various-textobjs').mdlink(false)<CR>", { desc = "outer md link textobj", buffer = true })

-- iE/aE: code block textobj
keymap({ "o", "x" }, "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(true)<CR>", { desc = "inner md code block textobj", buffer = true })
keymap({ "o", "x" }, "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock(false)<CR>", { desc = "outer md code block textobj", buffer = true })

-- Format Table
keymap("n", "<localleader>p", "vip:!pandoc -t commonmark_x<CR><CR>", { desc = "  Format Table", buffer = true })
keymap("x", "<localleader>p", ":!pandoc -t commonmark_x<CR><CR>", { desc = "  Format Table", buffer = true })
-- stylua: ignore end

-- Heading jump to next/prev heading
keymap({ "n", "x" }, "<C-j>", [[/^#\+ <CR>:nohl<CR>]], { desc = " # Next Heading", buffer = true })
keymap(
	{ "n", "x" },
	"<C-k>",
	[[?^#\+ <CR>:nohl<CR>]],
	{ desc = " # Previous Heading", buffer = true }
)

--------------------------------------------------------------------------------
-- GUI KEYBINDINGS

-- cmd+k: markdown link
keymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", { desc = "  Link", buffer = true })
keymap("x", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", { desc = "  Link", buffer = true })
keymap("i", "<D-k>", "[]()<Left><Left><Left>", { desc = "  Link", buffer = true })

-- cmd+b: bold
keymap("n", "<D-b>", "bi__<Esc>ea__<Esc>", { desc = "  Bold", buffer = true })
keymap("x", "<D-b>", "<Esc>`<i__<Esc>`>lla__<Esc>", { desc = "  Bold", buffer = true })
keymap("i", "<D-b>", "____<Left><Left>", { desc = "  Bold", buffer = true })

-- cmd+i: italics
keymap("n", "<D-i>", "bi*<Esc>ea*<Esc>", { desc = "  Italics", buffer = true })
keymap("x", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", { desc = "  Italics", buffer = true })
keymap("i", "<D-i>", "**<Left>", { desc = "  Italics", buffer = true })
