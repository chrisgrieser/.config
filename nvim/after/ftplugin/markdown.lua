require("config.utils")
--------------------------------------------------------------------------------

-- enable wrapping lines
-- HACK for whatever reason, needs to be wrapped in a condition
if not opt_local.wrap:get() then require("funcs.quality-of-life").toggleWrap() end

-- decrease line length without zen mode plugins
opt_local.signcolumn = "yes:9"

opt_local.formatoptions:remove("t")

--------------------------------------------------------------------------------

-- Build / Preview
keymap("n", "<leader>r", "<Plug>MarkdownPreviewToggle", { desc = "  Preview", buffer = true })

-- stylua: ignore start
-- link textobj
keymap({ "o", "x" }, "il", function() require("various-textobjs").mdlink(true) end, { desc = "inner md link textobj", buffer = true })
keymap({ "o", "x" }, "al", function() require("various-textobjs").mdlink(false) end, { desc = "outer md link textobj", buffer = true })

-- iE/aE: code block textobj
keymap({ "o", "x" }, "iE", function() require("various-textobjs").mdFencedCodeBlock(true) end, { desc = "inner md code block textobj", buffer = true })
keymap({ "o", "x" }, "aE", function() require("various-textobjs").mdFencedCodeBlock(false) end, { desc = "outer md code block textobj", buffer = true })

-- Format Table
keymap("x", "<D-p>", ":!pandoc -t commonmark_x<CR><CR>", { desc = "  Format Table", buffer = true })
-- stylua: ignore end

-- Heading jump to next/prev heading
keymap({ "n", "x" }, "<C-j>", [[/^#\+ <CR>:nohl<CR>]], { desc = " # Next Heading", buffer = true })
keymap({ "n", "x" }, "<C-k>", [[?^#\+ <CR>:nohl<CR>]], { desc = " # Previous Heading", buffer = true })

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
