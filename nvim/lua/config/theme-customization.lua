local M = {}

local fn = vim.fn
local g = vim.g

local u = require("config.utils")
--------------------------------------------------------------------------------

---@param update string
local function updateCursor(update) vim.opt.guicursor:append(update) end

---@param fromGroup string
---@param toGroup string
local function linkHl(fromGroup, toGroup) vim.api.nvim_set_hl(0, fromGroup, { link = toGroup }) end

---INFO not using `api.nvim_set_hl` yet as it overwrites a group instead of updating it
---@param hlgroup string
---@param changes string
local function updateHl(hlgroup, changes) vim.cmd.highlight(hlgroup .. " " .. changes) end

---@param hlgroup string
local function clearHl(hlgroup) vim.api.nvim_set_hl(0, hlgroup, {}) end

---@param hlgroup string
---@param changes { link?: string, fg?: string, bg?: string, underline?: boolean, reverse?: boolean, underdashed?: boolean, underdotted?: boolean, underdouble?: boolean }
local function overwriteHl(hlgroup, changes) vim.api.nvim_set_hl(0, hlgroup, changes) end

--------------------------------------------------------------------------------

local function customHighlights()
	-- FIX https://github.com/stsewd/tree-sitter-comment/issues/22
	clearHl("@lsp.type.comment")

	-- better url look
	local commentColor = u.getHighlightValue("Comment", "fg")
	overwriteHl("@string.special.url.comment", { fg = commentColor, underline = true })

	-- make `MatchParen` stand out more
	overwriteHl("MatchParen", { reverse = true })

	-- use underlines instead of undercurls for diagnostics
	for _, type in pairs { "Error", "Warn", "Info", "Hint" } do
		updateHl("DiagnosticUnderline" .. type, "gui=underline cterm=underline")
	end

	-- underdotted for spell issues (used only for git commit messages though)
	for _, type in pairs { "Bad", "Cap", "Rare", "Local" } do
		updateHl("Spell" .. type, "gui=underdotted cterm=underline")
	end

	-- trailing spaces more visible
	linkHl("Whitespace", "NonText")

	-- FIX themes markdown italics missing in many themes
	overwriteHl("@markup.italic.markdown_inline", { italic = true })

	-- de-emphasize commit messages between 50 and 72 chars
	linkHl("@comment.warning.gitcommit", "WarningMsg")
end

