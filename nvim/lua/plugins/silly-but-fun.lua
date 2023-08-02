return {
	{ -- simple screensaver
		"folke/drop.nvim",
		enabled = false,
		event = "VeryLazy",
		opts = {
			theme = "summer", -- stars|summer|spring|xmas|snow|leaves
			max = 75, -- maximum number of drops on the screen
			interval = 150, -- updates in ms
			screensaver = (1000 * 60) * 10, -- starting time in 5 minutes
		},
	},
	{ -- nicer screensaver, but a bit buggy
		"tamton-aquib/zone.nvim",
		event = "VeryLazy",
		opts = {
			style = "epilepsy", -- vanish|epilepsy|treadmill|dvd|matrix
			after = 60, -- seconds?
		},
	},
	{ -- just a duck
		"tamton-aquib/duck.nvim",
		keys = {
			{ "<leader>zd", function() require("duck").hatch("🦆", 5) end, desc = "󰇥 Hatch Duck" },
			{ "<leader>zc", function() require("duck").cook("💀") end, desc = "󰇥 Cook Duck" },
		},
		config = function()
			require("which-key").register { mode = { "n" }, ["<leader>z"] = { name = "󰯉 Zilly Fun Stuff" } }
		end
	},
}
