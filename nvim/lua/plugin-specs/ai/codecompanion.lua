-- vim: foldlevel=2
-- DOCS https://codecompanion.olimorris.dev/
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
local ccSpec = {
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
		-- stylua: ignore start
		{ "<leader>ac", "<cmd>CodeCompanionChat toggle<CR>", desc = " Chat (toggle)" },
		{ "<leader>an", "<cmd>CodeCompanionChat<CR>", desc = " Chat (new)" },
		{ "<leader>aa", ":CodeCompanion<CR>", mode = "x", desc = " 󰘎 Prompt" },
		-- builtin-prompts https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
		{ "<leader>ar", function() require("codecompanion").prompt("review_unstaged") end, desc = " Review unstaged changes" },
		{ "<leader>ae", function() require("codecompanion").prompt("explain") end, mode = "x", desc = " Explain" },
		{ "<leader>af", function() require("codecompanion").prompt("fix") end, mode = "x", desc = " Fix" },
		-- my own prompts
		{ "<leader>ai", function() require("codecompanion").prompt("improve") end, mode = "x", desc = " Improve" },
		-- stylua: ignore end
	},
	opts = {
		display = {
			-- not helpful anyway, just using gitsigns word-diff afterwards instead
			diff = { enabled = false },

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
			-- https://codecompanion.olimorris.dev/extending/prompts.html
			["Improve"] = {
				strategy = "inline",
				description = "Improve the selected code.",
				opts = {
					modes = { "v" },
					short_name = "Improve",
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
								I will send you some code, and I want you to improve the code.
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
			["Review unstaged changes"] = {
				strategy = "chat",
				description = "Review the currently unstaged changes, and suggest improvements",
				opts = {
					short_name = "review_unstaged",
					auto_submit = true,
				},
				prompts = {
					{
						role = "system",
						content = function(_ctx)
							return "The following diff is of a commit. Review the changes."
						end,
					},
					{
						role = "user",
						content = function(_ctx)
							local diff = vim.system({ "git", "diff" }):wait().stdout
							return "```diff\n" .. diff .. "\n```"
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
		opts = {
			file_types = { "markdown", "codecompanion" },
		},
	},
}
