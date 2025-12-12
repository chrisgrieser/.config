-- DOCS https://github.com/zbirenbaum/copilot.lua#setup-and-configuration
-- Usage: https://github.com/settings/copilot/features
--------------------------------------------------------------------------------

return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot", -- :Copilot auth
	event = "InsertEnter",
	enabled = false,
	keys = {
		{
			"<leader>oa",
			function() require("copilot.suggestion").toggle_auto_trigger() end,
			desc = " Toggle Copilot",
		},
	},
	opts = {
		filetypes = {
			text = false, -- extra safety net
			bib = false,
		},
		server_opts_overrides = {
			settings = {
				advanced = { inlineSuggestCount = 1 }, -- fetch only 1 completion
			},
		},
		panel = { enabled = false },
		suggestion = {
			auto_trigger = true, -- similar to neocodium this can
			hide_during_completion = true,
			keymap = { accept = "<D-s>", accept_line = "<D-S>", next = "<D-a>", prev = "<D-A>" },
		},
		root_dir = vim.uv.cwd,
		should_attach = require("config.utils").ignoreBuffer,
	},
}
