-- DOCS https://codecompanion.olimorris.dev/
return {
	"olimorris/codecompanion.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
	init = function () vim.g.whichkeyAddSpec { "<leader>a", group = " Code Companion" } end,
	keys = {
		{ "<leader>aa", ":CodeCompanion ", desc = " Inline Assistant" },
		{ "<leader>ac", "<cmd>CodeCompanionChat<CR>", desc = " Chat" },
	},
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
						api_key = vim.env.OPENAI_API_KEY,
					},
					schema = {
						model = {
							default = "gpt-4o-mini",
						},
					},
				})
			end,
		},
	},
}
