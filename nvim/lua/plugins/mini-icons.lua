-- DOCS https://github.com/nvim-mini/mini.icons/blob/main/doc/mini-icons.txt
vim.pack.add { "https://github.com/nvim-mini/mini.icons" }
--------------------------------------------------------------------------------

-- BUG `hl = ""` needed when using vim.pack

require("mini.icons").setup {
	file = {
		["init.lua"] = { glyph = "󰢱", hl = "" }, -- disable nvim glyph: https://github.com/echasnovski/mini.nvim/issues/1384
		["README.md"] = { glyph = "", hl = "" },
		[".ignore"] = { glyph = "󰈉", hl = "MiniIconsGrey" },
		["pre-commit"] = { glyph = "󰊢", hl = "" },
		["Brewfile"] = { glyph = "󱄖", hl = "MiniIconsYellow" },
	},
	extension = {
		["d.ts"] = { hl = "MiniIconsGreen" }, -- distinguish `.d.ts` from `.ts`
		["applescript"] = { glyph = "󰀵", hl = "" },
		["log"] = { glyph = "󱂅", hl = "MiniIconsGrey" },
		["gitignore"] = { glyph = "", hl = "" },
		["adblock"] = { glyph = "", hl = "MiniIconsRed" },
		["scm"] = { hl = "MiniIconsRed" }, -- treesitter query files
		["add"] = { glyph = "", hl = "" }, -- vim spellfile
	},
	filetype = {
		["css"] = { glyph = "", hl = "MiniIconsRed" },
		["typescript"] = { hl = "MiniIconsCyan" },
		["vim"] = { glyph = "", hl = "" },
		["qf"] = { glyph = "", hl = "" },

		-- plugin-filetypes
		["leetcode.nvim"] = { glyph = "󱫩", hl = "" },
		["ccc-ui"] = { glyph = "", hl = "" },
		["scissors-snippet"] = { glyph = "󰩫", hl = "" },
		["rip-substitute"] = { glyph = "", hl = "" },
	},
}
