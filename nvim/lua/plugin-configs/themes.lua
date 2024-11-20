-- INFO `colorschemeName` relevant for `theme-customization.lua`
--------------------------------------------------------------------------------

local lightTheme = {
	"EdenEast/nightfox.nvim",
	colorschemeName = "dawnfox",
}
-- { "uloco/bluloco.nvim", dependencies = { "rktjmp/lush.nvim" } },

--------------------------------------------------------------------------------

-- DOCS https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
local darkTheme = {
	"folke/tokyonight.nvim",
	colorschemeName = "tokyonight-moon",
	opts = {
		lualine_bold = true,
		on_highlights = function(hl, _)
			hl["@ibl.indent.char.1"] = { fg = "#3b4261" }
			hl["@keyword.return"] = { fg = "#ff45ff", bold = true }
			hl["GitSignsChange"] = { fg = "#acaa62" }
			hl["diffChanged"] = { fg = "#e8e05e" }
			hl["GitSignsAdd"] = { fg = "#369a96" }

		-- 	-- FIX
		-- -- bold and italic having white color, notably the lazy.nvim window
		-- setHl("Bold", { bold = true })
		-- setHl("Italic", { italic = true })
		-- -- broken when switching themes
		-- setHl("TelescopeSelection", { link = "Visual" })
		-- -- FIX for blink cmp highlight
		-- setHl("BlinkCmpKind", { link = "Special" })
		end,
	},
}
-- "fynnfluegge/monet.nvim",
-- { "binhtran432k/dracula.nvim", opts = { lualine_bold = true } },

--------------------------------------------------------------------------------
darkTheme.priority = 1000 -- https://lazy.folke.io/spec/lazy_loading#-colorschemes
lightTheme.priority = 1000
return { lightTheme, darkTheme } -- order relevant for `theme-customization.lua`
