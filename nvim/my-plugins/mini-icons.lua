-- DOCS https://github.com/nvim-mini/mini.icons/blob/main/doc/mini-icons.txt
vim.pack.add { "https://github.com/nvim-mini/mini.icons" }
--------------------------------------------------------------------------------

require("mini.icons").setup {
	file = {
		["init.lua"] = { glyph = "󰢱" }, -- disable nvim glyph: https://github.com/echasnovski/mini.nvim/issues/1384
		["README.md"] = { glyph = "" },
		[".ignore"] = { glyph = "󰈉", hl = "MiniIconsGrey" },
		["pre-commit"] = { glyph = "󰊢" },
		["Brewfile"] = { glyph = "󱄖", hl = "MiniIconsYellow" },
	},
	extension = {
		["d.ts"] = { hl = "MiniIconsGreen" }, -- distinguish `.d.ts` from `.ts`
		["applescript"] = { glyph = "󰀵" },
		["log"] = { glyph = "󱂅", hl = "MiniIconsGrey" },
		["gitignore"] = { glyph = "" },
		["adblock"] = { glyph = "", hl = "MiniIconsRed" },
		["scm"] = { hl = "MiniIconsRed" }, -- treesitter query files
		["add"] = { glyph = "" }, -- vim spellfile
	},
	filetype = {
		["css"] = { glyph = "", hl = "MiniIconsRed" },
		["typescript"] = { hl = "MiniIconsCyan" },
		["vim"] = { glyph = "" },
		["qf"] = { glyph = "" },

		-- plugin-filetypes
		["leetcode.nvim"] = { glyph = "󰐱" },
		["ccc-ui"] = { glyph = "" },
		["scissors-snippet"] = { glyph = "󰩫" },
		["rip-substitute"] = { glyph = "" },
	},
}
