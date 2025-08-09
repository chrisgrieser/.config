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
				if success and vim.bo[ctx.buf].buftype == "" then
					require("personal-plugins.misc").formatWithFallback()
				end
			end,
		})
	end,
	keys = {
		-- `:` for the visual mode commands, so context gets passed via `<>` marks
		{ "<leader>aa", ":CodeCompanion<CR>", mode = "x", desc = " Inline assistant" },
		{ "<leader>as", ":CodeCompanion simplify<CR>", mode = "x", desc = " Simplify" },
		-- stylua: ignore
		{ "<leader>ae", "<cmd>CodeCompanionChat explain this<CR>", mode = "x", desc = " Explain (chat)" },
		{ "<leader>ac", "<cmd>CodeCompanionChat toggle<CR>", desc = " Toggle chat" },
	},
	opts = {
		display = {
			-- not helpful anyway, just using gitsigns word-diff afterwards instead
			diff = { enabled = false },
			chat = {
				
			}
		},
		strategies = {
			inline = { adapter = "openai" },
			cmd = { adapter = "openai" },
			chat = { adapter = "openai" },
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
					-- GPT-5 models requires organizational verification if streaming
					opts = { stream = false },
				})
			end,
		},
	},
}
