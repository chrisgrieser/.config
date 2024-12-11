return {
	"nvim-telescope/telescope-symbols.nvim",
	dependencies = "nvim-telescope/telescope.nvim",
	keys = {
		{
			"<C-.>",
			mode = "i",
			function()
				require("telescope.builtin").symbols {
					sources = { "nerd", "math", "emoji" },
					layout_config = { horizontal = { width = 0.35 } },
				}
			end,
			desc = "󱗿 Icon Picker",
		},
	},
}
