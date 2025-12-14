vim.env.LAZY_STDPATH = "/tmp/nvim-debug"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local plugins = {
	{
		"olimorris/codecompanion.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			strategies = {
				inline = { adapter = "openai" },
				chat = { adapter = "openai" },
			},
			opts = { log_level = "DEBUG" },
			adapters = {
				http = {
					openai = function()
						return require("codecompanion.adapters").extend("openai", {
							env = {
								api_key = "…"
							},
							schema = {
								model = { default = "gpt-5-mini" },
								reasoning_effort = { default = "minimal" },
							},
						})
					end,
				},
			},
		},
	},
}

require("lazy.minit").repro { spec = plugins }
