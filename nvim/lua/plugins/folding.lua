return {
	{
		"jghauser/fold-cycle.nvim",
		lazy = true, -- loaded by keymap
		opts = true,
	},
	{
		"anuvyklack/pretty-fold.nvim",
		event = "UIEnter",
		opts = {
			process_comment_signs = false,
			keep_indentation = true,
			fill_char = " ",
			sections = {
				-- stylua: ignore
				left = { "content" },
				right = { " ", "number_of_folded_lines", "        " },
			},
		},
	},
}
