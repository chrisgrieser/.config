return {
	"uga-rosa/ccc.nvim",
	cmd = { "CccPick", "CccConvert" },
	keys = {
		{ "#", vim.cmd.CccPick, desc = " Color Picker" },
		{ "g#", vim.cmd.CccConvert, desc = " Convert to hsl" },
	},
	ft = { "css", "zsh", "lua", "toml" },
	config = function(spec)
		local ccc = require("ccc")
		ccc.setup {
			win_opts = { border = vim.g.borderStyle },
			highlight_mode = "bg",
			highlighter = {
				auto_enable = true,
				filetypes = spec.ft, -- uses lazy.nvim's ft spec
			},
			pickers = { -- = what colors are highlighted
				ccc.picker.hex_long, -- only long hex to not pick issue numbers like #123
				ccc.picker.css_rgb,
				ccc.picker.css_hsl,
				ccc.picker.ansi_escape({
					black = "#767676",
					blue = "#3165ff",
				}, { meaning1 = "bright" }),
			},
			alpha_show = "hide", -- hide by default
			recognize = { output = true }, -- automatically recognize color format under cursor
			inputs = { ccc.input.hsl }, -- always use HSL-logic for input
			outputs = {
				ccc.output.css_hsl,
				ccc.output.css_rgb,
				ccc.output.hex,
			},
			convert = {
				{ ccc.picker.hex, ccc.output.css_hsl },
				{ ccc.picker.css_rgb, ccc.output.css_hsl },
				{ ccc.picker.css_hsl, ccc.output.hex },
			},
			disable_default_mappings = true,
			mappings = {
				["<CR>"] = ccc.mapping.complete,
				["<Esc>"] = ccc.mapping.quit,
				["q"] = ccc.mapping.quit,
				["l"] = ccc.mapping.increase1,
				["h"] = ccc.mapping.decrease1,
				["L"] = ccc.mapping.increase10,
				["H"] = ccc.mapping.decrease10,
				["o"] = ccc.mapping.cycle_output_mode,
				["a"] = ccc.mapping.toggle_alpha,
			},
		}
	end,
}
