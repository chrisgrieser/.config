-- INFO `colorschemeName` relevant for `theme-customization.lua`
--------------------------------------------------------------------------------
-- https://github.com/EdenEast/nightfox.nvim?tab=readme-ov-file#configuration
local lightTheme = {
	"EdenEast/nightfox.nvim",
	colorschemeName = "dawnfox",
	opacity = 0.92,
	opts = {
		groups = {
			dayfox = {
				["@keyword.return"] = { fg = "#9f2e69", bold = true },
				["@namespace.builtin.lua"] = { link = "@variable.builtin" }, -- `vim` and `hs`
				["@markup.italic"] = { italic = true }, -- FIX
				["@character.printf"] = { link = "SpecialChar" },
			},
		},
	},
}

--------------------------------------------------------------------------------

-- DOCS https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
local darkTheme = {
	"folke/tokyonight.nvim",
	colorschemeName = "tokyonight-moon",
	opacity = 0.95,
	opts = {
		lualine_bold = true,
		on_highlights = function(hl, colors)
			hl["@ibl.indent.char.1"] = { fg = "#3b4261" }
			hl["@keyword.return"] = { fg = "#ff45ff", bold = true }
			hl["GitSignsChange"] = { fg = "#acaa62" }
			hl["diffChanged"] = { fg = "#e8e05e" }
			hl["GitSignsAdd"] = { fg = "#369a96" }
			hl["GitSignsAdd"] = { fg = "#369a96" }
			hl["Bold"] = { bold = true } -- FIX bold/italic being white in lazy.nvim window
			hl["Italic"] = { italic = true }
			hl["@markup.strong"] = { fg = colors.purple, bold = true }

			-- TODO INFO ERROR WARN
			for _, type in pairs { "todo", "error", "warning", "note" } do
				local name = "@comment." .. type
				hl[name] = { fg = "#000000", bg = hl[name].fg }
			end
		end,
	},
}

--------------------------------------------------------------------------------
darkTheme.priority = 1000 -- https://lazy.folke.io/spec/lazy_loading#-colorschemes
lightTheme.priority = 1000
return { lightTheme, darkTheme } -- order relevant for `theme-customization.lua`
