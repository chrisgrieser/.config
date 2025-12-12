-- vim: foldlevel=2
-- DOCS https://codecompanion.olimorris.dev/
--------------------------------------------------------------------------------

-- https://platform.openai.com/usage
-- https://platform.openai.com/docs/models
-- CONFIG
local model = "gpt-5-mini"
local reasoning_effort = "minimal" -- all GPT-5 models reason, "medium" is too slow
local apiKeyFile =
	"$HOME/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt"

--------------------------------------------------------------------------------

local function spinnerNotificationWhileRequest()
	if not package.loaded["snacks"] then return end

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

return {
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

		vim.api.nvim_create_autocmd("User", {
			desc = "User: leave visual mode",
			pattern = "CodeCompanionRequestFinished",
			callback = function()
				if vim.fn.mode():lower() ~= "v" then return end
				vim.cmd.normal { vim.fn.mode(), bang = true }
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			desc = "User: format & show diff when CodeCompanion finished",
			pattern = "CodeCompanionRequestFinished",
			callback = function(ctx)
				local ok, conform = pcall(require, "conform")
				if not ok then vim.lsp.buf.format { bufnr = ctx.buf } end
				if ok then conform.format { bufnr = ctx.buf } end
				local ok2, gitsigns = pcall(require, "gitsigns")
				if not ok2 then return end
				gitsigns.toggle_linehl()
				gitsigns.toggle_word_diff()
				require("gitsigns.config").config.show_deleted = true
			end,
		})
	end,
	keys = {
		{ "<leader>ac", "<cmd>CodeCompanionChat toggle<CR>", desc = " Chat (toggle)" },
		{ "<leader>aa", ":CodeCompanion<CR>", mode = "x", desc = " 󰘎 Prompt" },

		-- builtin-prompts https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
		-- stylua: ignore start
		{ "<leader>ae", function() require("codecompanion").prompt("explain") end, mode = "x", desc = " Explain" },
		{ "<leader>af", function() require("codecompanion").prompt("fix") end, mode = "x", desc = " Fix" },
		-- my own prompts
		{ "<leader>as", function() require("codecompanion").prompt("simplify") end, mode = "x", desc = " Simplify" },
		{ "<leader>ap", function() require("codecompanion").prompt("proofread") end, mode = "x", desc = " Proofread" },
		-- stylua: ignore end
	},
	opts = {
		display = {
			-- disabled, since inline-stragy does not handle indents properly
			-- diff = { enabled = false }, -- https://codecompanion.olimorris.dev/configuration/chat-buffer.html#diff

			-- https://codecompanion.olimorris.dev/configuration/chat-buffer.html
			chat = {
				auto_scroll = false,
				intro_message = "",
				fold_context = true,
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
			inline = {
				adapter = "openai",
				keymaps = {
					accept_change = { modes = { n = "ga" } },
					reject_change = { modes = { n = "gb" } },
					always_accept = { modes = { n = "gy" } },
				},
			},
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
			http = {
				openai = function()
					-- https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/adapters/http/openai.lua
					return require("codecompanion.adapters").extend("openai", {
						env = {
							api_key = ("cmd:cat %q"):format(apiKeyFile),
						},
						schema = {
							model = { default = model },
							reasoning_effort = { default = reasoning_effort },
						},
					})
				end,
			},
		},
		prompt_library = {
			-- https://codecompanion.olimorris.dev/extending/prompts.html
			["Simplify"] = {
				strategy = "inline",
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

								Keep the indentation level strictly the same, and do not
								change for formatting style.
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
			["Proofread"] = {
				strategy = "inline",
				opts = {
					modes = { "v" },
					short_name = "proofread",
					auto_submit = true,
					stop_context_insertion = true,
					user_prompt = false,
				},
				prompts = {
					{
						role = "system",
						content = function(_ctx)
							return [[
								You are an editor for the English language.
								I will send you some text, and I want you to improve the
								language, without changing the meaning.
							]]
						end,
					},
					{
						role = "user",
						content = function(ctx)
							-- stylua: ignore
							return require("codecompanion.helpers.actions").get_code(ctx.start_line, ctx.end_line)
						end,
					},
				},
			},
		},
	},
}
