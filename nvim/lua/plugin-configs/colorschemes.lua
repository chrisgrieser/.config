local themes = {
	{ --- DAWNFOX
		-- config: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md
		-- palette: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md#palette
		"EdenEast/nightfox.nvim",
		colorscheme = "dawnfox",
		opacity = 0.92,
		opts = {
			options = {
				styles = { comments = "italic" },
			},
			specs = {
				dawnfox = {
					-- add more contrast, especially for `lualine`
					git = { changed = "#bc7d0b", add = "#4a7e65" },
				},
			},
			groups = {
				dawnfox = {
					-- indent-blank-line: more contrast
					["IblIndent"] = { fg = "#e0cfbd" },

					-- general
					["@keyword.return"] = { fg = "#9f2e69", style = "bold" },
					["@namespace.builtin.lua"] = { link = "@variable.builtin" }, -- `vim` and `hs`
					["@character.printf"] = { link = "SpecialChar" },
					["ColorColumn"] = { bg = "#e9dfd2" },
					["WinSeparator"] = { fg = "#cfc1b3" },
					["Operator"] = { fg = "#846a52" },
					["@string.special.url.comment"] = { style = "underline" },
					["@markup.link.label.markdown_inline"] = { fg = "palette.orange.dim" }, -- for md in notifications
					["@markup.strong"] = { fg = "palette.magenta", style = "bold" },

					-- 1. `inline` code in comments
					-- 2. italic removed only in markdown, (still inherited from comments elsewhere)
					["@markup.raw"] = { bg = "#e9dfd2", style = "" },

					-- python
					["@type.builtin.python"] = { link = "Typedef" },
					["@string.documentation.python"] = { link = "Typedef" },
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

					-- telescope: increase contrast
					TelescopeBorder = { link = "FloatBorder" },
					TelescopeTitle = { fg = "palette.comment" },
					TelescopeResultsComment = { fg = "palette.comment" },

					-- snacks.nvim
					SnacksNormal = { link = "NotifyBackground" },

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
				},
			},
		},
	},
	{ --- TOKYONIGHT
		-- config: https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
		-- palette: https://github.com/folke/tokyonight.nvim/blob/main/extras/lua/tokyonight_moon.lua
		"folke/tokyonight.nvim",
		enabled = false,
		opacity = 0.91,
		opts = {
			style = "moon",
			lualine_bold = true,
			on_colors = function(colors)
				colors.git.change = colors.yellow
				colors.git.add = colors.green2
			end,
			on_highlights = function(hl, colors)
				-- general
				hl["@keyword.return"] = { fg = colors.magenta2, bold = true }
				hl["@markup.strong"] = { fg = colors.fg_dark, bold = true }
				hl["diffAdded"] = { fg = colors.green }

				-- FIX bold/italic being white in lazy.nvim window
				hl.Bold = { bold = true }
				hl.Italic = { italic = true }

				-- color bg, not fg (TODO INFO ERROR WARN)
				hl["@comment.todo"] = { fg = colors.black, bg = hl["@comment.todo"].fg }
				hl["@comment.error"] = { fg = colors.black, bg = hl["@comment.error"].fg }
				hl["@comment.warning"] = { fg = colors.black, bg = hl["@comment.warning"].fg }
				hl["@comment.note"] = { fg = colors.black, bg = hl["@comment.note"].fg }

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
		opacity = 0.92,
		init = function(spec)
			vim.g.gruvbox_material_background = "soft"
			vim.g.gruvbox_material_ui_contrast = "high"
			vim.g.gruvbox_material_better_performance = 1
			vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
			vim.g.gruvbox_material_inlay_hints_background = "dimmed"

			vim.api.nvim_create_autocmd("ColorScheme", {
				desc = "User: gruvbox material highlights",
				pattern = vim.fs.basename(spec[1]),
				callback = function()
					-- General
					vim.api.nvim_set_hl(0, "@keyword.return", { bold = true, fg = "#f6843a" })
					vim.api.nvim_set_hl(0, "@lsp.type.variable.lua", {}) -- FIX lua-globals
					vim.api.nvim_set_hl(0, "TSPunctBracket", { fg = "#af7e5d" })
					vim.defer_fn(
						function() vim.api.nvim_set_hl(0, "@constructor.lua", { fg = "#9b97a8" }) end,
						1
					)
					vim.api.nvim_set_hl(0, "@character.printf", { link = "Purple" }) -- lua :format()
					-- md inline code in comments
					vim.api.nvim_set_hl(0, "@markup.raw", { fg = "#a9b665", bg = "#3c3836" })

					-- cursorword
					vim.api.nvim_set_hl(0, "LspReferenceWrite", { underdashed = true })
					vim.api.nvim_set_hl(0, "LspReferenceRead", { underdotted = true })
					vim.api.nvim_set_hl(0, "LspReferenceText", {})

					-- no undercurls
					vim.cmd.highlight("DiagnosticUnderlineError gui=underline")
					vim.cmd.highlight("DiagnosticUnderlineWarn gui=underline")
					vim.cmd.highlight("DiagnosticUnderlineInfo gui=underline")
					vim.cmd.highlight("DiagnosticUnderlineHint gui=underline")
					vim.cmd.highlight("SpellBad gui=underdotted")
					vim.cmd.highlight("SpellError gui=underdotted")
					vim.cmd.highlight("SpellCap gui=underdotted")
					vim.cmd.highlight("SpellLocal gui=underdotted")

					-- no bold (TODO INFO ERROR WARN)
					-- vim.api.nvim_set_hl(0, "@comment.todo", { bg = "#7daea3", fg = "#32302f" })
					-- vim.api.nvim_set_hl(0, "@comment.error", { bg = "#ea6962", fg = "#32302f" })
					-- vim.api.nvim_set_hl(0, "@comment.warning", { bg = "#d8a657", fg = "#32302f" })
					-- vim.api.nvim_set_hl(0, "@comment.note", { bg = "#a9b665", fg = "#32302f" })
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
		-- `colorscheme` and `opacity` are not part of the lazy.nvim spec, but
		-- only helpers for the light-dark-mode toggling below
		if not theme.colorscheme then
			theme.colorscheme = vim.fs.basename(theme[1]):gsub("%.?nvim%-?", "")
		end
		if not theme.opacity then theme.opacity = 0.9 end
		return theme
	end)
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
	vim.g.neovide_transparency = nextTheme.opacity
end

--------------------------------------------------------------------------------
return themes
