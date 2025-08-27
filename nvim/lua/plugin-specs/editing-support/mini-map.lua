-- DOCS https://github.com/echasnovski/mini.map?tab=readme-ov-file#default-config
--------------------------------------------------------------------------------

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"echasnovski/mini.map",
	event = "VeryLazy",
	keys = {
		{ "<leader>om", function() require("mini.map").toggle() end, desc = "󰨁 Mini map" },
	},
	config = function()
		local minimap = require("mini.map")
		minimap.setup {
			window = {
				width = 15,
				winblend = 10,
				show_integration_count = false,
			},
			symbols = {
				encode = minimap.gen_encode_symbols.dot("4x2"),
				scroll_line = "", -- disable
			},
			integrations = {
				minimap.gen_integration.builtin_search(),
				minimap.gen_integration.gitsigns(),
				minimap.gen_integration.diagnostic(),
			},
		}
		minimap.open() -- auto-open on load
	end,
}
