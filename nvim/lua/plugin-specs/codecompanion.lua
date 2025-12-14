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
local useGitSignsInlineDiff = false
local formatInlineResult = false

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

local function postRequestHook()
	vim.api.nvim_create_autocmd("User", {
		desc = "User: leave visual mode",
		pattern = "CodeCompanionInlineFinished",
		callback = function()
			if vim.fn.mode():lower() ~= "v" then return end
			vim.cmd.normal { vim.fn.mode(), bang = true }
		end,
	})

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
				gitsigns.toggle_linehl()
				gitsigns.toggle_word_diff()
				require("gitsigns.config").config.show_deleted = true
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
		{ "<leader>aa", ":CodeCompanion<CR>", mode = "x", desc = " 󰘎 Prompt" },
		-- stylua: ignore
		{ "<leader>as", function() require("codecompanion").prompt("simplify") end, mode = "x", desc = " Simplify" },
		-- stylua: ignore
		{ "<leader>ap", function() require("codecompanion").prompt("proofread") end, mode = "x", desc = " Proofread" },
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
			-- disabled, since inline-stragy does not handle indents properly
			diff = { enabled = false },
		},
		strategies = {
			inline = {
				adapter = model.provider,
				keymaps = {
					accept_change = { modes = { n = "ga" } },
					reject_change = { modes = { n = "gb" } },
					always_accept = { modes = { n = "gy" } },
				},
			},
			chat = { adapter = model.provider },
		},
	},
}
