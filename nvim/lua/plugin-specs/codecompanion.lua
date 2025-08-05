-- DOCS https://codecompanion.olimorris.dev/
-- alternative: https://github.com/dlants/magenta.nvim
--------------------------------------------------------------------------------

return {
	"olimorris/codecompanion.nvim",
	cmd = "CodeCompanion",
	init = function()
		vim.g.whichkeyAddSpec { "<leader>a", group = " AI" }

		vim.api.nvim_create_autocmd("User", {
			desc = "User: add notifications for codecompanion",
			pattern = "CodeCompanionRequestStarted",
			callback = function()
				vim.notify("Request started.", nil, { title = "CodeCompanion", icon = "" })
			end,
		})
	end,
	keys = {
		-- `:` for the visual mode commands, so context gets passed via `<>` marks
		{ "<leader>aa", ":CodeCompanion<CR>", mode = "x", desc = " Inline assistant" },
		{ "<leader>as", ":CodeCompanion simplify<CR>", mode = "x", desc = " Simplify" },
		{ "<leader>ae", ":CodeCompanion explain this<CR>", mode = "x", desc = " Explain" },
		{ "<leader>ac", "<cmd>CodeCompanionChat toggle<CR>", desc = " Simplify" },
	},
	opts = {
		display = {
			-- not helpful anyway, just using gitsigns word-diff afterwards instead
			diff = { enabled = false },
		},
		strategies = {
			inline = { adapter = "openai" },
			cmd = { adapter = "openai" },
		},
		adapters = {
			openai = function()
				local model = "gpt-4.1-mini" -- https://platform.openai.com/docs/models
				local apiKeyFile =
					"$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/openai-api-key.txt"

				return require("codecompanion.adapters").extend("openai", {
					schema = { model = { default = model } },
					env = {
						api_key = ("cmd:cat %q"):format(apiKeyFile),
					},
				})
			end,
		},
	},
}
