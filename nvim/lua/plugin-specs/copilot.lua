-- DOCS https://github.com/zbirenbaum/copilot.lua#setup-and-configuration
--------------------------------------------------------------------------------

return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot", -- :Copilot auth
	event = "InsertEnter",
	keys = {
		{
			"<leader>oa",
			function() require("copilot.suggestion").toggle_auto_trigger() end,
			desc = " Toggle Copilot",
		},
	},
	opts = {
		panel = { enabled = false },
		suggestion = {
			auto_trigger = true, -- similar to neocodium this can
			hide_during_completion = true,
			keymap = { accept = "<D-s>", accept_line = "<D-S>", next = "<D-a>", prev = "<D-A>" },
		},
		root_dir = vim.uv.cwd,
		should_attach = function(bufnr, filepath)
			Chainsaw(filepath) -- 🪚
			if vim.fn.reg_recording() ~= "" then return false end -- not when recording
			if vim.bo[bufnr].buftype ~= "" then return false end

			local parent = vim.fs.dirname(filepath)
			local ignoreBuffer = parent:find("private dotfiles")
				or parent:find("leetcode") -- should do leetcode problems on my own
				or filepath:lower():find("recovery") -- e.g. password recovery
				or parent:find("/private/var/") -- path when editing in `pass` (2. extra safeguard)
				or filepath == ".env"
			return not ignoreBuffer
		end,
	},
}
