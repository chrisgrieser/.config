opt.termguicolors = false -- required for color previewing, but also messes up look in the terminal

local ccc = require("ccc")
ccc.setup({
	highlighter = { auto_enable = true },
	inputs = { ccc.input.hsl, ccc.input.rgb },
	outputs = { ccc.output.css_hsl, ccc.output.css_rgb },
	convert = {
		{ ccc.picker.hex, ccc.output.css_rgb },
		{ ccc.picker.css_rgb, ccc.output.css_hsl },
		{ ccc.picker.css_hsl, ccc.output.hex },
	}
})

keymap("n", "<leader>#", ":CccPick<CR>")
keymap("n", "g#", ":CccConvert<CR>")
