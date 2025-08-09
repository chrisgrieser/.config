-- DOCS https://codecompanion.olimorris.dev/
-- alternative: https://github.com/dlants/magenta.nvim
--------------------------------------------------------------------------------

-- CONFIG
-- https://platform.openai.com/usage
-- https://platform.openai.com/docs/models
local model = "gpt-5"
local apiKeyFile =
	"$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/openai-api-key.txt"

--------------------------------------------------------------------------------

local function spinnerNotificationWhileRequest()
	-- CONFIG
	local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local updateIntervalMs = 300

	local timer = assert(vim.uv.new_timer())
	vim.api.nvim_create_autocmd("User", {
		desc = "User: CodeCompanion lualine spinner (start)",
		pattern = "CodeCompanionRequestStarted",
		callback = function(ctx)
			if not package.loaded["snacks"] then return end
			timer:start(
				updateIntervalMs,
				updateIntervalMs,
				vim.schedule_wrap(function()
					local spinner = spinners[math.floor(vim.uv.now() / 300) % #spinners + 1]
					vim.notify("Request running " .. spinner, nil, {
						title = "CodeCompanion",
						icon = "",
						timeout = false,
						id = ctx.data.id, -- replaces existing notification
					})
				end)
			)
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		desc = "User: CodeCompanion lualine spinner (stop)",
		pattern = "CodeCompanionRequestFinished",
		callback = function(ctx)
			if not package.loaded["snacks"] then return end
			vim.notify("Request finished ✅", nil, { timeout = 2000, id = ctx.data.id })
			timer:stop()
			timer:close()
		end,
	})
end

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
	init = function() vim.g.whichkeyAddSpec { "<leader>a", group = " AI" } end,
	config = function(_, opts)
		require("codecompanion").setup(opts)

		spinnerNotificationWhileRequest()

		vim.api.nvim_create_autocmd("User", {
			desc = "User: CodeCompanion format on success",
			pattern = "CodeCompanionRequestFinished",
			callback = function(ctx)
				if ctx.data.status == "success" and vim.bo[ctx.buf].buftype == "" then
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
			chat = { -- https://codecompanion.olimorris.dev/configuration/chat-buffer.html
				auto_scroll = false,
				window = {
					opts = { statuscolumn = " " }, -- padding
				},
			},
		},
		strategies = {
			inline = { adapter = "openai" },
			cmd = { adapter = "openai" },
			chat = { adapter = "openai" },
		},
		adapters = {
			openai = function()
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
