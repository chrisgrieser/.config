-- INFO potential AI plugins:
-- https://github.com/huggingface/llm-ls
-- https://github.com/SilasMarvin/lsp-ai
-- https://github.com/sourcegraph/sg.nvim
-- https://github.com/Bryley/neoai.nvim
-- https://github.com/supermaven-inc/supermaven-nvim/
-- https://github.com/monkoose/neocodeium
--------------------------------------------------------------------------------

return {
	{ -- lua alternative to the official codeium.vim plugin https://github.com/Exafunction/codeium.vim
		"monkoose/neocodeium",
		event = "InsertEnter",
		cmd = "NeoCodeium",
		opts = {
			filetypes = {
				DressingInput = false,
				TelescopePrompt = false,
				noice = false, -- sometimes triggered in error-buffers
				text = false, -- `pass` passwords editing filetype is plaintext
				["rip-substitute"] = false,
			},
			silent = true,
			show_label = false, -- signcolumn label for number of suggestions
		},
		init = function()
			-- disable while recording
			vim.api.nvim_create_autocmd("RecordingEnter", { command = "NeoCodeium disable" })
			vim.api.nvim_create_autocmd("RecordingLeave", { command = "NeoCodeium enable" })
		end,
		keys = {
			-- stylua: ignore start
			{ "<D-s>", function() require("neocodeium").accept() end, mode = "i", desc = "󰚩 Accept full suggestion" },
			{ "<D-S>", function() require("neocodeium").accept_line() end, mode = "i", desc = "󰚩 Accept line" },
			{ "<D-d>", function() require("neocodeium").cycle(1) end, mode = "i", desc = "󰚩 Next suggestion" },
			-- stylua: ignore end
			{
				"<leader>oa",
				function()
					vim.cmd.NeoCodeium("toggle")
					local on = require("neocodeium.options").options.enabled
					require("config.utils").notify("NeoCodeium", on and "enabled" or "disabled", "info")
				end,
				desc = "󰚩 NeoCodeium Suggestions",
			},
		},
	},
	-- {
	-- 	"supermaven-inc/supermaven-nvim",
	-- 	build = ":SupermavenUseFree", -- needs to be run once to set the API key
	-- 	event = "InsertEnter",
	-- 	keys = {
	-- 		{ "<D-s>", mode = "i", desc = "󰚩 Accept Suggestion" },
	-- 		{ "<D-S>", mode = "i", desc = "󰚩 Accept Word" },
	-- 		{
	-- 			"<leader>oa",
	-- 			function()
	-- 				vim.cmd.SupermavenToggle()
	-- 				local text = require("supermaven-nvim.api").is_running() and "enabled" or "disabled"
	-- 				require("config.utils").notify("󰚩 Supermaven", text)
	-- 			end,
	-- 			desc = "󰚩 Supermaven Suggestions",
	-- 		},
	-- 	},
	-- 	opts = {
	-- 		keymaps = {
	-- 			accept_suggestion = "<D-s>",
	-- 			accept_word = "<D-S>",
	-- 		},
	-- 		log_level = "off", -- silence notifications
	-- 		ignore_filetypes = {
	-- 			gitcommit = true,
	-- 			DressingInput = true,
	-- 			TelescopePrompt = true,
	-- 			text = true, -- `pass`' filetype when editing passwords
	-- 			["rip-substitute"] = true,
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("supermaven-nvim").setup(opts)
	--
	-- 		-- PENDING https://github.com/supermaven-inc/supermaven-nvim/issues/49
	-- 		require("supermaven-nvim.completion_preview").suggestion_group = "NonText"
	--
	-- 		-- disable while recording
	-- 		vim.api.nvim_create_autocmd("RecordingEnter", { command = "SupermavenStop" })
	-- 		vim.api.nvim_create_autocmd("RecordingLeave", { command = "SupermavenStart" })
	-- 	end,
	-- },
}
