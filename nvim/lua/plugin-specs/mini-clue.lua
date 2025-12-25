return {
	"nvim-mini/mini.clue",
	event = "VeryLazy",
	config = function()
		local miniclue = require("mini.clue")

		miniclue.setup {
			clues = {
				miniclue.gen_clues.builtin_completion(),
				miniclue.gen_clues.g(),
				miniclue.gen_clues.windows(),
				miniclue.gen_clues.z(),
			},

			triggers = {
				{ mode = "n", keys = "<Leader>" },
				{ mode = "x", keys = "<Leader>" },

				{ mode = "n", keys = "g" },
				{ mode = "x", keys = "g" },

				{ mode = "n", keys = "<C-w>" },

				{ mode = "n", keys = "z" },
				{ mode = "x", keys = "z" },
			},

			window = {
				config = {},
				delay = 400,
				scroll_down = "<PageDown>",
				scroll_up = "<PageUp>",
			},
		}
	end,
}
