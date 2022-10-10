-- hide URLs and other formatting
-- TODO: figure out how to *only* conceal markdown links
-- https://www.reddit.com/r/vim/comments/h8pgor/til_conceal_in_vim/
wo.conceallevel = 1

-- spelling
wo.spell = true

-- wrapping and related options
wo.wrap = true -- soft wrap
wo.linebreak = true -- do not break words for soft wrap
keymap({"n", "v"}, "j", "gj")
keymap({"n", "v"}, "k", "gk")
keymap({"n", "v"}, "H", "g^")
keymap({"n", "v"}, "L", "g$")
wo.colorcolumn = ''

