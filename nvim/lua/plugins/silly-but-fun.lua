return {
	{ -- simple screensaver, zone.nvim is nicer but often buggy
		"folke/drop.nvim",
		enabled = true,
		event = "VeryLazy",
		opts = {
			theme = "summer", -- stars|summer|spring|xmas|snow|leaves
			max = 50, -- maximum number of drops on the screen
			screensaver = (1000 * 60) * 10, -- start after 10 minutes
		},
	},
	{ -- just a duck
		"tamton-aquib/duck.nvim",
		keys = {
			{ "<leader>zd", function() require("duck").hatch("🦆", 5) end, desc = "󰇥 Hatch Duck" },
			{ "<leader>zc", function() require("duck").cook("💀") end, desc = "󰇥 Cook Duck" },
		},
		init = function()
			require("which-key").register {
				mode = { "n" },
				["<leader>z"] = { name = " 󰯉 Zilly Fun Stuff" },
			}
		end,
	},
}
