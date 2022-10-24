require("utils")
--------------------------------------------------------------------------------

-- hide URLs and other formatting, TODO: figure out how to hide only URLs
-- localOpt("conceallevel", 2)

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

-- cmd+shift+e: export as pdf (cmd+ctrl remapped via karabiner)
keymap("n", "<D-C-e>", ":!pandoc %:p --output=%:t:r.pdf --pdf-engine=wkhtmltopdf<CR>:!open %:t:r.pdf<CR><CR>")

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

keymap("n", "<CR>", 'A') -- So double return keeps markdown list syntax
keymap("n", "<leader>x", 'mz^lllrx`z') -- check markdown tasks
keymap("n", "<leader>-", "mzI- <Esc>`z") -- Add bullet point
keymap("n", "<leader>>", "mzI> <Esc>`z") -- Turn into blockquote

