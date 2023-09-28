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

	overwriteHighlight("LspReferenceWrite", { underdashed = true }) -- i.e. definition
	overwriteHighlight("LspReferenceRead", { underdotted = true }) -- i.e. reference
	overwriteHighlight("LspReferenceText", {}) -- too much noise, as is underlines e.g. strings

	-- make `MatchParen` stand out more (orange to close to rainbow brackets)
	overwriteHighlight("MatchParen", { reverse = true })

	-- proper underlines for diagnostics
	for _, type in pairs { "Error", "Warn", "Info", "Hint" } do
		updateHighlight("DiagnosticUnderline" .. type, "gui=underdouble cterm=underline")
	end
end

local function themeModifications()
	local mode = vim.opt.background:get()
	local theme = g.colors_name -- some themes do not set g.colors_name
	if not theme then theme = mode == "light" and g.lightTheme or g.darkTheme end

	-- FIX lualine_a not getting bold in many themes
	local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }

	if theme == "tokyonight" then
		vim.defer_fn(function()
			for _, v in pairs(vimModes) do
				updateHighlight("lualine_y_diff_modified_" .. v, "guifg=#acaa62")
				updateHighlight("lualine_y_diff_added_" .. v, "guifg=#369a96")
				updateHighlight("lualine_a_" .. v, "gui=bold")
			end
		end, 100)
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
		-- transparent sign column
		clearHighlight("SignColumn")
		updateHighlight("GitSignsAdd", "guibg=none")
		updateHighlight("GitSignsChange", "guibg=none")
		updateHighlight("GitSignsDelete", "guibg=none")
		-- bold lualine
		vim.defer_fn(function()
			for _, v in pairs(vimModes) do
				updateHighlight("lualine_a_" .. v, "gui=bold")
			end
		end, 100)
		for _, type in pairs { "Hint", "Info", "Warn", "Error" } do
			updateHighlight("DiagnosticSign" .. type, "guibg=none")
		end

		linkHighlight("MoreMsg", "Folded") -- FIX for https://github.com/rebelot/kanagawa.nvim/issues/89
	elseif theme == "zephyr" then
		updateHighlight("IncSearch", "guifg=#FFFFFF")
		linkHighlight("TabLineSel", "lualine_a_normal")
		linkHighlight("TabLineFill", "lualine_c_normal")
	-----------------------------------------------------------------------------
	-- light themes
	elseif theme == "dawnfox" then
		updateHighlight("IblIndent", "guifg=#e0cfbd")
		updateHighlight("ColorColumn", "guibg=#eee6dc")
		updateHighlight("VertSplit", "guifg=#b29b84")
		for _, v in pairs(vimModes) do
			updateHighlight("lualine_y_diff_modified_" .. v, "guifg=#a9810a")
		end
		updateHighlight("Operator", "guifg=#846a52")
		-- FIX python highlighting issues
		linkHighlight("@type.builtin.python", "Typedef")
		linkHighlight("@string.documentation.python", "Typedef")
		linkHighlight("@keyword.operator.python", "Operator")
	elseif theme == "rose-pine" and mode == "light" then
		updateHighlight("IblIndent", "guifg=#e3d4c4")
		updateHighlight("ColorColumn", "guibg=#eee6dc")
		updateHighlight("Headline", "gui=bold guibg=#ebe1d5")
	end
end

--------------------------------------------------------------------------------

autocmd("ColorScheme", {
	callback = function()
		themeModifications()
		customHighlights()
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

-- INFO on adding new lualine elements, the lualine highlights are set again,
-- resulting in a loss of its styling. Therefore, the theme customizations have
-- to be applied again.
function M.reloadTheming() themeModifications() end

-- initialize theme on startup
local isDarkMode = fn.system([[defaults read -g AppleInterfaceStyle]]):find("Dark")
local targetMode = isDarkMode and "dark" or "light"
M.setThemeMode(targetMode)

--------------------------------------------------------------------------------

return M
