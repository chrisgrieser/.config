-- INFO openai_api_key defined in zshenv
--------------------------------------------------------------------------------
return {
	{
		"jackMort/ChatGPT.nvim",
		cmd = "ChatGPT",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		config = function()
			require("chatgpt").setup {
				welcome_message = "",
				max_line_length = 90,
				keymaps = {
					close = "<Esc>", -- mappings Esc here removes ability to use normal mode
					yank_last = "<D-c>",
					new_session = "<D-k>", -- = clear
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
					border = { style = BorderStyle },
				},
				chat_input = {
					prompt = " > ",
					border = { style = BorderStyle },
				},
			}
		end,
	},
	{
		"jcdickinson/codeium.nvim",
		event = "InsertEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup {
				config_path = vim.env.ICLOUD .. "Dotfolder/private dotfiles/codium-api-key.json",
				bin_path = vim.fn.stdpath("data") .. "/codeium",
			}
		end,
	},
}
