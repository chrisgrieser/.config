---@module "lazy.types"
---@type LazyPluginSpec
return {
	"Isrothy/neominimap.nvim",
	event = "VeryLazy",
	keys = {
		{ "<leader>om", "<cmd>Neominimap Toggle<cr>", desc = "󰍍 Toggle global minimap" },
	},
	init = function()
		---@module "neominimap"
		---@type Neominimap.UserConfig
		vim.g.neominimap = {
			layout = "split",
		}
	end,
}
