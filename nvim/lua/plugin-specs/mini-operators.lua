vim.pack.add { "https://github.com/nvim-mini/mini.operators" }
--------------------------------------------------------------------------------

Keymap { "S", "s$", desc = "󰅪 Substitute to EoL", remap = true }
Keymap { "W", "w$", desc = "󰅪 Multiply to EoL", remap = true }

--------------------------------------------------------------------------------

require("mini.operators").setup {
	evaluate = { prefix = "" }, -- disable
	replace = { prefix = "s" },
	exchange = { prefix = "sx" },
	sort = { prefix = "sy" },
	multiply = { prefix = "w" },
}
