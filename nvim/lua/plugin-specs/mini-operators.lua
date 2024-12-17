return {
	"echasnovski/mini.operators",
	keys = {
		{ "s", desc = "󰅪 Substitute Operator" }, -- in visual mode, `s` surrounds
		{ "w", mode = { "n", "x" }, desc = "󰅪 Multiply Operator" },
		{ "sy", desc = "󰅪 Sort Operator" },
		{ "sx", desc = "󰅪 Exchange Operator" },
		{ "S", "s$", desc = "󰅪 Substitute to EoL", remap = true },
		{ "W", "w$", desc = "󰅪 Multiply to EoL", remap = true },
	},
	opts = {
		evaluate = { prefix = "" }, -- disable
		replace = { prefix = "s", reindent_linewise = true },
		exchange = { prefix = "sx", reindent_linewise = true },
		sort = { prefix = "sy" },
		multiply = {
			prefix = "", -- set our own in `make_mappings`
		},
	},
	config = function(_, opts)
		require("mini.operators").setup(opts)

		-- Do not set `multiply` mapping for line, since we use our own, as
		-- multiply's transformation function only supports pre-duplication
		-- changes, which prevents us from doing post-duplication cursor
		-- movements.
		require("mini.operators").make_mappings(
			"multiply",
			{ textobject = "w", selection = "w", line = "" }
		)
	end,
}
