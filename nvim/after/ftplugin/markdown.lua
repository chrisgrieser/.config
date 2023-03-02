require("config.utils")
--------------------------------------------------------------------------------

-- spellcheck
opt_local.spell = true

-- enable wrapping lines
-- HACK for whatever reason, needs to be wrapped in a condition
if not opt_local.wrap:get() then require("funcs.quality-of-life").toggleWrap() end

-- decrease line length without zen mode plugins
opt_local.signcolumn = "yes:9"

--------------------------------------------------------------------------------
-- stylua: ignore start
-- link textobj
keymap({ "o", "x" }, "il", function() require("various-textobjs").mdlink(true) end, { desc = "inner md link textobj", buffer = true })
keymap({ "o", "x" }, "al", function() require("various-textobjs").mdlink(false) end, { desc = "outer md link textobj", buffer = true })

-- iE/aE: code block textobj
keymap({ "o", "x" }, "iE", function() require("various-textobjs").mdFencedCodeBlock(true) end, { desc = "inner md code block textobj", buffer = true })
keymap({ "o", "x" }, "aE", function() require("various-textobjs").mdFencedCodeBlock(false) end, { desc = "outer md code block textobj", buffer = true })
-- stylua: ignore end

keymap("x", "<D-s>", ":!pandoc -t commonmark_x<CR><CR>", { desc = "format md table", buffer = true })
--------------------------------------------------------------------------------

-- Heading jump to next/prev heading
keymap({ "n", "x" }, "<C-j>", [[/^#\+ <CR>:nohl<CR>]], { desc = "next heading", buffer = true })
keymap({ "n", "x" }, "<C-k>", [[?^#\+ <CR>:nohl<CR>]], { desc = "previous heading", buffer = true })

--KEYBINDINGS WITH THE GUI
if IsGui() then
	local opts = { buffer = true }
	-- cmd+r: Markdown Preview
	keymap("n", "<D-r>", "<Plug>MarkdownPreviewToggle", opts)

	-- cmd+k: markdown link
	keymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", opts)
	keymap("x", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", opts)
	keymap("i", "<D-k>", "[]()<Left><Left><Left>", opts)

	-- cmd+b: bold
	keymap("n", "<D-b>", "bi__<Esc>ea__<Esc>", opts)
	keymap("x", "<D-b>", "<Esc>`<i__<Esc>`>lla__<Esc>", opts)
	keymap("i", "<D-b>", "____<Left><Left>", opts)

	-- cmd+i: italics
	keymap("n", "<D-i>", "bi*<Esc>ea*<Esc>", opts)
	keymap("x", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", opts)
	keymap("i", "<D-i>", "**<Left>", opts)
end
