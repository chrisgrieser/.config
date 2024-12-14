return { 
	"echasnovski/mini.icons",
	opts = {
		file = {
			["init.lua"] = { glyph = "󰢱" }, -- disable nvim glyph: https://github.com/echasnovski/mini.nvim/issues/1384
			["README.md"] = { glyph = "" },
			[".ignore"] = { glyph = "󰈉", hl = "MiniIconsGrey" },
			["pre-commit"] = { glyph = "󰊢" },
		},
		extension = {
			["d.ts"] = { hl = "MiniIconsRed" }, -- distinguish `.d.ts` from `.ts`
			["applescript"] = { glyph = "󰀵", hl = "MiniIconsGrey" },
			["log"] = { glyph = "󱂅", hl = "MiniIconsGrey" },
			["gitignore"] = { glyph = "" },
		},
		filetype = {
			["css"] = { glyph = "", hl = "MiniIconsRed" },
			["typescript"] = { hl = "MiniIconsCyan" },
			["vim"] = { glyph = "" }, -- used for `obsidian.vimrc`
		},
	},
	config = function(_, opts)
		require("mini.icons").setup(opts)
		require("mini.icons").mock_nvim_web_devicons()
	end,
}

