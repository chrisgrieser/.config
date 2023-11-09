return {
	{ -- better embedded terminal
		"akinsho/toggleterm.nvim",
		opts = {
			size = 11,
			direction = "horizontal",
			autochdir = true, -- when nvim changes pwd, will also change its pwd
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "toggleterm",
				callback = function()
					vim.opt_local.scrolloff = 0
					vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, nowait = true })
				end,
			})
		end,
		keys = {
			{ "<leader>t", vim.cmd.ToggleTerm, desc = " ToggleTerm" },
			{ "<leader>z", vim.cmd.ToggleTermSendCurrentLine, desc = " ToggleTerm: Send Line" },
			{ "<leader>z", vim.cmd.ToggleTermSendVisualSelection, mode = "x", desc = " ToggleTerm: Send Sel" },
		},
	},
}
