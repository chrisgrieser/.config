-- vim: foldlevel=2
-- DOCS https://codecompanion.olimorris.dev/
--------------------------------------------------------------------------------

-- https://platform.openai.com/usage
-- https://platform.openai.com/docs/models
local model = "gpt-5-mini"
local reasoning_effort = "minimal" -- all GPT-5 models reason, "medium" is too slow

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
local ccSpec = {
	"olimorris/codecompanion.nvim",
	cmd = { "CodeCompanion", "CodeCompanionChat" },
	init = function() vim.g.whichkeyAddSpec { "<leader>a", group = " AI" } end,
	config = function(_, opts)
		require("codecompanion").setup(opts)

		spinnerNotificationWhileRequest()

		vim.api.nvim_create_autocmd("User", {
			desc = "User: Sound when CodeCompanion finished",
			pattern = "CodeCompanionRequestFinished",
			callback = function()
				if jit.os ~= "OSX" then return end
				local sound =
					"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/head_gestures_double_shake.caf"
				vim.system { "afplay", sound }
			end,
		})
	end,
	keys = {
		-- stylua: ignore start
		{ "<leader>ac", "<cmd>CodeCompanionChat toggle<CR>", desc = " Chat (toggle)" },
		{ "<leader>an", "<cmd>CodeCompanionChat<CR>", desc = " Chat (new)" },
		{ "<leader>aa", ":CodeCompanion<CR>", mode = "x", desc = " 󰘎 Prompt" },
		-- builtin-prompts https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
		{ "<leader>ae", function() require("codecompanion").prompt("explain") end, mode = "x", desc = " Explain" },
		{ "<leader>af", function() require("codecompanion").prompt("fix") end, mode = "x", desc = " Fix" },
		-- my own prompts
		{ "<leader>as", function() require("codecompanion").prompt("simplify") end, mode = "x", desc = " Simplify" },
		-- stylua: ignore end
	},
	opts = {
		display = {
			diff = { enabled = true }, -- https://codecompanion.olimorris.dev/configuration/chat-buffer.html#diff

			-- https://codecompanion.olimorris.dev/configuration/chat-buffer.html
			chat = {
				auto_scroll = false,
				intro_message = "",
				fold_context = true, -- BUG not working
				icons = { chat_context = "󰔌" }, -- icon for the fold context
				window = {
					opts = {
						foldlevel = 1,
						foldmethod = "expr",
						foldexpr = "v:lua.vim.treesitter.foldexpr()", -- allow folding codeblocks
						statuscolumn = " ", -- padding
					},
				},
			},
		},
		strategies = {
			inline = { adapter = "openai" },
			chat = {
				adapter = "openai",
				keymaps = {
					close = { modes = { n = "q" }, opts = { nowait = true } },
					stop = { modes = { n = "<C-c>" } },
					clear = { modes = { n = "<D-k>", i = "<D-k>" } },
					next_header = { modes = { n = "<C-j>", i = "<C-j>" } },
					previous_header = { modes = { n = "<C-k>", i = "<C-k>" } },
					fold_code = { modes = { n = "zz" } },
				},
			},
		},
		adapters = {
			openai = function()
				local apiKeyFile =
					"$HOME/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/openai-api-key.txt"

				-- https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/adapters/openai.lua
				return require("codecompanion.adapters").extend("openai", {
					env = { api_key = ("cmd:cat %q"):format(apiKeyFile) },
					schema = {
						model = {
							default = model,
							choices = {
								["gpt-5-nano"] = { opts = { has_vision = true, can_reason = true, stream = true } },
								["gpt-5-mini"] = { opts = { has_vision = true, can_reason = true, stream = false } },
								["gpt-5"] = { opts = { has_vision = true, can_reason = true, stream = false } },
							},
						},
						reasoning_effort = { default = reasoning_effort },
					},
				})
			end,
		},
		prompt_library = {
			-- https://codecompanion.olimorris.dev/extending/prompts.html
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
								I will send you some code, and I want you to simplify
								the code while not diminishing its readability.
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

--------------------------------------------------------------------------------

return {
	ccSpec,
	{ -- modifications to render-markdown config
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
		opts = { file_types = { "markdown", "codecompanion" } },
	},
}
