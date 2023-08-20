-- vim-pseudo-modeline: buffer_has_colors
--------------------------------------------------------------------------------
local M = {}

local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local u = require("config.utils")

--------------------------------------------------------------------------------

---@param hlgroupfrom string
---@param hlgroupto string
local function linkHighlight(hlgroupfrom, hlgroupto)
	vim.api.nvim_set_hl(0, hlgroupfrom, { link = hlgroupto, default = true })
end

---INFO not using `api.nvim_set_hl` yet as it overwrites a group instead of updating it
---@param hlgroup string
---@param changes string
local function updateHighlight(hlgroup, changes) cmd.highlight(hlgroup .. " " .. changes) end

---@param hlgroup string
local function clearHighlight(hlgroup) vim.api.nvim_set_hl(0, hlgroup, {}) end

---@param hlgroup string
---@param changes table
local function overwriteHighlight(hlgroup, changes) vim.api.nvim_set_hl(0, hlgroup, changes) end

--------------------------------------------------------------------------------

local function customHighlights()
	-- Comments
	clearHighlight("@lsp.type.comment") -- FIX: https://github.com/stsewd/tree-sitter-comment/issues/22
	local commentColor = u.getHighlightValue("Comment", "fg")
	updateHighlight(
		"@text.uri",
		("guisp=%s guifg=%s gui=underline term=underline"):format(commentColor, commentColor)
	)

	-- make MatchParen stand out more (orange to close to rainbow brackets)
	overwriteHighlight("MatchParen", { reverse = true })
	-- overwriteHighlight("MatchParenCur", { reverse = true, bold = true })

	-- proper underlines for diagnostics
	local types = { "Error", "Warn", "Info", "Hint" }
	for _, type in pairs(types) do
		updateHighlight(type .. "Text", "gui=underdouble cterm=underline")
		updateHighlight("DiagnosticUnderline" .. type, "gui=underdouble cterm=underline")
	end
end

-- selene: allow(high_cyclomatic_complexity)
local function themeModifications()
	local mode = vim.opt.background:get()
	-- some themes do not set g.colors_name
	local theme = g.colors_name
	if not theme then theme = mode == "light" and g.lightTheme or g.darkTheme end

	-- FIX lualine_a not getting bold in many themes
	local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }

	if theme == "tokyonight" then
		for _, v in pairs(vimModes) do
			updateHighlight("lualine_y_diff_modified_" .. v, "guifg=#acaa62")
			updateHighlight("lualine_y_diff_added_" .. v, "guifg=#369a96")
			updateHighlight("lualine_a_" .. v, "gui=bold")
		end
		updateHighlight("GitSignsChange", "guifg=#acaa62")
		updateHighlight("GitSignsAdd", "guifg=#369a96")
	elseif theme == "gruvbox-material" or theme == "sonokai" then
		local commentColor = u.getHighlightValue("Comment", "fg")
		updateHighlight("DiagnosticUnnecessary", "gui=underdouble cterm=underline guifg=" .. commentColor)
	elseif theme == "material" and mode == "light" then
		updateHighlight("@property", "guifg=#6c9798")
		updateHighlight("@field", "guifg=#6c9798")
		updateHighlight("Comment", "guifg=#9cb4b5")
		updateHighlight("NonText", "guifg=#9cb4b5")
		updateHighlight("NotifyINFOTitle", "guifg=#4eb400")
		updateHighlight("NotifyINFOIcon", "guifg=#4eb400")
		linkHighlight("@text.warning.comment", "WarningMsg")

		-- fix cursor being partially overwritten by the theme
		vim.opt.guicursor:append("r-cr-o-v:hor10")
		vim.opt.guicursor:append("a:blinkwait200-blinkoff500-blinkon700")

		for _, type in pairs { "Hint", "Info", "Warn", "Error" } do
			updateHighlight("DiagnosticUnderline" .. type, "gui=underdouble cterm=underline")
		end
	elseif theme == "bluloco" then
		linkHighlight("@text.note.comment", "@text.todo.comment")
		linkHighlight("@text.warning.comment", "@text.todo.comment")
		linkHighlight("@text.danger.comment", "@text.todo.comment")
		vim.opt.guicursor:append("i-ci-c:ver25")
		vim.opt.guicursor:append("o-v:hor10")
		if mode == "dark" then updateHighlight("ColorColumn", "guibg=#2e3742") end
	elseif theme == "kanagawa" then
		clearHighlight("SignColumn")
		linkHighlight("MoreMsg", "Folded") -- FIX for https://github.com/rebelot/kanagawa.nvim/issues/89
	elseif theme == "zephyr" then
		updateHighlight("IncSearch", "guifg=#FFFFFF")
		linkHighlight("TabLineSel", "lualine_a_normal")
		linkHighlight("TabLineFill", "lualine_c_normal")
	-----------------------------------------------------------------------------
	-- light themes
	elseif theme == "dawnfox" then
		updateHighlight("IndentBlanklineChar", "guifg=#e3d4c4")
		updateHighlight("ColorColumn", "guibg=#eee6dc")
		updateHighlight("VertSplit", "guifg=#b29b84")
		for _, v in pairs(vimModes) do
			updateHighlight("lualine_y_diff_modified_" .. v, "guifg=#b3880a")
		end
	elseif theme == "rose-pine" and mode == "light" then
		updateHighlight("IndentBlanklineChar", "guifg=#e3d4c4")
		updateHighlight("ColorColumn", "guibg=#eee6dc")
		updateHighlight("Headline", "gui=bold guibg=#ebe1d5")
	end
end

--------------------------------------------------------------------------------

autocmd("ColorScheme", {
	callback = function()
		-- defer needed for some modifications to properly take effect
		for _, delayMs in pairs { 50, 300 } do
			vim.defer_fn(themeModifications, delayMs)
			vim.defer_fn(customHighlights, delayMs)
		end
	end,
})

--------------------------------------------------------------------------------

---exported for remote control via hammerspoon
---@param mode "dark"|"light"
function M.setThemeMode(mode)
	vim.opt.background = mode
	g.neovide_transparency = mode == "dark" and g.darkOpacity or g.lightOpacity
	local targetTheme = mode == "dark" and g.darkTheme or g.lightTheme
	cmd.highlight("clear") -- needs to be set before colorscheme https://github.com/folke/lazy.nvim/issues/40
	cmd.colorscheme(targetTheme)
end

-- initialize theme on startup
local isDarkMode = fn.system([[defaults read -g AppleInterfaceStyle]]):find("Dark")
local targetMode = isDarkMode and "dark" or "light"
M.setThemeMode(targetMode)

--------------------------------------------------------------------------------

return M
