-- hide URLs and other formatting
-- TODO: figure out how to *only* conceal markdown links
-- https://www.reddit.com/r/vim/comments/h8pgor/til_conceal_in_vim/
opt.conceallevel = 1

-- spelling
opt.spell = true
opt.spelllang = "en_us"

-- wrapping and related options
opt.wrap = true -- soft wrap
opt.linebreak = true -- do not break words for soft wrap
keymap({"n", "v"}, "j", "gj")
keymap({"n", "v"}, "k", "gk")
keymap({"n", "v"}, "H", "g^")
keymap({"n", "v"}, "L", "g$")
opt.colorcolumn = ''

