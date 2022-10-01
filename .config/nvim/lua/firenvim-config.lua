require("utils")

opt.laststatus = 0
cmd[[colorscheme tokyonight]]

-- relevant for spellcheck suggestions
require("telescope").setup {
	defaults = {
		mappings = {
			i = { ["<Esc>"] = require('telescope.actions').close, -- close w/ one esc }, }
		},
	}
}