local function themeModifications()
	local mode = vim.o.background
	local theme = g.colors_name
	-- some themes do not set g.colors_name
	if not theme then theme = mode == "light" and g.lightTheme or g.darkTheme end
	local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }

	local function boldLualineA()
		for _, v in pairs(vimModes) do
			updateHl("lualine_a_" .. v, "gui=bold")
		end
	end
	-- INFO
	local function revertedTodoComments()
		local types = { todo = "Hint", error = "Error", warning = "Warn", note = "Info" }
		local textColor = mode == "dark" and "#000000" or "#ffffff"
		for type, altType in pairs(types) do
			local fg = u.getHighlightValue("@comment." .. type, "fg")
				or u.getHighlightValue("Diagnostic" .. altType, "fg")
			if fg and fg ~= textColor then
				overwriteHl("@comment." .. type, { bg = fg, fg = textColor })
			end
		end
	end

	-----------------------------------------------------------------------------

	if theme == "tokyonight" then
		local statuslineYellow = mode == "dark" and "#b8b042" or "#e8e05e"
		for _, vimMode in pairs(vimModes) do
			updateHl("lualine_y_diff_modified_" .. vimMode, "guifg=" .. statuslineYellow)
			updateHl("lualine_y_diff_added_" .. vimMode, "guifg=#369a96")
		end
		updateHl("GitSignsChange", "guifg=#acaa62")
		updateHl("GitSignsAdd", "guifg=#369a96")

		updateHl("@keyword.return", "guifg=#fd4283")
		if mode == "dark" then revertedTodoComments() end
	elseif theme == "neomodern" and mode == "light" then
		vim.defer_fn(revertedTodoComments, 1)
		overwriteHl("@keyword.return", { fg = "#fd4283", bold = true })
		overwriteHl("NonText", { fg = "#b5b5bb" })
		overwriteHl("IblIndent", { fg = "#d8d8db" })
		for _, v in pairs(vimModes) do
			updateHl("lualine_a_" .. v, "guifg=#ffffff")
		end
		overwriteHl("NotifyINFOIcon", { fg = "#00b9a2" })
		overwriteHl("NotifyINFOTitle", { fg = "#00b9a2" })
		-- higher contrast
		overwriteHl("@lsp.mod.readonly", { fg = "#ec9403" })
		overwriteHl("@keyword", { fg = "#9255e6" })
		overwriteHl("@keyword.conditional", { fg = "#9255e6" })
	elseif theme == "dracula" then
		boldLualineA()
		revertedTodoComments()
		clearHl("Constant")
		linkHl("Boolean", "Special")
		linkHl("Number", "@field")
		overwriteHl("@keyword.return", { fg = "#5e9fff", bold = true })
	elseif theme == "dawnfox" then
		overwriteHl("@ibl.indent.char.1", { fg = "#e0cfbd" })
		overwriteHl("ColorColumn", { bg = "#e9dfd2" })
		overwriteHl("TreesitterContext", { bg = "#e6d9cb" })
		overwriteHl("VertSplit", { fg = "#b29b84" })
		overwriteHl("Operator", { fg = "#846a52" })
		for _, v in pairs(vimModes) do
			updateHl("lualine_y_diff_modified_" .. v, "guifg=#828208")
		end
		updateHl("@keyword.return", "gui=bold")

		-- FIX python highlighting issues
		linkHl("@type.builtin.python", "Typedef")
		linkHl("@string.documentation.python", "Typedef")
		linkHl("@keyword.operator.python", "Operator")
	elseif theme == "gruvbox-material" or theme == "sonokai" then
		local commentColor = u.getHighlightValue("Comment", "fg")
		updateHl("DiagnosticUnnecessary", "gui=underdouble cterm=underline guifg=" .. commentColor)
		overwriteHl("TSParameter", { fg = "#6f92b3" })
		overwriteHl("@keyword.return", { fg = "#b577c8", bold = true })
	elseif theme == "material" and mode == "light" then
		updateHl("@property", "guifg=#6c9798")
		updateHl("@field", "guifg=#6c9798")
		updateHl("Comment", "guifg=#9cb4b5")
		updateHl("NonText", "guifg=#9cb4b5")
		updateHl("NotifyINFOTitle", "guifg=#4eb400")
		updateHl("NotifyINFOIcon", "guifg=#4eb400")

		-- fix cursor being partially overwritten by the theme
		updateCursor("r-cr-o-v:hor10")
		updateCursor("a:blinkwait200-blinkoff500-blinkon700")

		for _, type in pairs { "Hint", "Info", "Warn", "Error" } do
			updateHl("DiagnosticUnderline" .. type, "gui=underdouble cterm=underline")
		end
	elseif theme == "kanagawa" then
		boldLualineA()
		overwriteHl("TreesitterContext", { bg = "#363648" })

		-- transparent sign column
		clearHl("SignColumn")
		updateHl("GitSignsAdd", "guibg=none")
		updateHl("GitSignsChange", "guibg=none")
		updateHl("GitSignsDelete", "guibg=none")

		for _, type in pairs { "Hint", "Info", "Warn", "Error" } do
			updateHl("DiagnosticSign" .. type, "guibg=none")
		end
	elseif theme == "bluloco" then
		updateCursor("i-ci-c:ver25")
		updateCursor("o-v:hor10")
		if mode == "dark" then updateHl("ColorColumn", "guibg=#2e3742") end
	end
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		customHighlights()
		vim.defer_fn(themeModifications, 100)
	end,
})

---exported for remote control via hammerspoon
---@param mode "dark"|"light"
function M.setThemeMode(mode)
	vim.opt.background = mode
	local targetTheme = mode == "dark" and g.darkTheme or g.lightTheme
	vim.cmd.highlight("clear") -- needs to be set before colorscheme https://github.com/folke/lazy.nvim/issues/40
	vim.cmd.colorscheme(targetTheme)
end

-- INFO on adding new lualine elements, the lualine highlights are set again,
-- resulting in a loss of its styling. Therefore, the theme customizations have
-- to be applied again.
function M.reloadTheming() themeModifications() end

-- initialize theme on startup
local isDarkMode = fn.system([[defaults read -g AppleInterfaceStyle]]):find("Dark")
M.setThemeMode(isDarkMode and "dark" or "light")

--------------------------------------------------------------------------------
return M
