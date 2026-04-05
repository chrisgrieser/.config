vim.pack.add { "https://github.com/nvim-mini/mini.operators" }
--------------------------------------------------------------------------------

require("config.utils").pluginKeymaps {
	{ "S", "s$", desc = "󰅪 Substitute to EoL", remap = true },
	{ "W", "w$", desc = "󰅪 Multiply to EoL", remap = true },
}

--------------------------------------------------------------------------------

require("mini.operators").setup {
	evaluate = { prefix = "" }, -- disable
	replace = { prefix = "s" },
	exchange = { prefix = "sx" },
	sort = { prefix = "sy" },
	multiply = { prefix = "w" },
}
