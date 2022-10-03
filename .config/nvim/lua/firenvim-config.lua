require("utils")
--------------------------------------------------------------------------------
cmd[[
let g:firenvim_config = {
	\ 'localSettings': {
		\ '.*': {
			\ 'takeover': 'always',
			\ },
		\ }
	\ }
]]


--------------------------------------------------------------------------------


-- start in insert mode
autocmd("BufNewFile", {
	pattern = "*",
	command = "start"
})

-- autosaving the text field
autocmd({"TextChangedI", "TextChanged"}, {
	pattern = "*",
	command = "silent! update"
})

keymap("", "<D-s>", ":write!<CR>") -- manual saving

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

-- Appearance
cmd[[colorscheme tokyonight]]
opt.laststatus = 0
opt.textwidth = 0

-- relevant for spellcheck suggestions
require("telescope").setup {
	defaults = {
		mappings = {
			i = { ["<Esc>"] = require('telescope.actions').close }, -- close w/ one esc
		},
	}
}

