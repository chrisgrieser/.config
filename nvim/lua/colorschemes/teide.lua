-- config: https://github.com/serhez/teide.nvim#%EF%B8%8F-configuration
-- palette: https://github.com/serhez/teide.nvim/blob/main/extras/lua/teide_dimmed.lua
--------------------------------------------------------------------------------

return {
	"serhez/teide.nvim",
	priority = 1000,
	lazy = false,
	config = function(_, opts)
		require("teide").setup(opts)
		vim.cmd.colorscheme("teide")
	end,
	-----------------------------------------------------------------------------
	opts = {
		style = "dimmed", -- "dimmed"|""dark"|"darker"
		lualine_bold = true,
		light_brightness = 0.3, -- for light theme
		dim_inactive = false, -- BUG does not dim signcolumn properly
		styles = {
			comments = { italic = false },
		},
		--------------------------------------------------------------------------
		on_colors = function(colors)
			colors.git.change = colors.yellow -- yellow, not blue
			colors.comment = "#767fb1" -- more contrast
		end,
		on_highlights = function(hl, colors)
			-- custom highlights
			hl.StandingOut = { fg = colors.magenta2, bold = true }
			hl["@keyword.return"] = { link = "StandingOut" }
			hl["@markdown.internal_link"] = {
				fg = colors.magenta,
				sp = colors.magenta, -- underline color of spaces
				underline = true,
			}

			-- general
			hl["@lsp.type.parameter"] = { fg = colors.yellow }
			hl["@markup.strong"] = { fg = colors.fg_dark, bold = true }
			hl["@string.documentation.python"] = { link = "Comment" }
			hl.LspSignatureActiveParameter = { link = "Visual" }
			hl.Added = { fg = colors.green2 }
			hl.Removed = { fg = colors.red }
			hl.Bold = { bold = true } -- FIX missing color in lazy.nvim window
			hl.Italic = { italic = true } -- FIX missing color in lazy.nvim window
			hl.LspCodeLens = { link = "LspInlayHint" }

			-- Snacks
			hl.SnacksPickerMatch = { fg = colors.magenta } -- make matches stand out more

			-- blink.cmp
			hl.BlinkCmpKindFile = { link = "LspKindText" } -- FIX wrong bg for icons with source `path`
			hl.BlinkCmpLabelDetail = { link = "Comment" } -- FIX wrong color
			hl.BlinkCmpLabelDescription = { link = "NonText" } -- FIX wrong color
			hl.BlinkCmpLabelMatch = { fg = colors.yellow } -- make matches stand out more

			-- mini.icons
			hl.MiniIconsGrey = { fg = colors.fg_dark }

			-- cursorword
			hl.LspReferenceWrite = { underdashed = true }
			hl.LspReferenceRead = { underdotted = true }
			hl.LspReferenceText = {} -- too much noise, as it underlines e.g. strings

			-- no undercurl
			hl.DiagnosticUnderlineHint = { underline = true, sp = hl.DiagnosticUnderlineHint.sp }
			hl.DiagnosticUnderlineInfo = { underline = true, sp = hl.DiagnosticUnderlineInfo.sp }
			hl.DiagnosticUnderlineWarn = { underline = true, sp = hl.DiagnosticUnderlineWarn.sp }
			hl.DiagnosticUnderlineError = { underline = true, sp = hl.DiagnosticUnderlineError.sp }
			hl.SpellBad = { underdotted = true, sp = hl.SpellBad.sp }
			hl.SpellCap = { underdotted = true, sp = hl.SpellCap.sp }
			hl.SpellRare = { underdotted = true, sp = hl.SpellRare.sp }
			hl.SpellLocal = { underdotted = true, sp = hl.SpellLocal.sp }
		end,
	},
}
