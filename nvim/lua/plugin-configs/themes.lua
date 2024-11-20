-- INFO `colorschemeName` relevant for `theme-customization.lua`
--------------------------------------------------------------------------------

-- DOCS https://github.com/EdenEast/nightfox.nvim?tab=readme-ov-file#configuration
-- https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md
local lightTheme = {
	"EdenEast/nightfox.nvim",
	colorscheme = "dawnfox",
	opacity = 0.92,
	opts = {
		groups = {
			dawnfox = {
				["@keyword.return"] = { fg = "#9f2e69", style = "bold" },
				["@namespace.builtin.lua"] = { link = "@variable.builtin" }, -- `vim` and `hs`
				["@character.printf"] = { link = "SpecialChar" },
				["ColorColumn"] = { bg = "#e9dfd2" },
				["WinSeparator"] = { fg = "#cfc1b3" },
				["Operator"] = { fg = "#846a52" },
				["@markup.raw"] = { bg = "#e9dfd2" }, -- for inline code in comments
				["@string.special.url.comment"] = { style = "underline" },

				-- FIX python highlighting issues `fffff`
				["@type.builtin.python"] = { link = "Typedef" },
				["@string.documentation.python"] = { link = "Typedef" },
				["@keyword.operator.python"] = { link = "Operator" },
			},
		},
	},
	init = function(plugin)
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			pattern = plugin.colorscheme,
			desc = "User: Changes for " .. plugin.colorscheme,
			callback = function()
				vim.defer_fn(function()
					if vim.g.colors_name ~= plugin.colorscheme then return end

					-- fix indent-blank-line color
					vim.api.nvim_set_hl(0, "@ibl.indent.char.1", { fg = "#e0cfbd" })

					-- fixes contrast issues in lualine
					local vimModes =
						{ "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
					for _, v in pairs(vimModes) do
						vim.cmd.highlight(("lualine_y_diff_modified_%s guifg=#828208"):format(v))
						vim.cmd.highlight(("lualine_y_diff_added_%s guifg=#477860"):format(v))
					end
				end, 350)
			end,
		})
	end,
}

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
			hl["@markup.strong"] = { fg = colors.magenta, bold = true }

			-- TODO INFO ERROR WARN
			hl["@comment.todo"] = { fg = "#000000", bg = hl["@comment.todo"].fg }
			hl["@comment.error"] = { fg = "#000000", bg = hl["@comment.error"].fg }
			hl["@comment.warning"] = { fg = "#000000", bg = hl["@comment.warning"].fg }
			hl["@comment.note"] = { fg = "#000000", bg = hl["@comment.note"].fg }

			hl["DiagnosticUnderlineError"] = { underline = true, sp = hl["DiagnosticUnderlineError"].sp }
			hl["DiagnosticUnderlineWarn"] = { underline = true, sp = hl["DiagnosticUnderlineWarn"].sp }
			hl["DiagnosticUnderlineInfo"] = { underline = true, sp = hl["DiagnosticUnderlineInfo"].sp }
			hl["DiagnosticUnderlineHint"] = { underline = true, sp = hl["DiagnosticUnderlineHint"].sp }
		end,
	},
}

--------------------------------------------------------------------------------
darkTheme.priority = 1000 -- https://lazy.folke.io/spec/lazy_loading#-colorschemes
lightTheme.priority = 1000
return { lightTheme, darkTheme } -- order relevant for `theme-customization.lua`
