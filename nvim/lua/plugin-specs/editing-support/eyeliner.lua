---@module "lazy.types"
---@type LazyPluginSpec
return {
	"jinh0/eyeliner.nvim",
	keys = { "f", "F", "t", "T" },
	opts = {
		highlight_on_key = true,
		dim = true,
		max_length = 500,
		disabled_buftypes = {},
	},
}
