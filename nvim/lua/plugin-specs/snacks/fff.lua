---@module "lazy.types"
---@type LazyPluginSpec
return {
	"dmtrKovalenko/fff.nvim",
	build = function() require("fff.download").download_or_build_binary() end,
	opts = {},
	lazy = false,
	keys = {
		{ "gO", function() require("fff").find_files() end, desc = "FFFind files" },
	},
}
