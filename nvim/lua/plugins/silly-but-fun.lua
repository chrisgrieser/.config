return {
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
	{ -- just a duck
		"tamton-aquib/duck.nvim",
		keys = {
			{ "<leader>zd", function() require("duck").hatch("🦆", 5) end, desc = "󰇥 Hatch Duck" },
			{ "<leader>zc", function() require("duck").cook("💀") end, desc = "󰇥 Cook Duck" },
		},
	},
	-- TODO
	-- implement timer & autocmds for making this a screensaver
	-- https://github.com/folke/drop.nvim/blob/main/lua/drop/config.lua#L184-L188
	-- https://github.com/folke/drop.nvim/blob/main/lua/drop/config.lua#L140-L155
	{ -- impressive animations
		"Eandrju/cellular-automaton.nvim",
		keys = {
			-- stylua: ignore
			{ "<leader>zr", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "󰯉 Make it Rain" },
			-- stylua: ignore
			{ "<leader>zg", "<cmd>CellularAutomaton game_of_life<CR>", desc = "󰯉 Game of Life" },
		},
		config = function()
			require("which-key").register { mode = { "n" }, ["<leader>z"] = { name = "󰯉 Zilly Fun Stuff" } }
		end
	},
}
