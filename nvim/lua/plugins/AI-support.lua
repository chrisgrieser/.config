-- INFO openai_api_key defined in zshenv but there read from outside of dotfiles
--------------------------------------------------------------------------------
return {
	{
		"tzachar/cmp-tabnine",
		build = "./install.sh",
		event = "InsertEnter",
		config = function()
			-- TABNINE
			-- INFO also requires setup in cmp config
			require("cmp_tabnine.config"):setup { -- yes, requires a ":", not "."
				max_lines = 1000,
				max_num_results = 20,
				run_on_every_keystroke = true,
				snippet_placeholder = "…",
				show_prediction_strength = true,
			}
			local function prefetchTabnine() require("cmp_tabnine"):prefetch(vim.fn.expand("%:p")) end
			prefetchTabnine() -- initialize for the current buffer

			-- automatically prefetch completions for the buffer
			augroup("prefetchTabNine", {})
			autocmd("BufRead", {
				group = "prefetchTabNine",
				callback = prefetchTabnine,
			})
		end,
	},
	{
		"jackMort/ChatGPT.nvim",
		cmd = "ChatGPT",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		config = function()
			require("chatgpt").setup {
				welcome_message = "",
				-- question_sign = "",
				-- answer_sign = "ﮧ",
				max_line_length = 90,
				keymaps = {
					close = "<Esc>", -- mappings Esc here removes ability to use normal mode
					yank_last = "<D-c>",
					new_session = "<D-k>", -- clear
					scroll_up = "<S-Up>",
					scroll_down = "<S-Down>",
				},
				chat_layout = {
					size = {
						height = "90%",
						width = "90%",
					},
				},
				chat_window = {
					border = { style = borderStyle },
				},
				chat_input = {
					prompt = " > ",
					border = { style = borderStyle },
				},
			}
		end,
	},
	{
		"dense-analysis/neural",
		cmd = "NeuralCode",
		dependencies = "MunifTanjim/nui.nvim",
		config = function()
			require("neural").setup {
				mappings = {
					swift = nil,
					prompt = nil,
				},
				open_ai = {
					api_key = vim.env.OPENAI_API_KEY, -- not committed, defined in config/private-settings.lua outside of repo
					max_tokens = 1000,
					temperature = 0.1,
					presence_penalty = 0.5,
					frequency_penalty = 0.5,
				},
				ui = { icon = "ﮧ" },
			}
		end,
	},
	{
		"Exafunction/codeium.vim",
		event = "InsertEnter",
		-- currently supported languages: https://discord.com/channels/1027685395649015980/1027697446446432336/1053406784569737227
		config = function()
			vim.keymap.set(
				"i",
				"<C-c>",
				function() return vim.fn["codeium#Accept"]() end,
				{ expr = true, desc = "codium accept" }
			)
		end,
	},
}
