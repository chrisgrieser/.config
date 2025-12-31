-- DOCS https://github.com/nvim-mini/mini.operators/blob/main/doc/mini-operators.txt
--------------------------------------------------------------------------------

return {
	"nvim-mini/mini.operators",
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
		replace = { prefix = "s" },
		exchange = { prefix = "sx" },
		sort = { prefix = "sy" },
		multiply = { prefix = "" }, -- disable -> set our own in `make_mappings`
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
