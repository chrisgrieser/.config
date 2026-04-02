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
	multiply = { prefix = "" }, -- disable -> set our own in `make_mappings`
}

-- Do not set `multiply` mapping for line, since we use our own, as
-- multiply's transformation function only supports pre-duplication
-- changes, which prevents us from doing post-duplication cursor
-- movements.
require("mini.operators").make_mappings(
	"multiply",
	{ textobject = "w", selection = "w", line = "" }
)
