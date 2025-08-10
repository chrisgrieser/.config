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
		side_scrolloff = math.floor(vim.o.columns / 3),
		keymap_desc_deliminator = ": ",
		space_char = " ",
		keymaps = {
			expand = "<Space>",
			collapse = "<Space>",
			link_forward = "o", -- jump to linked unit
			link_backward = "i", -- jump back to unit's parent
			set_as_root = "r",
		},
	},
}
