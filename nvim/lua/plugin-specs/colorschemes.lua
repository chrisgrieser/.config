-- vim: foldlevel=1
--------------------------------------------------------------------------------

local dawnfox = {
	-- config: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md
	-- palette: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md#palette
	"EdenEast/nightfox.nvim",
	colorscheme = "dawnfox",
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

local tokyonight = {
	-- config: https://github.com/folke/tokyonight.nvim#%EF%B8%8F-configuration
	-- palette: https://github.com/folke/tokyonight.nvim/blob/main/extras/lua/tokyonight_moon.lua
	"folke/tokyonight.nvim",
	colorscheme = "tokyonight",
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

local gruvboxMaterial = { --- GRUVBOX-MATERIAL
	-- https://github.com/sainnhe/gruvbox-material/blob/master/doc/gruvbox-material.txt#L144
	"sainnhe/gruvbox-material",
	colorscheme = "gruvbox-material",
	init = function(spec)
		vim.g.gruvbox_material_background = "medium" -- soft|medium|hard
		vim.g.gruvbox_material_foreground = "material" -- material|mix|original
		vim.g.gruvbox_material_ui_contrast = "high" -- low|high
		vim.g.gruvbox_material_better_performance = 1
		vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
		vim.g.gruvbox_material_inlay_hints_background = "dimmed"
		vim.g.gruvbox_material_disable_italic_comment = 1

		local name = vim.fs.basename(spec[1])
		vim.api.nvim_create_autocmd("ColorScheme", {
			desc = "User: Highlights for " .. name,
			pattern = name,
			callback = function()
				local setHl = function(...) vim.api.nvim_set_hl(0, ...) end
				local hlCmd = vim.cmd.highlight

				-- FIX MISSING HIGHLIGHTS
				-- stop globals like `vim` in lua or `Objc` in JXA from being overwritten
				setHl("@lsp.type.variable", {})
				-- placeholders like the `%s` in `string.format("foo %s bar")`
				setHl("@character.printf", { link = "Purple" })

				-- FIX selection hardly visible in DressingInput
				-- (keep it for the scrollbar though)
				setHl("Visual", { bg = "#385055" })
				setHl("SatelliteBar", { bg = "#45403d" })

				-- General
				setHl("TSParameter", { fg = "#679bbf" })
				setHl("TSConstant", { fg = "#948ecb" })
				setHl("@string.documentation.python", { link = "Comment" })
				setHl("@keyword.return", { bold = true, fg = "#f6843a" })
				setHl("TSPunctBracket", { fg = "#af7e5d" })
				vim.defer_fn(function() setHl("@constructor.lua", { fg = "#9b97a8" }) end, 1)

				-- md `inline` code in comments
				setHl("@markup.raw", { fg = "#a9b665", bg = "#3c3836" })

				-- cursorword
				setHl("LspReferenceWrite", { underdashed = true })
				setHl("LspReferenceRead", { underdotted = true })
				setHl("LspReferenceText", {})

				-- no undercurls
				hlCmd("DiagnosticUnderlineError gui=underline")
				hlCmd("DiagnosticUnderlineWarn gui=underline")
				hlCmd("DiagnosticUnderlineInfo gui=underline")
				hlCmd("DiagnosticUnderlineHint gui=underline")
				hlCmd("SpellBad gui=underdotted")
				hlCmd("SpellError gui=underdotted")
				hlCmd("SpellCap gui=underdotted")
				hlCmd("SpellLocal gui=underdotted")

				-- no overly excessive underlines/bold
				hlCmd("ErrorMsg gui=none")
				hlCmd("WarningMsg gui=none")

				-- FIX missing snacks.nvim highlights for trace
				setHl("SnacksNotifierTitleTrace", { link = "NotifyTraceTitle" })
				setHl("SnacksNotifierTitleIcon", { link = "NotifyTraceIcon" })
				setHl("SnacksNotifierTitleBorder", { link = "NotifyTraceBorder" })
				setHl("SnacksNotifierTitleFooter", { link = "NotifyTraceBorder" })

				-- FIX lazy.nvim,
				setHl("Bold", { bold = true })
				setHl("LazyReasonRequire", { link = "@variable.parameter" })
			end,
		})
	end,
}

--------------------------------------------------------------------------------

-- CONFIG
local lightTheme = dawnfox
local darkTheme = gruvboxMaterial

--------------------------------------------------------------------------------

-- TOGGLE LIGHT/DARK
-- 1. Triggered on startup in `init.lua` (not here, since lazy.nvim didn't load yet)
-- 2. and via Hammerspoon on manual mode change (`OptionSet` autocmd doesn't work reliably)
vim.g.setColorscheme = function(init)
	if init then
		-- needs to be set manually, since `Neovide` does not set correctly
		-- https://github.com/neovide/neovide/issues/3066
		local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
		vim.o.background = (macOSMode.stdout or ""):find("Dark") and "dark" or "light"
	else
		-- reset so next theme isn't affected by previous one
		vim.cmd.highlight("clear")
	end
	local nextTheme = (vim.o.background == "light" and lightTheme or darkTheme)
	vim.cmd.colorscheme(nextTheme.colorscheme)
end

--------------------------------------------------------------------------------

lightTheme.priority = 1000 -- see https://lazy.folke.io/spec/lazy_loading#-colorschemes
darkTheme.priority = 1000
return { lightTheme, darkTheme }
