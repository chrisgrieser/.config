--# selene: allow(mixed_table) -- lazy.nvim uses them
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
					-- stylua: ignore
					vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, nowait = true, desc = "Quit" })
				end,
			})
		end,
		keys = {
			{ "<leader>t", vim.cmd.ToggleTerm, desc = " ToggleTerm" },
			{ "<leader>T", vim.cmd.ToggleTermSendCurrentLine, desc = " ToggleTerm: Send Line" },
			{
				"<leader>T",
				vim.cmd.ToggleTermSendVisualSelection,
				mode = "x",
				desc = "  ToggleTerm: Send Sel",
			},
		},
	},
}
