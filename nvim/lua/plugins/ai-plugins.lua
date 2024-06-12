-- INFO potential AI plugins:
-- https://github.com/huggingface/llm-ls
-- https://github.com/SilasMarvin/lsp-ai
-- https://github.com/sourcegraph/sg.nvim
-- https://github.com/Bryley/neoai.nvim
-- https://github.com/supermaven-inc/supermaven-nvim/
-- https://github.com/monkoose/neocodeium
--------------------------------------------------------------------------------

return {
	{
		"supermaven-inc/supermaven-nvim",
		build = ":SupermavenUseFree", -- needs to be run once to set the API key
		event = "InsertEnter",
		keys = {
			{ "<D-s>", mode = "i", desc = "󰚩 Accept Suggestion" },
			{ "<D-S>", mode = "i", desc = "󰚩 Accept Word" },
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
			disable_keymaps = false,
			keymaps = {
				accept_suggestion = "<D-s>",
				accept_word = "<D-S>",
			},
			ignore_filetypes = {
				gitcommit = true,
				DressingInput = true,
				text = true, -- `pass`' filetype when editing passwords
				["rip-substitute"] = true,
			},
			color = { suggestion_group = "NonText" }, -- PENDING https://github.com/supermaven-inc/supermaven-nvim/issues/49
			disable_inline_completion = false, -- disables cmp integration
		},
		config = function(_, opts)
			require("supermaven-nvim").setup(opts)

			-- PENDING https://github.com/supermaven-inc/supermaven-nvim/issues/49
			require("supermaven-nvim.completion_preview").suggestion_group = "NonText"

			-- disable while recording
			vim.api.nvim_create_autocmd("RecordingEnter", { command = "SupermavenStop" })
			vim.api.nvim_create_autocmd("RecordingLeave", { command = "SupermavenStart" })
		end,
	},
}
