-- DOCS https://codecompanion.olimorris.dev/
-- alternative: https://github.com/dlants/magenta.nvim
--------------------------------------------------------------------------------

-- https://platform.openai.com/usage
-- https://platform.openai.com/docs/models

-- INFO not switching to 5 yet, since it's slow when not also reducing reasoning
-- effort, for which there release yet
local model = "gpt-4.1-mini"

--------------------------------------------------------------------------------

local function spinnerNotificationWhileRequest()
	if not package.loaded["snacks"] then return end

	-- CONFIG
	local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local updateIntervalMs = 250

	local timer
	vim.api.nvim_create_autocmd("User", {
		desc = "User: CodeCompanion spinner (start)",
		pattern = "CodeCompanionRequestStarted",
		callback = function(ctx)
			timer = assert(vim.uv.new_timer())
			timer:start(
				0,
				updateIntervalMs,
				vim.schedule_wrap(function()
					local spinner = spinners[math.floor(vim.uv.now() / updateIntervalMs) % #spinners + 1]
					vim.notify("Request running " .. spinner, vim.log.levels.DEBUG, {
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
		desc = "User: CodeCompanion spinner (stop)",
		pattern = "CodeCompanionRequestFinished",
		callback = function(ctx)
			timer:stop()
			timer:close()
			vim.notify("Request finished ✅", nil, {
				title = "CodeCompanion",
				icon = "",
				timeout = 2000,
				id = ctx.data.id,
			})
		end,
	})
end

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanion", "CodeCompanionChat" },
	init = function() vim.g.whichkeyAddSpec { "<leader>a", group = " AI" } end,
	config = function(_, opts)
		require("codecompanion").setup(opts)

		spinnerNotificationWhileRequest()

		vim.api.nvim_create_autocmd("User", {
			desc = "User: CodeCompanion finished",
			pattern = "CodeCompanionInlineFinished",
			callback = function()
				if jit.os == "OSX" then
					local sound =
						"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/head_gestures_double_shake.caf"
					vim.system { "afplay", sound }
				end
				vim.defer_fn(vim.lsp.buf.format, 200)
			end,
		})
	end,
	keys = {
		{ "<leader>aa", ":CodeCompanion<CR>", mode = "x", desc = " Inline assistant" },
		{ "<leader>ac", "<cmd>CodeCompanionChat toggle<CR>", desc = " Toggle chat" },
		-- stylua: ignore
		{ "<leader>ae", function() require("codecompanion").prompt("explain") end, mode = "x", desc = " Explain" },
		-- stylua: ignore
		{ "<leader>as", function() require("codecompanion").prompt("simplify") end, mode = "x", desc = " Simplify" },
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
		prompt_library = {
			["Simplify"] = {
				strategy = "inline",
				description = "Simplify the selected code.",
				opts = {
					modes = { "v" },
					short_name = "simplify",
					auto_submit = true,
					stop_context_insertion = true,
					user_prompt = false,
				},
				prompts = {
					{
						role = "system",
						content = function(ctx)
							return ([[
								I want you to act as a senior %s developer. 
								I will send you some code, and I want you to simplify the code. 
								Do not diminish readability of the code while doing so.
							]]):format(ctx.filetype)
						end,
					},
					{
						role = "user",
						content = function(ctx)
							-- stylua: ignore
							return require("codecompanion.helpers.actions").get_code(ctx.start_line, ctx.end_line)
						end,
						opts = { contains_code = true },
					},
				},
			},
		},
	},
}
