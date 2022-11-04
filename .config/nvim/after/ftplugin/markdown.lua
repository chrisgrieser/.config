require("utils")
local opts = {buffer = true, silent = true}
--------------------------------------------------------------------------------

-- hide URLs and other formatting, TODO: figure out how to hide only URLs
-- localOpt("conceallevel", 2)


-- hack to make lists auto-continue via Return in Insert & o in normal mode
-- i.e. replaces bullet.vim based on https://www.reddit.com/r/vim/comments/otpr29/comment/h6yldkj/
cmd [[
	setlocal comments="b:*,b:-,b:+"
	setlocal formatoptions+=ro
]]


-- spelling
setlocal("spell", true)

-- syntax highlighting in code blocks
g.markdown_fenced_languages = {
	"python",
	"py=python",
	"css",
	"yaml",
	"json",
	"toml",
	"lua",
	"javascript",
	"js=javascript",
	"typescript",
	"ts=typescript",
	"applescript",
	"bash",
	"sh=bash",
	"zsh",
}

-- wrapping and related options
setlocal("wrap", true) -- soft wrap
setlocal("linebreak", true) -- do not break words for soft wrap
setlocal("colorcolumn", "") -- deactivate ruler
keymap({"n", "v"}, "H", "g^", opts)
keymap({"n", "v"}, "L", "g$", opts)
keymap({"n", "v"}, "J", "7gj", opts)
keymap({"n", "v"}, "K", "7gk", opts)
keymap({"n", "v"}, "k", "gk", opts)
keymap({"n", "v"}, "j", function() require("quality-of-life").overscroll("gj") end, opts)

--------------------------------------------------------------------------------

-- cmd+k: markdown link
keymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", opts)
keymap("v", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", opts)
keymap("i", "<D-k>", "[]()<Left><Left><Left>", opts)

-- cmd+b: bold
keymap("n", "<D-b>", "bi__<Esc>ea__<Esc>", opts)
keymap("v", "<D-b>", "<Esc>`<i__<Esc>`>lla__<Esc>", opts)
keymap("i", "<D-b>", "____<Left><Left>", opts)

-- cmd+i: italics
keymap("n", "<D-i>", "bi*<Esc>ea*<Esc>", opts)
keymap("v", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", opts)
keymap("i", "<D-i>", "**<Left>", opts)

-- cmd+e for inline code done in gui-settings, since also used for other cases
-- outside of markdown (e.g. templater strings)

keymap("n", "<CR>", "A", opts) -- So double return keeps markdown list syntax
keymap("n", "<leader>x", "mz^lllrx`z", opts) -- check markdown tasks
keymap("n", "<leader>-", "mzI- <Esc>`z", opts) -- Add bullet point
keymap("n", "<leader>>", "mzI> <Esc>`z", opts) -- Turn into blockquote
