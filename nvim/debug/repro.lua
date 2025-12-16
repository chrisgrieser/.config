vim.env.LAZY_STDPATH = "/tmp/nvim-debug"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local plugins = {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-treesitter/nvim-treesitter", lazy = false, build = ":TSUpdate" },
		},
		opts = {
			opts = { log_level = "DEBUG" },
			interactions = {
				chat = {
					adapter = { name = "openai_responses", model = "gpt-5-mini" },
				},
				inline = {
					adapter = { name = "openai_responses", model = "gpt-5-mini" },
				},
			},
			adapters = {
				http = {
					openai_responses = function()
						return require("codecompanion.adapters").extend("openai_responses", {
							env = {
								api_key = 'cmd:cat "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt"',
							},
							schema = {
								model = {
									choices = {
										["gpt-5-mini"] = { opts = { can_reason = true } },
									},
								},
								["reasoning.effort"] = { default = "minimal" },
								["reasoning.summary"] = { enabled = function() return false end },
							},
						})
					end,
				},
			},
		},
	},
}

require("lazy.minit").repro { spec = plugins }

--------------------------------------------------------------------------------

require("nvim-treesitter").install { "lua", "markdown", "markdown_inline", "yaml" }
