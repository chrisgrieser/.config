return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	ft = "markdown",
	opts = {
		legacy_commands = false, -- this will be removed in the next major release
		preferred_link_style = "markdown",
		workspaces = {
			{ name = "Notes", path = vim.g.notesDir },
		},
		frontmatter = {
			sort = { "aliases" },
		},
		footer = {
			format = "{{backlinks}} backlinks",
		},
		callbacks = {
			enter_note = function(note)
				vim.keymap.del("n", "<CR>", bu)
				vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<cr>", {
					buffer = true,
					desc = "Toggle checkbox",
				})
			end,
		},
	},
}
