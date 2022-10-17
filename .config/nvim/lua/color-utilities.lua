opt.termguicolors = true -- required for color previewing, but also messes up look in the terminal

local ccc = require("ccc")

ccc.setup{
	win_opts	= { border = borderStyle },
	highlighter = {
		auto_enable = true,
		excludes = {"packer"},
	},
	inputs = { ccc.input.hsl },
	-- outputs = { ccc.output.css_hsl, ccc.output.css_rgb, ccc.output.hex },
	convert = {
		{ ccc.picker.hex, ccc.output.css_hsl },
		{ ccc.picker.css_rgb, ccc.output.css_hsl },
		{ ccc.picker.css_hsl, ccc.output.hex },
	},
	mappings = {
		["<Esc>"] = ccc.mapping.quit,
		L = ccc.mapping.increase5,
		H = ccc.mapping.decrease5,
	},
}

keymap("n", "<leader>#", ":CccPick<CR>")
keymap("n", "g#", ":CccConvert<CR>")
keymap("i", "<C-#>", "<Plug>(ccc-insert)")
