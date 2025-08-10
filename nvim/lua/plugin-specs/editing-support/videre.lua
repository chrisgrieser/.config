-- DOCS https://github.com/Owen-Dechow/videre.nvim#-options
--------------------------------------------------------------------------------

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"Owen-Dechow/videre.nvim",
	cmd = "Videre",
	keys = {
		{ "<leader>ij", vim.cmd.Videre, ft = "json", desc = " Explore JSON" },
	},
	opts = {
		editor_type = "floating", -- split|floating
		floating_editor_style = { margin = 2, border = vim.o.winborder, zindex = 10 },
		max_lines = 10, -- array length before collapsing
		round_units = true,
		round_connections = false,
		disable_line_wrap = false,
		side_scrolloff = 20,

		keymap_desc_deliminator = "=",
		keymap_priorities = {
			expand = 4,
			link_forward = 3,
			link_backward = 3,
			collapse = 2,
			set_as_root = 1,
		},
		keymaps = {
			expand = "E",
			collapse = "E",
			link_forward = "L", -- Jump to linked unit
			link_backward = "H", -- Jump back to unit parent
			set_as_root = "R",
		},
	},
}
