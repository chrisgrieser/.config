return {
	{ -- just a duck
		"tamton-aquib/duck.nvim",
		keys = {
			{ "<leader>ö", function() require("duck").hatch("🦆", 5) end, desc = "󰇥 Hatch Duck" },
			{ "<leader>Ö", function() require("duck").cook("💀") end, desc = "󰇥 Cook Duck" },
		},
	},
}
