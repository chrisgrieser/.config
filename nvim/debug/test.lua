---@module 'blink.cmp'
---@type blink.cmp.Config
local opts = {
	sources = {
		providers = {
			snippets = {
				min_keyword_length = 1,
				score_offset = -1,
			},
			buffer = {
				fallback_for = {},
				max_items = 4,
				min_keyword_length = 4,
				score_offset = -3,
			},
		},
	},
	windows = {
		autocomplete = {
			draw = {
				columns = {
					{ "label", "label_description", "kind_icon" },
				},
				components = {
					label = {
						width = { max = 35 },
					},
					kind_icon = {
						text = function(ctx) return ctx.kind_icon end,
					},
				},
			},
		},
	},
}

