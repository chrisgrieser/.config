return {
	"akinsho/git-conflict.nvim",
	event = "VeryLazy",
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "GitConflictDetected",
			callback = function(ctx)
				vim.notify(ctx.file, nil, { title = "Merge conflict", icon = "" })
				vim.g.whichkeyAddSpec { "<leader>m", group = " Merge conflict" }
			end,
		})
	end,
	opts = {
		default_mappings = {
			ours = "<leader>mo",
			theirs = "<leader>mt",
			none = "<leader>mn",
			both = "<leader>mn",
			next = "gc",
			prev = "gC",
		},
		default_commands = false,
		disable_diagnostics = true,

		-- must have background color, otherwise the default color will be used
		highlights = { incoming = "DiffAdd", current = "DiffText" },
	},
}
