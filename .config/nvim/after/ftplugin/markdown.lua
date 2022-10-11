require("utils")
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
keymap({"n", "v"}, "j", "gj", {buffer = true})
keymap({"n", "v"}, "k", "gk", {buffer = true})
keymap({"n", "v"}, "H", "g^", {buffer = true})
keymap({"n", "v"}, "L", "g$", {buffer = true})

