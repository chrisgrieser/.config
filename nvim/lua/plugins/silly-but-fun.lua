return {
	{ -- just a duck
		"tamton-aquib/duck.nvim",
		keys = {
			{ "<leader>ö", function() require("duck").hatch("🦆", 5) end, desc = "󰇥 Hatch Duck" },
			{ "<leader>Ö", function() require("duck").cook("💀") end, desc = "󰇥 Cook Duck" },
		},
	},
	{ -- simple screensaver (zone.nvim is nicer, but unfortunately buggy)
		"folke/drop.nvim",
		event = "VeryLazy",
		opts = {
			theme = "summer", -- stars|summer|spring|xmas|snow|leaves
			max = 100, -- maximum number of drops on the screen
			interval = 100, -- updates in ms
			screensaver = (1000 * 60) * 5, -- starting time in 5 minutes
		},
	},
}
