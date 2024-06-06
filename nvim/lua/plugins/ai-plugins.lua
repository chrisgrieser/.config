-- INFO potential AI plugins:
-- https://github.com/huggingface/llm-ls
-- https://github.com/sourcegraph/sg.nvim
-- https://github.com/Bryley/neoai.nvim
-- https://github.com/supermaven-inc/supermaven-nvim/
-- https://github.com/monkoose/neocodeium
--------------------------------------------------------------------------------

return {
	{
		"supermaven-inc/supermaven-nvim",
		build = "SupermavenUseFree", -- needs to be run once to set the API key
		cmd = "SupermavenStop", -- when starting a recoding before the plugin is loaded
		event = "InsertEnter",
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
		},
		init = function()
			-- disable while recording
			vim.api.nvim_create_autocmd("RecordingEnter", { command = "SupermavenStop" })
			vim.api.nvim_create_autocmd("RecordingLeave", { command = "SupermavenStart" })
		end,
	},
}
