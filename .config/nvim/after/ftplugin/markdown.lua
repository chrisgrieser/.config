require("utils")
require("keybindings")
--------------------------------------------------------------------------------

-- hide URLs and other formatting
-- TODO: figure out how to *only* conceal markdown links
-- https://www.reddit.com/r/vim/comments/h8pgor/til_conceal_in_vim/
localOpt("conceallevel", 1)

-- spelling
localOpt("spell", true)

-- wrapping and related options
localOpt("wrap", true) -- soft wrap
localOpt("linebreak", true) -- do not break words for soft wrap
localOpt("colorcolumn", "") -- deactivate ruler
keymap({"n", "v"}, "H", "g^", {buffer = true})
keymap({"n", "v"}, "L", "g$", {buffer = true})
keymap({"n", "v"}, "k", "gk", {buffer = true})
keymap({"n", "v"}, "j", function() overscroll("gj") end, {buffer = true})

-- keybindings
local opts = {buffer = true}

-- cmd+k: markdown link
keymap("n", "<D-k>", "bi[<Esc>ea]()<Esc>hp", opts)
keymap("v", "<D-k>", "<Esc>`<i[<Esc>`>la]()<Esc>hp", opts)
keymap("i", "<D-k>", "[]()<Left><Left><Left>", opts)

-- cmd+b: bold
keymap("n", "<D-b>", "bi__<Esc>ea__<Esc>", opts)
keymap("v", "<D-b>", "<Esc>`<i__<Esc>`>lla__<Esc>", opts)

-- cmd+i: italics
keymap("n", "<D-i>", "bi*<Esc>ea*<Esc>", opts)
keymap("v", "<D-i>", "<Esc>`<i*<Esc>`>la*<Esc>", opts)

-- cmd+e: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", opts)
keymap("v", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", opts)
