-- config: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md
-- palette: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md#palette
--------------------------------------------------------------------------------

return {
	"EdenEast/nightfox.nvim",
	priority = 1000,
	opts = {
		specs = {
			dawnfox = {
				-- add more contrast, especially for `lualine`
				git = { changed = "#bc7d0b", add = "#4a7e65" },
			},
		},
		groups = {
			dawnfox = {
				-- general
				["StandingOut"] = { fg = "#9f2e69", style = "bold" },
				["@keyword.return"] = { link = "StandingOut" },
				["LspSignatureActiveParameter"] = { link = "Visual" },
				["@namespace.builtin.lua"] = { link = "@variable.builtin" }, -- `vim` and `hs`
				["@character.printf"] = { link = "SpecialChar" },
				["ColorColumn"] = { bg = "#e9dfd2" },
				["WinSeparator"] = { fg = "#cfc1b3" },
				["Operator"] = { fg = "#846a52" },
				["@string.special.url.comment"] = { style = "underline" },
				["@markup.link.label.markdown_inline"] = { fg = "palette.orange.dim" }, -- for md in notifications
				["@markup.strong"] = { fg = "palette.magenta", style = "bold" },
				["Added"] = { link = "diffAdded" },
				["Removed"] = { link = "diffRemoved" },
				["Whitespace"] = { fg = "#dfccd4" }, -- bit darker

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
				SnacksPicker = { link = "Normal" },
				SnacksPickerMatch = { fg = "palette.orange" }, -- make matches stand out more
			},
		},
	},
}
