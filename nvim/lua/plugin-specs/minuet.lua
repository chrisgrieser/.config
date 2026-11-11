vim.pack.add { "https://github.com/milanglacier/minuet-ai.nvim" }
--------------------------------------------------------------------------------
-- ALTERNATIVES
-- Copilot LSP (subscription), requires nvim 0.12 https://github.com/github/copilot-language-server-release
-- Cerebras: https://github.com/4tyone/snek-nvim
-- Cerebras: https://github.com/jim-at-jibba/nvim-stride
--------------------------------------------------------------------------------

Keymap { "<leader>oa", "<cmd>Minuet virtualtext toggle<CR>", desc = "󰚩 Toggle Minuet AI" }

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	desc = "User: Highlights for minuet-ai.nvim",
	callback = function() vim.api.nvim_set_hl(0, "MinuetVirtualText", { link = "NonText" }) end,
})

vim.g.lualineAdd("sections", "lualine_x", {
	require("minuet.lualine"),
	fmt = function(str)
		if str ~= "" then return "󰚩 Minuet" end
	end,
}, "before")

--------------------------------------------------------------------------------

-- DOCS https://github.com/milanglacier/minuet-ai.nvim#configuration
require("minuet").setup {
	-- the maximum total characters of the context before and after the cursor
	-- 16000 characters typically equate to approximately 4,000 tokens for LLMs.
	context_window = 4000,
	throttle = 500, -- only send the request every x milliseconds, use 0 to disable
	debounce = 200, -- inactivity before request is sent x milliseconds, set to 0 to disable
	notify = "warn", -- notifications shown: "verbose"|"warn"|"error"
	-- The request timeout, measured in seconds. When streaming is enabled
    -- (stream = true), setting a shorter request_timeout allows for faster
    -- retrieval of completion items, albeit potentially incomplete.
    -- Conversely, with streaming disabled (stream = false), a timeout
    -- occurring before the LLM returns results will yield no completion items.
    request_timeout = 2.5,
    n_completions = 2,

	-----------------------------------------------------------------------------

	-- https://github.com/milanglacier/minuet-ai.nvim#openai
	provider = "openai",
	provider_options = {
		openai = {
			model = "gpt-6-luna", -- https://developers.openai.com/api/docs/models/gpt-6-luna
			stream = true,
			optional = { reasoning_effort = "none" }, -- quicker
			api_key = function()
				local file = io.open(vim.g.openaiApiKeyFile, "r")
				assert(file, "Could not find file for `OPENAI_API_KEY`.")
				local apiKey = file:read("*l") -- reads first line
				file:close()
				return apiKey
			end,
		},
	},

	--------------------------------------------------------------------

	virtualtext = {
		auto_trigger_ft = { "*" }, -- = all filetypes
		auto_trigger_ignore_ft = {
			bib = false,
			text = false, -- filetype when editing in `pass` (extra safeguard)
			csv = false,
		},
		keymap = {
			accept = "<D-s>",
			accept_line = "<D-S>",
			next = "<D-a>",
		},
		-- Whether show virtual text suggestion when the completion menu
		-- (nvim-cmp or blink-cmp) is visible.
		show_on_completion_menu = true,
	},

	blink = {
		enable_auto_complete = false,
	},
	lsp = {
		completion = { enable = true },
	},

	-----------------------------------------------------------------------------

	-- LIST of functions to execute. If any function returns `false`, Minuet
	-- will not trigger auto-completion. Manual completion can still be invoked.
	enable_predicates = {
		function()
			-- INFO plugins are already disabled when using `pass`, this is an
			-- extra safeguard to disable AI for those buffers
			local bufnr = vim.api.nvim_get_current_buf()
			local filepath = vim.api.nvim_buf_get_name(bufnr)
			local filename = vim.fs.basename(filepath)

			-- conditions to ignore
			local isRecording = vim.fn.reg_recording() ~= ""
			local specialBuffer = vim.bo[bufnr].buftype ~= ""
			local extensionlessFile = not filename:find("%.")
			if isRecording or specialBuffer or extensionlessFile then return false end

			-- paths to ignore
			local pathsToIgnore = {
				"security",
				"leetcode/", -- should do leetcode problems on my own
				"/private/var/", -- path when editing in `pass` (extra safeguard)
				"api-key",
				".env",
				"config.local",
				"recovery", -- e.g., password recovery files
			}
			local ignorePath = vim.iter(pathsToIgnore):any(
				function(ignored) return filepath:lower():find(ignored, 1, true) ~= nil end
			)
			if ignorePath then
				vim.notify_once("Disabled AI on this buffer.")
				return false
			end

			return true
		end,
	},
}

--------------------------------------------------------------------------------
