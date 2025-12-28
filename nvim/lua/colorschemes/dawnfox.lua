-- config: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md
-- palette: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md#palette
--------------------------------------------------------------------------------

return {
	"EdenEast/nightfox.nvim",
	priority = 1000,
	lazy = false,
	config = function(_, opts)
		require("nightfox").setup(opts)
		vim.cmd.colorscheme("dawnfox")
	end,
	-----------------------------------------------------------------------------
	opts = {
		options = { dim_inactive = false },
		specs = {
			dawnfox = {
				-- add more contrast, especially for `lualine`
				git = { changed = "#bc7d0b", add = "#4a7e65" },
			},
		},
		groups = {
			dawnfox = {
				-- custom highlights
				["StandingOut"] = { fg = "#9f2e69", style = "bold" },
				["@keyword.return"] = { link = "StandingOut" },
				["@markdown.internal_link"] = {
					fg = "palette.magenta",
					sp = "palette.magenta", -- underline color of spaces
					style = "underline",
				},

				-- general
				["LspSignatureActiveParameter"] = { link = "Visual" },
				["@namespace.builtin.lua"] = { link = "@variable.builtin" }, -- `vim` and `hs`
				["@character.printf"] = { link = "SpecialChar" },
				["@punctuation.special.gitcommit"] = { link = "Operator" },
				["ColorColumn"] = { bg = "#e9dfd2" },
				["WinSeparator"] = { fg = "#cfc1b3" },
				["Operator"] = { fg = "#846a52" },
				["@string.special.url.comment"] = { style = "underline" },
				["@markup.link.label.markdown_inline"] = { fg = "palette.orange.dim" }, -- for md in notifications
				["@markup.link"] = { style = "" }, -- no bold
				["@markup.link.url"] = { style = "" }, -- no italic
				["@markup.strong"] = { fg = "palette.blue", style = "bold" },
				["Added"] = { link = "diffAdded" },
				["Removed"] = { link = "diffRemoved" },
				["Whitespace"] = { fg = "#dfccd4" }, -- a bit darker
				Conceal = { link = "Comment" }, -- leetcode.nvim, also more readability
				LspCodeLens = { link = "LspInlayHint" },

				-- todo comments
				["@comment.todo"] = { style = "bold" },
				["@comment.error"] = { style = "bold" },
				["@comment.warning"] = { style = "bold" },
				["@comment.note"] = { style = "bold" },

				-- 1. `inline` code in comments
				-- 2. italic removed only in markdown, (still inherited from comments elsewhere)
				["@markup.raw"] = { bg = "#e9dfd2", style = "" },

				-- FIX missing differentiation in python
				["@type.builtin.python"] = { link = "Typedef" },
				["@string.documentation.python"] = { link = "Comment" },
				["@keyword.operator.python"] = { link = "Operator" },

				-- cursorword
				LspReferenceWrite = { bg = "", style = "underdashed" },
				LspReferenceRead = { bg = "", style = "underdotted" },
				LspReferenceText = { bg = "" }, -- too much noise, as it underlines e.g. strings

				-- no undercurl
				DiagnosticUnderlineHint = { style = "underline" },
				DiagnosticUnderlineInfo = { style = "underline" },
				DiagnosticUnderlineWarn = { style = "underline" },
				DiagnosticUnderlineError = { style = "underline" },
				SpellBad = { style = "underdotted" },
				SpellCap = { style = "underdotted" },
				SpellRare = { style = "underdotted" },
				SpellLocal = { style = "underdotted" },

				-- `mini.icons`
				MiniIconsGrey = { fg = "#767676" },

				-- blink.cmp
				BlinkCmpLabelMatch = { fg = "palette.orange" }, -- make matches stand out more
				BlinkCmpDocBorder = { link = "FloatBorder" },
				Pmenu = { bg = "#eadfd6" }, -- more in theme color

				-- FIX wrong bg for icons of source `buffer` and `path`
				BlinkCmpKindText = { link = "LspKindText" },
				BlinkCmpKindFile = { link = "LspKindText" },
				BlinkCmpKindFolder = { link = "LspKindText" },

				-- blink.cmp.git
				BlinkCmpGitKindPR = { fg = "palette.orange" },
				BlinkCmpGitKindIssue = { fg = "palette.orange" },
				BlinkCmpGitLabelPRId = { fg = "palette.orange" },
				BlinkCmpGitKindIconPR = { fg = "palette.orange" },
				BlinkCmpGitKindMention = { fg = "palette.orange" },
				BlinkCmpGitLabelIssueId = { fg = "palette.orange" },
				BlinkCmpGitKindIconIssue = { fg = "palette.orange" },
				BlinkCmpGitLabelMentionId = { fg = "palette.orange" },
				BlinkCmpGitKindIconMention = { fg = "palette.orange" },

				-- snacks notifier
				SnacksNotifierTitleDebug = { fg = "palette.comment" }, -- use grey for debug
				SnacksNotifierIconDebug = { fg = "palette.comment" },
				SnacksNotifierBorderDebug = { link = "FloatBorder" },
				SnacksNotifierFooterDebug = { fg = "palette.comment" },
				SnacksNotifierTitleTrace = { link = "NotifyDEBUGTitle" }, -- now unused debug-color for trace so not both grey
				SnacksNotifierIconTrace = { link = "NotifyDEBUGIcon" },
				SnacksNotifierBorderTrace = { link = "NotifyDEBUGBorder" },
				SnacksNotifierFooterTrace = { link = "NotifyDEBUGBorder" },

				-- Snacks picker
				SnacksIndent = { fg = "#e0cfbd" }, -- less contrast
				SnacksPicker = { link = "Normal" }, -- FIX background
				SnacksPickerMatch = { fg = "palette.orange" }, -- make matches stand out more
			},
		},
	},
}
