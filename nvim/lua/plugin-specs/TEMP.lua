local apiKeyFile =
	"$HOME/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt"

return {
	"olimorris/codecompanion.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	lazy = false,
	keys = {
		{ ",ae", function() require("codecompanion").prompt("explain") end, mode = "x" },
	},
	opts = {
		interactions = {
			chat = { adapter = { name = "openai", model = "gpt-5-mini" } },
		},
		opts = { log_level = "DEBUG" },
		adapters = {
			http = {
				openai = function()
					return require("codecompanion.adapters").extend("openai", {
						env = {
							api_key = ("cmd:cat %q"):format(apiKeyFile),
						},
						schema = {
							reasoning_effort = { default = "minimal" },
						},
					})
				end,
			},
		},
	},
}
