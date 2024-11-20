-- INFO `colorschemeName` relevant for `theme-customization.lua`
--------------------------------------------------------------------------------
-- https://github.com/EdenEast/nightfox.nvim?tab=readme-ov-file#configuration
local lightTheme = {
	"EdenEast/nightfox.nvim",
	colorscheme = "dawnfox",
	opacity = 0.92,
	opts = {
		groups = {
			dawnfox = {
				["@keyword.return"] = { fg = "#9f2e69" },
				["@namespace.builtin.lua"] = { link = "@variable.builtin" }, -- `vim` and `hs`
				["@character.printf"] = { link = "SpecialChar" },
				["ColorColumn"] = { bg = "#e9dfd2" },
				["WinSeparator"] = { fg = "#cfc1b3" },
				["Operator"] = { fg = "#846a52" },

				-- FIX python highlighting issues
				["@type.builtin.python"] = { link = "Typedef" },
				["@string.documentation.python"] = { link = "Typedef" },
				["@keyword.operator.python"] = { link = "Operator" },
			},
		},
	},
	init = function(plugin)
		vim.api.nvim_create_autocmd({"ColorScheme", "VimEnter"}, {
			pattern = plugin.colorscheme,
			desc = "User: Some fixes for " .. plugin.colorscheme,
			callback = function()
				vim.defer_fn(function()
					if vim.g.colors_name ~= plugin.colorscheme then return end

					vim.api.nvim_set_hl(0, "@ibl.indent.char.1", { fg = "#e0cfbd" })
					local vimModes =
						{ "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
					for _, v in pairs(vimModes) do
						vim.cmd.highlight(("lualine_y_diff_modified_%s  guifg=#828208"):format(v))
						vim.cmd.highlight(("lualine_y_diff_added_%s  guifg=#477860"):format(v))
					end
				end, 300)
			end,
		})
	end,
}
-- 		vim.defer_fn(function() setHl("@ibl.indent.char.1", { fg = "#e0cfbd" }) end, 1)

--------------------------------------------------------------------------------

-- DOCS https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
local darkTheme = {
	"folke/tokyonight.nvim",
	colorscheme = "tokyonight-moon",
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
