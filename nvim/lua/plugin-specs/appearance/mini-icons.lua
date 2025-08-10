---@module "lazy.types"
---@type LazyPluginSpec
return {
	"echasnovski/mini.icons",
	opts = {
		file = {
			["init.lua"] = { glyph = "󰢱" }, -- disable nvim glyph: https://github.com/echasnovski/mini.nvim/issues/1384
			["README.md"] = { glyph = "" },
			[".ignore"] = { glyph = "󰈉", hl = "MiniIconsGrey" },
			["pre-commit"] = { glyph = "󰊢" },
			["Brewfile"] = { glyph = "󱄖", hl = "MiniIconsYellow" },
		},
		extension = {
			["d.ts"] = { hl = "MiniIconsRed" }, -- distinguish `.d.ts` from `.ts`
			["applescript"] = { glyph = "󰀵", hl = "MiniIconsGrey" },
			["log"] = { glyph = "󱂅", hl = "MiniIconsGrey" },
			["gitignore"] = { glyph = "" },
			["adblock"] = { glyph = "", hl = "MiniIconsRed" },
		},
		filetype = {
			["css"] = { glyph = "", hl = "MiniIconsRed" },
			["typescript"] = { hl = "MiniIconsCyan" },
			["vim"] = { glyph = "" }, -- used for `obsidian-vimrc`

			-- plugin-filetypes
			["ccc-ui"] = { glyph = "" },
			["scissors-snippet"] = { glyph = "󰩫" },
			["rip-substitute"] = { glyph = "" },
			["Videre"] = { glyph = "󱁉" },
		},
	},
}
