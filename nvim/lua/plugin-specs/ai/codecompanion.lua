-- DOCS https://codecompanion.olimorris.dev/
-- alternative: https://github.com/dlants/magenta.nvim
--------------------------------------------------------------------------------

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
	init = function()
		vim.g.whichkeyAddSpec { "<leader>a", group = " AI" }

		-- Start: notify
		vim.api.nvim_create_autocmd("User", {
			desc = "User: CodeCompanion started",
			pattern = "CodeCompanionRequestStarted",
			callback = function()
				vim.notify("Request started.", nil, { title = "CodeCompanion", icon = "" })
			end,
		})
		-- Finish: notify & format on success
		vim.api.nvim_create_autocmd("User", {
			desc = "User: CodeCompanion finished",
			pattern = "CodeCompanionRequestFinished",
			callback = function(ctx)
				local success = ctx.data.status == "success"
				local result = success and "finished." or "failed: " .. ctx.data.status
				local lvl = success and "info" or "error"
				vim.notify("Request " .. result, lvl, { title = "CodeCompanion", icon = "" })
				if success then require("personal-plugins.misc").formatWithFallback() end
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
				-- https://platform.openai.com/usage
				-- https://platform.openai.com/docs/models
				local model = "gpt-5"
				local apiKeyFile =
					"$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/openai-api-key.txt"

				return require("codecompanion.adapters").extend("openai", {
					schema = { model = { default = model } },
					env = { api_key = ("cmd:cat %q"):format(apiKeyFile) },
				})
			end,
		},
	},
}
