-- vim: foldlevel=2
-- DOCS https://codecompanion.olimorris.dev/
--------------------------------------------------------------------------------

-- https://platform.openai.com/usage
-- https://platform.openai.com/docs/models
local model = {
	name = "gpt-5-mini",
	reasoningEffort = "minimal", -- all GPT-5 models reason, "medium" is too slow
	apiKeyFile = "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt",
	provider = "openai",
}
local useGitSignsInlineDiff = true
local formatInlineResult = true

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
			local modelName = ctx.data.adapter.model
			timer = assert(vim.uv.new_timer())
			timer:start(
				0,
				updateIntervalMs,
				vim.schedule_wrap(function()
					local spinner = spinners[math.floor(vim.uv.now() / updateIntervalMs) % #spinners + 1]
					vim.notify(modelName .. " " .. spinner, vim.log.levels.DEBUG, {
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
			local modelName = ctx.data.adapter.model
			timer:stop()
			timer:close()
			vim.notify(modelName .. " finished ✅", nil, {
				title = "CodeCompanion",
				icon = "",
				id = ctx.data.id,
			})
		end,
	})
end

local function postRequestHook()
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
		desc = "User: format & show diff when CodeCompanion finished",
		pattern = "CodeCompanionInlineFinished",
		callback = function(ctx)
			local ok, conform = pcall(require, "conform")
			if formatInlineResult then
				if not ok then vim.lsp.buf.format { bufnr = ctx.buf } end
				if ok then conform.format { bufnr = ctx.buf } end
			end
			local ok2, gitsigns = pcall(require, "gitsigns")
			if ok2 and useGitSignsInlineDiff then
				require("gitsigns.config").config.show_deleted = true
				gitsigns.setup { linehl = true, word_diff = true }
			end
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
		postRequestHook()
	end,
	keys = {
		{ "<leader>ac", "<cmd>CodeCompanionChat toggle<CR>", desc = " Chat (toggle)" },
		{ "<leader>aa", ":CodeCompanion<CR>", mode = "x", desc = " 󰘎 Prompt" },

		-- stylua: ignore start
		{ "<leader>as", function() require("codecompanion").prompt("simplify") end, mode = "x", desc = " Simplify" },
		{ "<leader>ae", function() require("codecompanion").prompt("explain") end, mode = "x", desc = " Simplify" },
		{ "<leader>ap", function() require("codecompanion").prompt("proofread") end, mode = "x", desc = " Proofread" },
		-- stylua: ignore end
	},
	opts = {
		prompt_library = {
			markdown = {
				dirs = {
					vim.fn.stdpath("config") .. "/prompts", -- in nvim config
					-- also accepts relative path to cwd https://codecompanion.olimorris.dev/configuration/prompt-library#adding-prompts
				},
			},
		},
		adapters = {
			http = {
				openai = function()
					-- https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/adapters/http/openai.lua
					return require("codecompanion.adapters").extend("openai", {
						env = {
							api_key = ("cmd:cat %q"):format(model.apiKeyFile),
						},
						schema = {
							model = { default = model.name },
							reasoning_effort = { default = model.reasoningEffort },
						},
					})
				end,
			},
		},
		display = {
			diff = {
				enabled = false, -- disabled, since inline-stragy does not handle indents properly
			},
			-- https://codecompanion.olimorris.dev/configuration/chat-buffer.html
			chat = {
				auto_scroll = false,
				fold_context = true,
				icons = { chat_context = "󰔌" }, -- icon for the fold context
			},
		},
		strategies = {
			inline = { adapter = model.provider },
			chat = {
				adapter = model.provider,
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
	},
}
