return {
	"supermaven-inc/supermaven-nvim",
	build = ":SupermavenUseFree", -- needs to be run once to set the API key
	event = "InsertEnter",
	keys = {
		{ "<D-s>", mode = "i", desc = "󰚩 Accept Suggestion" },
		{
			"<leader>oa",
			function()
				vim.cmd.SupermavenToggle()
				local text = require("supermaven-nvim.api").is_running() and "enabled" or "disabled"
				require("config.utils").notify("󰚩 Supermaven", text)
			end,
			desc = "󰚩 Supermaven",
		},
	},
	opts = {
		keymaps = {
			accept_suggestion = "<D-s>",
		},
		log_level = "off", -- silence notifications
		ignore_filetypes = {
			gitcommit = true,
			gitrebase = true,
			snacks_input = true,
			snacks_picker_input = true,
			snacks_notif = true,
			["rip-substitute"] = true,

			-- INFO `pass` passwords editing filetype is plaintext, also this is
			-- the filetype of critical files (e.g. zsh files with API keys)
			text = true,
		},
	},
	config = function(_, opts)
		require("supermaven-nvim").setup(opts)

		-- disable while recording
		vim.api.nvim_create_autocmd("RecordingEnter", { command = "SupermavenStop" })
		vim.api.nvim_create_autocmd("RecordingLeave", { command = "SupermavenStart" })
	end,
}
