vim.env.LAZY_STDPATH = "/tmp/nvim-debug"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local apiKeyFile =
	"$HOME/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt"

-- Your CodeCompanion setup
local plugins = {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
			{ "nvim-lua/plenary.nvim" },
		},
		opts = {
			strategies = {
				inline = { adapter = "openai" },
				chat = { adapter = "openai" },
			},
			opts = { log_level = "DEBUG" },
		},
		adapters = {
			http = {
				openai = function()
					return require("codecompanion.adapters").extend("openai", {
						api_key = ("cmd:cat %q"):format(apiKeyFile),
						schema = {
							model = { default = "gpt-5-mini" },
							reasoning_effort = { default = "minimal" },
						},
					})
				end,
			},
		},
	},
}

-- Leaving this comment in to see if the issue author notices ;-)
-- This is so I can tell if they've really tested with their own minimal.lua file
require("lazy.minit").repro { spec = plugins }

-- Setup Tree-sitter
local ts_status, treesitter = pcall(require, "nvim-treesitter.configs")
if ts_status then
	treesitter.setup {
		ensure_installed = { "lua", "markdown", "markdown_inline", "yaml", "diff" },
		highlight = { enable = true },
	}
end
