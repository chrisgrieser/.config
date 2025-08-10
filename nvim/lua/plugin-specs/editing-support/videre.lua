-- DOCS https://github.com/Owen-Dechow/videre.nvim#-options
--------------------------------------------------------------------------------

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"Owen-Dechow/videre.nvim",
	cmd = "Videre",
	keys = {
		{ "<leader>eg", vim.cmd.Videre, ft = "json", desc = " Explore Graph (Videre)" },
	},
	opts = {
		editor_type = "floating", -- split|floating
		floating_editor_style = { margin = 1, border = vim.o.winborder },
		max_lines = 10, -- array length before collapsing
		round_units = true,
		round_connections = true,
		disable_line_wrap = false,
		side_scrolloff = math.floor(vim.o.columns / 3),

		keymap_desc_deliminator = ": ",
		space_char = "·",
		keymap_priorities = {
			expand = 4,
			link_forward = 3,
			link_backward = 3,
			collapse = 2,
			set_as_root = 1,
		},
		keymaps = {
			expand = "<Space>",
			collapse = "<Space>",
			link_forward = "o", -- Jump to linked unit
			link_backward = "i", -- Jump back to unit parent
			set_as_root = "r",
		},
	},
}
