return {
	"olimorris/codecompanion.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
	opts = {
		strategies = {
			chat = {
				adapter = "openai",
			},
			inline = {
				adapter = "openai",
			},
			cmd = {
				adapter = "openai",
			},
		},
		adapters = {
			openai = function()
				return require("codecompanion.adapters").extend("openai", {
					env = {
						api_key = "cmd"
					},
				})
			end,
		},
	},
}
