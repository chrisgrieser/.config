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
	-- {
	-- 	"Exafunction/codeium.vim",
	-- 	event = "InsertEnter",
	-- 	init = function()
	-- 		vim.g.codeium_disable_bindings = 1 -- no default bindings
	-- 		vim.g.codeium_filetypes = {
	-- 			applescript = false,
	-- 		}
	-- 	end,
	-- 	config = function()
	-- 		-- stylua: ignore start
	-- 		vim.keymap.set("i", "<C-e>", function() return vim.fn["codeium#Clear"]() end, { desc = "codium clear", expr = true })
	-- 		vim.keymap.set("i", "<C-c>", function() return vim.fn["codeium#Accept"]() end, { desc = "codium accept", expr = true })
	-- 		-- stylua: ignore end
	-- 	end,
	-- },
}
