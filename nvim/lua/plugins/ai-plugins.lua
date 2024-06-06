-- INFO potential AI plugins:
-- https://github.com/huggingface/llm-ls
-- https://github.com/sourcegraph/sg.nvim
-- https://github.com/Bryley/neoai.nvim
-- https://github.com/supermaven-inc/supermaven-nvim/
-- https://github.com/monkoose/neocodeium
--------------------------------------------------------------------------------

return {
	{
		"AlejandroSuero/supermaven-nvim",
		build = ":SupermavenUseFree", -- needs to be run once to set the API key
		event = "InsertEnter",
		branch = "feature/exposing-suggestion-group",
		keys = {
			{ "<D-s>", mode = "i" },
			{
				"<leader>oa",
				function()
					vim.cmd.SupermavenToggle()
					vim.cmd.SupermavenStatus()
				end,
				desc = "󰚩 Supermaven Suggestions",
			},
		},
		opts = {
			keymaps = { accept_suggestion = "<D-s>" },
			ignore_filetypes = {
				gitcommit = true,
				DressingInput = true,
				text = true, -- `pass`' filetype when editing passwords
				regex = true, -- rg-substitute buffer
			},
			color = { suggestion_group = "NonText" },
		},
		config = function(_, opts)
			require("supermaven-nvim").setup(opts)

			-- PENDING https://github.com/supermaven-inc/supermaven-nvim/issues/49
			-- https://github.com/AlejandroSuero/supermaven-nvim/tree/feature/exposing-suggestion-group
			-- require("supermaven-nvim.completion_preview").suggestion_group = "NonText"

			-- f ff fff

			-- disable while recording
			vim.api.nvim_create_autocmd("RecordingEnter", { command = "SupermavenStop" })
			vim.api.nvim_create_autocmd("RecordingLeave", { command = "SupermavenStart" })
		end,
	},
}
