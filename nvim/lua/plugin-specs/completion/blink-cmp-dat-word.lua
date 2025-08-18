---@module "lazy.types"
---@type LazyPluginSpec
return {
	"saghen/blink.cmp",
	dependencies = { "xieyonn/blink-cmp-dat-word" },
	opts = {
		sources = {
			providers = {
				datword = {
					name = "DatWord",
					module = "blink-cmp-dat-word",
					opts = {
						paths = { "/usr/share/dict/words" }, -- included by default on Linux/macOS
					},
					max_items = 10,
					score_offset = -10,
					min_keyword_length = 7,
				},
			},
		},
	},
}
