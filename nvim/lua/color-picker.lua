require("utils")
local ccc = require("ccc")
--------------------------------------------------------------------------------
opt.termguicolors = true -- required for color previewing, but also messes up look in the terminal

ccc.setup {
	win_opts = {border = borderStyle},
	highlighter = {
		auto_enable = true,
		max_byte = 2 * 1024 * 1024, -- 2mb
		lsp = true,
		excludes = {
			"packer",
		}
	},
	alpha_show = "hide", -- needed when highlighter.lsp is set to true
	recognize = {output = true}, -- automatically recognize color format under cursor
	inputs = {ccc.input.hsl},
	outputs = {
		ccc.output.css_hsl,
		ccc.output.css_rgb,
		ccc.output.hex,
	},
	convert = {
		{ccc.picker.hex, ccc.output.css_hsl},
		{ccc.picker.css_rgb, ccc.output.css_hsl},
		{ccc.picker.css_hsl, ccc.output.hex},
	},
	mappings = {
		["<Esc>"] = ccc.mapping.quit,
		["q"] = ccc.mapping.quit,
		L = ccc.mapping.increase5,
		H = ccc.mapping.decrease5,
	},
}

keymap("n", "#", ":CccPick<CR>")
keymap("n", "'", ":CccConvert<CR>") -- shift-# on German keyboard
keymap("i", "<C-#>", "<Plug>(ccc-insert)")
