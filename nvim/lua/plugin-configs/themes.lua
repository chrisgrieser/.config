-- INFO `colorschemeName` relevant for `theme-customization.lua`
--------------------------------------------------------------------------------

-- DOCS
-- https://github.com/EdenEast/nightfox.nvim?tab=readme-ov-file#configuration
-- https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md
local lightTheme = {
	"EdenEast/nightfox.nvim",
	colorscheme = "dawnfox",
	opacity = 0.92,
	opts = {
		specs = {
			dawnfox = {
				-- add more contrast, especially for lualine
				git = { changed = "#b2770a", add = "#4a7e65" },
			},
		},
		groups = {
			dawnfox = {
				["IndentBlankPluginCustom"] = { fg = "#e0cfbd" },

				["@keyword.return"] = { fg = "#9f2e69", style = "bold" },
				["@namespace.builtin.lua"] = { link = "@variable.builtin" }, -- `vim` and `hs`
				["@character.printf"] = { link = "SpecialChar" },
				["ColorColumn"] = { bg = "#e9dfd2" },
				["WinSeparator"] = { fg = "#cfc1b3" },
				["Operator"] = { fg = "#846a52" },
				["@string.special.url.comment"] = { style = "underline" },

				-- markdown
				["@markup.raw"] = { bg = "#e9dfd2" }, -- for inline code in comments
				["@markup.link.label.markdown_inline"] = { fg = "palette.orange.dim" }, -- for md in notifications
				["@markup.strong"] = { fg = "palette.magenta", style = "bold" },

				-- python
				["@type.builtin.python"] = { link = "Typedef" },
				["@string.documentation.python"] = { link = "Typedef" },
				["@keyword.operator.python"] = { link = "Operator" },

				-- cursorword
				["LspReferenceWrite"] = { bg = "", style = "underdashed" },
				["LspReferenceRead"] = { bg = "", style = "underdotted" },
				["LspReferenceText"] = { bg = "" }, -- too much noise, as it underlines e.g. strings

				-- no undercurl
				["DiagnosticUnderlineHint"] = { style = "underline" },
				["DiagnosticUnderlineInfo"] = { style = "underline" },
				["DiagnosticUnderlineWarn"] = { style = "underline" },
				["DiagnosticUnderlineError"] = { style = "underline" },
				["SpellBad"] = { style = "underdotted" },
				["SpellCap"] = { style = "underdotted" },
				["SpellRare"] = { style = "underdotted" },

				-- add contrast to SnacksNotifier
				["SnacksNotifierIconDebug"] = { link = "Comment" },
				["SnacksNotifierTitleDebug"] = { link = "Comment" },
				["SnacksNotifierBorderDebug"] = { link = "Comment" },
				["SnacksNotifierFooterDebug"] = { link = "Comment" },
			},
		},
	},
}

--------------------------------------------------------------------------------

-- DOCS
-- https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
-- https://github.com/folke/tokyonight.nvim/blob/main/extras/lua/tokyonight_moon.lua
local darkTheme = {
	"folke/tokyonight.nvim",
	colorscheme = "tokyonight-moon",
	opacity = 0.93,
	opts = {
		lualine_bold = true,
		on_highlights = function(hl, colors)
			hl["IndentBlankPluginCustom"] = hl["IblIndent"]

			hl["@keyword.return"] = { fg = "#ff45ff", bold = true }
			hl["GitSignsChange"] = { fg = colors.yellow }
			hl["GitSignsAdd"] = { fg = colors.green2 }
			hl["Bold"] = { bold = true } -- FIX bold/italic being white in lazy.nvim window
			hl["Italic"] = { italic = true }
			hl["@markup.strong"] = { fg = colors.magenta, bold = true }

			-- cursorword
			hl["LspReferenceWrite"] = { underdashed = true }
			hl["LspReferenceRead"] = { underdotted = true }
			hl["LspReferenceText"] = {} -- too much noise, as it underlines e.g. strings

			-- color bg, not fg (TODO INFO ERROR WARN)
			hl["@comment.todo"] = { fg = "#000000", bg = hl["@comment.todo"].fg }
			hl["@comment.error"] = { fg = "#000000", bg = hl["@comment.error"].fg }
			hl["@comment.warning"] = { fg = "#000000", bg = hl["@comment.warning"].fg }
			hl["@comment.note"] = { fg = "#000000", bg = hl["@comment.note"].fg }

			-- no undercurl
			hl["DiagnosticUnderlineHint"] = { underline = true, sp = hl["DiagnosticUnderlineHint"].sp }
			hl["DiagnosticUnderlineInfo"] = { underline = true, sp = hl["DiagnosticUnderlineInfo"].sp }
			hl["DiagnosticUnderlineWarn"] = { underline = true, sp = hl["DiagnosticUnderlineWarn"].sp }
			hl["DiagnosticUnderlineError"] =
				{ underline = true, sp = hl["DiagnosticUnderlineError"].sp }
			hl["SpellBad"] = { underdotted = true, sp = hl["SpellBad"].sp }
			hl["SpellCap"] = { underdotted = true, sp = hl["SpellCap"].sp }
			hl["SpellRare"] = { underdotted = true, sp = hl["SpellRare"].sp }
		end,
	},
}

--------------------------------------------------------------------------------
darkTheme.priority = 1000 -- https://lazy.folke.io/spec/lazy_loading#-colorschemes
lightTheme.priority = 1000
return { lightTheme, darkTheme } -- order relevant for `theme-customization.lua`