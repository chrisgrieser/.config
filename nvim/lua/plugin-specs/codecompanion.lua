-- DOCS https://codecompanion.olimorris.dev/
--------------------------------------------------------------------------------

return {
	"olimorris/codecompanion.nvim",
	cmd = "CodeCompanion",
	init = function()
		vim.g.whichkeyAddSpec { "<leader>a", group = " AI" }

		vim.api.nvim_create_autocmd("User", {
			desc = "User: add notifications for codecompanion",
			pattern = "CodeCompanionRequest*InlineStarted",
			callback = function(ctx)
				local type = ctx.match:match("CodeCompanionRequest(%a+)InlineStarted"):lower()
				vim.notify("Request " .. type .. ".", nil, { title = "CodeCompanion", icon = "" })
			end,
		})
	end,
	keys = {
		-- `:` so context gets passed via `<>` marks
		{ "<leader>aa", ":CodeCompanion<CR>", mode = { "n", "x" }, desc = " Inline assistant" },
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
