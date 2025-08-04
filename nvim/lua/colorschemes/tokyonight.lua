-- config: https://github.com/folke/tokyonight.nvim#%EF%B8%8F-configuration
-- palette: https://github.com/folke/tokyonight.nvim/blob/main/extras/lua/tokyonight_moon.lua
--------------------------------------------------------------------------------

return {
	"folke/tokyonight.nvim",
	priority = 1000,
	opts = {
		style = "moon",
		styles = {
			comments = { italic = false },
		},
		lualine_bold = true,
		on_colors = function(colors)
			colors.git.change = colors.yellow -- yellow, not blue
			colors.git.add = colors.green2 -- prettier green
			colors.comment = "#767fb1" -- bit more contrast (original: #636da6)
		end,
		on_highlights = function(hl, colors)
			-- general
			hl["@keyword"].italic = false
			hl.Comment.italic = false
			hl.StandingOut = { fg = colors.magenta2, bold = true }
			hl["@keyword.return"] = { link = "StandingOut" }
			hl["@markup.strong"] = { fg = colors.fg_dark, bold = true }
			hl["@string.documentation.python"] = { link = "Comment" }
			hl.LspSignatureActiveParameter = { link = "Visual" }
			hl.Added = { fg = colors.green2 }
			hl.Removed = { fg = colors.red }
			hl.Bold = { bold = true } -- FIX missing color in lazy.nvim window
			hl.Italic = { italic = true } -- FIX missing color in lazy.nvim window

			-- Snacks
			hl.SnacksPickerMatch = { fg = colors.yellow } -- make matches stand out more
			hl.SnacksPickerGitStatusModified = { fg = colors.blue2 } -- differentiate from match color

			-- blink.cmp
			hl.BlinkCmpKindFile = { link = "LspKindText" } -- FIX wrong bg for icons with source `path`
			hl.BlinkCmpLabelDetail = { link = "Comment" } -- FIX wrong color
			hl.BlinkCmpLabelDescription = { link = "NonText" } -- FIX wrong color
			hl.BlinkCmpLabelMatch = { fg = colors.yellow } -- make matches stand out more

			-- apply color to `bg`, not `fg` (TODO INFO ERROR WARN)
			hl["@comment.todo"] = { fg = colors.black, bg = hl["@comment.todo"].fg }
			hl["@comment.error"] = { fg = colors.black, bg = hl["@comment.error"].fg }
			hl["@comment.warning"] = { fg = colors.black, bg = hl["@comment.warning"].fg }
			hl["@comment.note"] = { fg = colors.black, bg = hl["@comment.note"].fg }

			-- mini.icons
			hl.MiniIconsGreen = { fg = "#86f080" }
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
