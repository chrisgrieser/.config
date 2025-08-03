-- loads highlights either when enabled via `#`, or when `CccPick` is called manually
return {
	"uga-rosa/ccc.nvim",
	cmd = { "CccPick", "CccConvert" },
	ft = { "css", "zsh" },
	keys = {
		{
			"#",
			function()
				-- enable color highlights, then override to activate picker
				vim.cmd.CccHighlighterEnable()
				vim.notify("Highlights enabled.", nil, { title = "ccc.nvim", icon = "" })
			end,
			desc = " Enable color highlights",
		},
		{ "<leader>r#", vim.cmd.CccConvert, desc = " Convert to hsl" },
	},
	config = function()
		-- override key
		-- vim.keymap.set("n", "#", vim.cmd.CccPick, { desc = " Color picker" })
		-- high_color="0xffc95050" # red #c95050
		local ccc = require("ccc")
		ccc.setup {
			point_char = "󰣏",
			win_opts = {
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
			},
			highlight_mode = "bg",
			highlighter = {
				auto_enable = true,
				filetypes = { "css", "zsh", "lua", "toml" },
			},
			pickers = { -- = what colors are highlighted
				ccc.picker.hex_long, -- only long hex to not pick up issue numbers like `#123`
				ccc.picker.css_rgb,
				ccc.picker.css_hsl,
				ccc.picker.ansi_escape(
					{ black = "#767676", blue = "#3165ff" },
					{ meaning1 = "bright" }
				),
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
