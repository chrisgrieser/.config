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
				vim.notify(text, nil, { title = "Supermaven", icon = "󰚩" })
			end,
			desc = "󰚩 Supermaven",
		},
	},
	opts = {
		keymaps = {
			accept_suggestion = "<D-s>",
		},
		log_level = "off",
		ignore_filetypes = {
			"gitcommit",
			"gitrebase",
			"bib",

			-- INFO `pass` passwords editing filetype is plaintext, also this is
			-- the filetype of critical files (e.g. zsh files with API keys)
			"text",
		},
		condition = function()
			-- not when recording or in a special buffer
			if vim.fn.reg_recording() ~= "" then return false end
			if vim.bo.buftype ~= "" then return false end

			-- file based
			local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
			local name = vim.fs.basename(vim.api.nvim_buf_get_name(0))
			local ignoreBuffer = parent:find("private dotfiles")
				or name:lower():find("recovery")
				or name == ".env"
			return not ignoreBuffer -- `false` -> disable in that buffer
		end,
	},
}
