-- DOCS https://github.com/obsidian-nvim/obsidian.nvim/blob/main/lua/obsidian/config/default.lua
--------------------------------------------------------------------------------

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	ft = "markdown",
	opts = {
		ui = { enable = false }, -- using `render-markdown`
		legacy_commands = false, -- this will be removed in the next major release
		preferred_link_style = "wiki",
		completion = {
			min_chars = 1,
			match_case = false,
			create_new = false,
		},
		workspaces = {
			{ name = "Notes", path = vim.g.notesDir },
		},
		footer = {
			format = "{{backlinks}} backlinks",
			separator = string.rep("─", vim.o.textwidth),
		},
		callbacks = {
			enter_note = function(note) vim.keymap.del("n", "<CR>", { buffer = note.bufnr }) end,
		},
	},
}
