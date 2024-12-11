return { -- icon library
	"echasnovski/mini.icons",
	opts = {
		file = {
			["init.lua"] = { glyph = "󰢱" }, -- disable nvim glyph: https://github.com/echasnovski/mini.nvim/issues/1384
			["README.md"] = { glyph = "" },
			[".ignore"] = { glyph = "󰈉", hl = "MiniIconsGrey" },
			["pre-commit"] = { glyph = "󰊢" },

			-- frequently accessed plugin spec files
			["blink-cmp.lua"] = { glyph = "󰢱 󰩫" },
			["colorschemes.lua"] = { glyph = "󰢱 " },
			["gitsigns.lua"] = { glyph = "󰢱 󰊢" },
			["lualine.lua"] = { glyph = "󰢱 ▭" },
			["mason.lua"] = { glyph = "󰢱 " },
			["mini-icons.lua"] = { glyph = "󰢱 " },
			["various-textobjs.lua"] = { glyph = "󰢱 󱡔" },
			["treesitter-textobjects.lua"] = { glyph = "󰢱 󱡔" },
			["noice.lua"] = { glyph = "󰢱 󰎟" },
			["scissors.lua"] = { glyph = "󰢱 󰩫" },
			["snacks.lua"] = { glyph = "󰢱 󰉚" },
			["telescope.lua"] = { glyph = "󰢱 󰭎" },
			["tinygit.lua"] = { glyph = "󰢱 󰊢" },
			["which-key.lua"] = { glyph = "󰢱 ⌨️" },
		},
		extension = {
			["d.ts"] = { hl = "MiniIconsRed" }, -- distinguish `.d.ts` from `.ts`
			["applescript"] = { glyph = "󰀵", hl = "MiniIconsGrey" },
		},
		filetype = {
			["css"] = { hl = "MiniIconsRed" },
			["typescript"] = { hl = "MiniIconsCyan" },
			["vim"] = { glyph = "" }, -- used for `obsidian.vimrc`
		},
	},
	config = function(_, opts)
		require("mini.icons").setup(opts)
		require("mini.icons").mock_nvim_web_devicons()
	end,
}

