-- DOCS https://codecompanion.olimorris.dev/
--------------------------------------------------------------------------------

return {
	"olimorris/codecompanion.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
	init = function()
		vim.g.whichkeyAddSpec { "<leader>a", group = " AI" }

		-- add notifications
		vim.api.nvim_create_autocmd("User", {
			desc = "User: notifications for codecompanion",
			pattern = "CodeCompanionRequest*",
			callback = function(ctx)
				local type = (ctx.match:match("CodeCompanionRequest(%a+)") or ""):lower()
				if type ~= "started" and type ~= "finished" then return end

				local opts = { title = "CodeCompanion", icon = "", id = "codecompanion" }
				vim.notify("Request " .. type .. ".", nil, opts)
			end,
		})
	end,
	keys = {
		{ "<leader>aa", ":CodeCompanion ", mode = { "n", "x" }, desc = " Inline assistant" },
		{ "<leader>ac", "<cmd>CodeCompanionChat<CR>", desc = " Chat" },
	},
	opts = {
		-- CodeCompanion settings
		display = {
			chat = {
				start_in_insert_mode = true,
				intro_message = "Press ? for options",
				show_header_separator = false,
				window = {
					layout = "vertical", -- also "float"
					opts = { statuscolumn = " " }, -- just for padding
				},
			},
			diff = {
				enabled = true,
			},
		},

		-- LLM settings
		strategies = {
			chat = { adapter = "openai" },
			inline = { adapter = "openai" },
			cmd = { adapter = "openai" },
		},
		adapters = {
			openai = function()
				return require("codecompanion.adapters").extend("openai", {
					env = { api_key = vim.env.OPENAI_API_KEY }, -- via .zshenv
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
