require("utils")
local opts = {buffer = true, silent = true}
--------------------------------------------------------------------------------

-- hide URLs and other formatting, TODO: figure out how to hide only URLs
-- localOpt("conceallevel", 2)

-- hack to make lists auto-continue via Return in Insert & o in normal mode
-- i.e. replaces bullet.vim based on https://www.reddit.com/r/vim/comments/otpr29/comment/h6yldkj/
setlocal("comments", "b:*,b:-,b:+")
local fo = getlocalopt("formatoptions"):gsub("c", "") .. "ro" ---@diagnostic disable-line: undefined-field
setlocal("formatoptions", fo)

-- spelling
setlocal("spell", true)

-- syntax highlighting in code blocks
g.markdown_fenced_languages = {
	"css",
	"python",
	"py=python",
	"yaml",
	"json",
	"lua",
	"javascript",
	"js=javascript",
	"bash",
	"sh=bash",
}

-- wrapping and related options
setlocal("wrap", true) -- soft wrap
setlocal("linebreak", true) -- do not break words for soft wrap
setlocal("colorcolumn", "") -- deactivate ruler
keymap({"n", "x"}, "H", "g^", opts)
keymap({"n", "x"}, "L", "g$", opts)
keymap({"n", "x"}, "J", function() require("quality-of-life").overscroll("7gj") end, opts)
keymap({"n", "x"}, "K", "7gk", opts)
keymap({"n", "x"}, "k", "gk", opts)
keymap({"n", "x"}, "j", function() require("quality-of-life").overscroll("gj") end, opts)

-- automatically open float, since virtual text is hard to read with wrapping
keymap("n", "ge", function() vim.diagnostic.goto_next {wrap = true, float = true} end, opts)
keymap("n", "gE", function() vim.diagnostic.goto_prev {wrap = true, float = true} end, opts)
--------------------------------------------------------------------------------

-- Heading instead of function navigation
keymap({"n", "x"}, "<C-j>", [[/^#\+ <CR>:nohl<CR>]], opts)
keymap({"n", "x"}, "<C-k>", [[?^#\+ <CR>:nohl<CR>]], opts)

--------------------------------------------------------------------------------

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

-- cmd+e for inline code done in gui-settings, since also used for other cases
-- outside of markdown (e.g. template strings)

-- Misc
keymap("n", "<leader>x", "mz^lllrx`z", opts) -- check markdown tasks
keymap("n", "<leader>-", "mzI- <Esc>`z", opts) -- Add bullet point
keymap("n", "<leader>>", "mzI> <Esc>`z", opts) -- Turn into blockquote
