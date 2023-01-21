require("config.utils")
--------------------------------------------------------------------------------

-- spellcheck
opt_local.spell = true

-- HACK to make lists auto-continue via Return in Insert & o in normal mode
-- i.e. replaces bullet.vim based on https://www.reddit.com/r/vim/comments/otpr29/comment/h6yldkj/
bo.comments = "b:-"
bo.formatoptions = bo.formatoptions:gsub("[ct]", "") .. "ro"

-- enable wrapping lines
-- HACK for whatever reason, needs to be wrapped in a condition, otherwise it
-- worn't trigger?!
if not opt_local.wrap:get() then require("funcs.quality-of-life").toggleWrap() end

-- decrease line length without zen mode plugins 
opt_local.signcolumn = "yes:9"

-- make gf for filepaths available in markdown again
keymap("n", "gP", "gf", {desc = "goto path (gf)", buffer = true})

--------------------------------------------------------------------------------
-- link textobj
keymap(
	{ "o", "x" },
	"il",
	function() require("various-textobjs").mdlink(true) end,
	{ desc = "inner md link textobj", buffer = true }
)
keymap(
	{ "o", "x" },
	"al",
	function() require("various-textobjs").mdlink(false) end,
	{ desc = "outer md link textobj", buffer = true }
)

-- iE/aE: code block textobj
keymap(
	{ "o", "x" },
	"iE",
	function() require("various-textobjs").mdFencedCodeBlock(true) end,
	{ desc = "inner md code block textobj", buffer = true }
)
keymap(
	{ "o", "x" },
	"aE",
	function() require("various-textobjs").mdFencedCodeBlock(false) end,
	{ desc = "outer md code block textobj", buffer = true }
)

--------------------------------------------------------------------------------

local opts = { buffer = true, silent = true }
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
