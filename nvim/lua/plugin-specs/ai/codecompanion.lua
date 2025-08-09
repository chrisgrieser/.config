-- DOCS https://codecompanion.olimorris.dev/
-- alternative: https://github.com/dlants/magenta.nvim
--------------------------------------------------------------------------------

-- CONFIG
-- https://platform.openai.com/usage
-- https://platform.openai.com/docs/models
local model = "gpt-4.1-mini" -- not switching to 5 yet, since it's slow

--------------------------------------------------------------------------------

local function spinnerNotificationWhileRequest()
	if not package.loaded["snacks"] then return end

	-- CONFIG
	local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local updateIntervalMs = 300

	local timer
	vim.api.nvim_create_autocmd("User", {
		desc = "User: CodeCompanion lualine spinner (start)",
		pattern = "CodeCompanionRequestStarted",
		callback = function(ctx)
			timer = assert(vim.uv.new_timer())
			timer:start(
				0,
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
			timer:stop()
			timer:close()
			vim.notify("Request finished ✅", nil, {
				title = "CodeCompanion",
				icon = "",
				timeout = 3000,
				id = ctx.data.id,
			})
			if jit.os == "OSX" then
				local sound =
					"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/head_gestures_double_shake.caf"
				vim.system { "afplay", sound }
			end
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
			pattern = "CodeCompanionInlineFinished",
			callback = function(ctx)
				vim.defer_fn(function() vim.lsp.buf.format { bufnr = ctx.buf } end, 1000)
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

			-- https://codecompanion.olimorris.dev/configuration/chat-buffer.html
			chat = {
				auto_scroll = false,
				intro_message = "",
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
				local apiKeyFile =
					"$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/openai-api-key.txt"

				-- https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/adapters/openai.lua
				return require("codecompanion.adapters").extend("openai", {
					schema = { model = { default = model } },
					env = { api_key = ("cmd:cat %q"):format(apiKeyFile) },
					opts = {
						-- GPT-5 models requires organizational verification if streaming
						stream = model:find("gpt%-5"),
					},
				})
			end,
		},
	},
}
