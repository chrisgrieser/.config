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

			-- plugins
			["oil"] = { glyph = "󰁴" },
			["snacks_input"] = { glyph = "󰏫" },
			["snacks_notif"] = { glyph = "󰎟" },
			["noice"] = { glyph = "󰎟" },
			["mason"] = { glyph = "" },
			["ccc-ui"] = { glyph = "" },
			["scissors-snippet"] = { glyph = "󰩫" },
			["rip-substitute"] = { glyph = "" },
		},
	},
	config = function(_, opts)
		require("mini.icons").setup(opts)

		-- plugin still needing the mock: telescope & lualine
		require("mini.icons").mock_nvim_web_devicons()
	end,
}
