-- DOCS
-- config: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md
-- palette: https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md#palette
local lightTheme = {
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
				["IndentBlankPluginCustom"] = { fg = "#e0cfbd" },

				-- general
				["@keyword.return"] = { fg = "#9f2e69", style = "bold" },
				["@namespace.builtin.lua"] = { link = "@variable.builtin" }, -- `vim` and `hs`
				["@character.printf"] = { link = "SpecialChar" },
				["ColorColumn"] = { bg = "#e9dfd2" },
				["WinSeparator"] = { fg = "#cfc1b3" },
				["Operator"] = { fg = "#846a52" },
				["@string.special.url.comment"] = { style = "underline" },
				["@markup.raw"] = { bg = "#e9dfd2" }, -- for inline code in comments
				["@markup.link.label.markdown_inline"] = { fg = "palette.orange.dim" }, -- for md in notifications
				["@markup.strong"] = { fg = "palette.magenta", style = "bold" },

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
}

--------------------------------------------------------------------------------

-- DOCS
-- config: https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
-- palette: https://github.com/folke/tokyonight.nvim/blob/main/extras/lua/tokyonight_moon.lua
local darkTheme = {
	"folke/tokyonight.nvim",
	colorscheme = "tokyonight-moon",
	opacity = 0.91,
	opts = {
		lualine_bold = true,
		on_colors = function(colors)
			colors.git.change = colors.yellow
			colors.git.add = colors.green2
		end,
		on_highlights = function(hl, colors)
			hl.IndentBlankPluginCustom = hl.IblIndent

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
}
--------------------------------------------------------------------------------
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
	local theme = (vim.o.background == "dark" and darkTheme or lightTheme)
	vim.cmd.colorscheme(theme.colorscheme)
	vim.g.neovide_transparency = theme.opacity
end

--------------------------------------------------------------------------------
darkTheme.priority = 1000 -- https://lazy.folke.io/spec/lazy_loading#-colorschemes
lightTheme.priority = 1000
return { lightTheme, darkTheme }