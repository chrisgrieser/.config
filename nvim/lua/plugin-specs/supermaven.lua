return {
	"supermaven-inc/supermaven-nvim",
	build = ":SupermavenUseFree", -- needs to be run once to set the API key
	event = "InsertEnter",
	keys = {
		{ "<D-s>", mode = "i", desc = "󰚩 Accept Suggestion" },
		{ "<leader>oa", vim.cmd.SupermavenToggle, desc = "󰚩 AI completion" },
	},
	config = function(_, opts)
		require("supermaven-nvim").setup(opts)

		vim.api.nvim_create_autocmd("RecordingEnter", { command = "SupermavenStop" })
		vim.api.nvim_create_autocmd("RecordingLeave", { command = "SupermavenStart" })

		-- PENDING https://github.com/supermaven-inc/supermaven-nvim/issues/49
		require("supermaven-nvim.completion_preview").suggestion_group = "NonText"

		vim.g.lualineAdd(
			"sections",
			"lualine_x",
			function() return require("supermaven-nvim.api").is_running() and "" or "󱚧 " end
		)
	end,
	opts = {
		keymaps = {
			accept_suggestion = "<D-s>",
		},
		log_level = "off",
		ignore_filetypes = {
			"snacks_picker_input",
			"snacks_input",
			"gitcommit",
			"gitrebase",
			"bib",

			-- INFO `pass` passwords editing filetype is plaintext, also this is
			-- the filetype of critical files (e.g. zsh files with API keys)
			"text",
		},
		-- BUG once false, permanently shuts down supermaven https://github.com/supermaven-inc/supermaven-nvim/pull/130
		-- condition = function()
		-- 	if vim.bo.buftype ~= "" then return false end
		-- 	local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
		-- 	local name = vim.fs.basename(vim.api.nvim_buf_get_name(0))
		-- 	local ignoreBuffer = parent:find("private dotfiles")
		-- 		or name:lower():find("recovery")
		-- 		or name == ".env"
		-- 	return not ignoreBuffer -- `false` -> disable in that buffer
		-- end,
	},
}
