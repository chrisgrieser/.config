local spec = {
	{
		"chrisgrieser/nvim-rip-substitute",
		opts = {},
		keys = {
			{
				"<leader>fs",
				function() require("rip-substitute").sub() end,
				vvvv = { "n", "x" },
				desc = " rip substitute",
			},
		},
	},
}

