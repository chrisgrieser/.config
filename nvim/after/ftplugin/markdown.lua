require("config/utils")
local opts = { buffer = true, silent = true }
--------------------------------------------------------------------------------

-- hide URLs and other formatting, TODO figure out how to hide only URLs
-- setlocal("conceallevel", 2)

-- spellcheck
setlocal("spell", true)

-- hack to make lists auto-continue via Return in Insert & o in normal mode
-- i.e. replaces bullet.vim based on https://www.reddit.com/r/vim/comments/otpr29/comment/h6yldkj/
setlocal("comments", "b:-")
local foOpts = getlocalopt("formatoptions"):gsub("[ct]", "") .. "ro"
setlocal("formatoptions", foOpts)

--------------------------------------------------------------------------------
-- link textobj
keymap({ "o", "x" }, "il", function() varTextObj.mdlink(true) end, { desc = "inner md link textobj" })
keymap({ "o", "x" }, "al", function() varTextObj.mdlink(false) end, { desc = "outer md link textobj" })

-- code block textobj
keymap({ "o", "x" }, "iC", function() varTextObj.mdFencedCodeBlock(true) end, { desc = "inner md code block textobj" })
keymap({ "o", "x" }, "aC", function() varTextObj.mdFencedCodeBlock(false) end, { desc = "outer md code block textobj" })

--------------------------------------------------------------------------------

-- decrease line length without zen mode plugins (which unfortunately remove
-- statuslines and stuff)
setlocal("signcolumn", "yes:9")

--------------------------------------------------------------------------------

-- Heading instead of function navigation
keymap({ "n", "x" }, "<C-j>", [[/^#\+ <CR>:nohl<CR>]], opts)
keymap({ "n", "x" }, "<C-k>", [[?^#\+ <CR>:nohl<CR>]], opts)

--KEYBINDINGS WITH THE GUI
if isGui() then
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

	-- cmd+4: bullet points
	keymap("n", "<D-4>", "mzI- <Esc>`z", opts)
	keymap("x", "<D-4>", ":s/^/- /<CR>", opts)
end
