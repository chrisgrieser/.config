local themes = {
	{ --- DAWNFOX
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
					["@keyword.return"] = { fg = "#9f2e69", style = "bold" },
					["@keyword.break"] = { fg = "#9f2e69", style = "bold" },
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

					-- eyeliner.nvim
					EyelinerSecondary = { fg = "palette.blue" },

					-- `mini.icons`
					MiniIconsGrey = { fg = "#767676" },

					-- blink.cmp
					BlinkCmpLabelMatch = { fg = "palette.orange" }, -- make matches stand out more
					BlinkCmpDocBorder = { link = "FloatBorder" },

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

					-- use grey for debug
					SnacksNotifierTitleDebug = { fg = "palette.comment" },
					SnacksNotifierIconDebug = { fg = "palette.comment" },
					SnacksNotifierBorderDebug = { link = "FloatBorder" },
					SnacksNotifierFooterDebug = { fg = "palette.comment" },

					-- use now unused debug-color for trace to they aren't both grey
					SnacksNotifierTitleTrace = { link = "NotifyDEBUGTitle" },
					SnacksNotifierIconTrace = { link = "NotifyDEBUGIcon" },
					SnacksNotifierBorderTrace = { link = "NotifyDEBUGBorder" },
					SnacksNotifierFooterTrace = { link = "NotifyDEBUGBorder" },

					-- Snacks
					SnacksIndent = { fg = "#e0cfbd" }, -- less contrast
					SnacksPicker = { link = "Normal" },
					SnacksPickerMatch = { fg = "palette.orange" }, -- make matches stand out more
				},
			},
		},
	},
	{ --- TOKYONIGHT
		-- config: https://github.com/folke/tokyonight.nvim#%EF%B8%8F-configuration
		-- palette: https://github.com/folke/tokyonight.nvim/blob/main/extras/lua/tokyonight_moon.lua
		"folke/tokyonight.nvim",
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
				hl["@keyword.return"] = { fg = colors.magenta2, bold = true }
				hl["@keyword.break"] = { fg = colors.magenta2, bold = true }
				hl["@markup.strong"] = { fg = colors.fg_dark, bold = true }
				hl["@string.documentation.python"] = { link = "Comment" }
				hl.Comment = { fg = colors.comment, italic = false }
				hl.LspSignatureActiveParameter = { link = "Visual" }
				hl.Added = { fg = colors.green2 }
				hl.Removed = { fg = colors.red }

				-- FIX bold/italic being white in lazy.nvim window
				hl.Bold = { bold = true }
				hl.Italic = { italic = true }

				-- FIX hlgroup not set when starting in different color scheme
				hl.TelescopeSelection = { link = "Visual" }

				-- FIX wrong background color for icons of the source `path`
				hl.BlinkCmpKindFile = { link = "LspKindText" }

				-- make matches stand out more
				hl.BlinkCmpLabelMatch = { fg = colors.yellow }
				hl.TelescopeMatching = { fg = colors.yellow }

				-- color bg, not fg (TODO INFO ERROR WARN)
				hl["@comment.todo"] = { fg = colors.black, bg = hl["@comment.todo"].fg }
				hl["@comment.error"] = { fg = colors.black, bg = hl["@comment.error"].fg }
				hl["@comment.warning"] = { fg = colors.black, bg = hl["@comment.warning"].fg }
				hl["@comment.note"] = { fg = colors.black, bg = hl["@comment.note"].fg }

				-- mini.icons
				hl.MiniIconsGreen = { fg = "#9de88d" }
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
	},
	{ --- GRUVBOX-MATERIAL
		-- https://github.com/sainnhe/gruvbox-material/blob/master/doc/gruvbox-material.txt#L144
		"sainnhe/gruvbox-material",
		init = function(spec)
			vim.g.gruvbox_material_background = "medium" -- soft|medium|hard
			vim.g.gruvbox_material_foreground = "material" -- material|mix|original
			vim.g.gruvbox_material_ui_contrast = "high" -- low|high
			vim.g.gruvbox_material_better_performance = 1
			vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
			vim.g.gruvbox_material_inlay_hints_background = "dimmed"

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
	},
}

--------------------------------------------------------------------------------

themes = vim.iter(themes)
	:filter(function(theme) return theme.enabled ~= false end)
	:map(function(theme)
		theme.priority = 1000 -- see https://lazy.folke.io/spec/lazy_loading#-colorschemes
		-- `colorscheme` is not part of the lazy.nvim spec, but
		-- only helpers for the light-dark-mode toggling below
		if not theme.colorscheme then
			theme.colorscheme = vim.fs.basename(theme[1]):gsub("%.?nvim%-?", "")
		end
		return theme
	end)
	:take(2)
	:totable()

-- TOGGLE LIGHT/DARK
-- 1. Triggered on startup in `init.lua` (not here, since lazy.nvim didn't load yet)
-- 2. and via Hammerspoon on manual mode change (`OptionSet` autocmd doesn't work reliably)
vim.g.setColorscheme = function(init)
	if init then
		-- needs to be set manually, since `Neovide` does not set it in time on startup
		local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
		vim.o.background = macOSMode.stdout:find("Dark") and "dark" or "light"
	else
		-- reset so next theme isn't affected by previous one
		vim.cmd.highlight("clear")
	end
	local nextTheme = (vim.o.background == "light" and themes[1] or themes[2])
	vim.cmd.colorscheme(nextTheme.colorscheme)
end

--------------------------------------------------------------------------------
return themes
