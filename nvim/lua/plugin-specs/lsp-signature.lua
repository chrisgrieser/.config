---@module "lazy.core.specs"
---@type LazyPluginSpec
return {
	"ray-x/lsp_signature.nvim",
	event = "InsertEnter",
	opts = {
		hint_prefix = "󰏪 ",
		hint_scheme = "Todo",
		floating_window = false,
		always_trigger = true,
	},
}
