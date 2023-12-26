local M = {}

local fn = vim.fn
local g = vim.g

local u = require("config.utils")
--------------------------------------------------------------------------------

---@param update string
local function updateCursor(update) vim.opt.guicursor:append(update) end

---@param hlgroupfrom string
---@param hlgroupto string
local function linkHl(hlgroupfrom, hlgroupto)
	vim.api.nvim_set_hl(0, hlgroupfrom, { link = hlgroupto })
end

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
	overwriteHl("@text.uri", { fg = commentColor, underline = true })

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
end

local function themeModifications()
	local mode = vim.opt.background:get()
	local theme = g.colors_name -- some themes do not set g.colors_name
	if not theme then theme = mode == "light" and g.lightTheme or g.darkTheme end
	local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }

	if theme == "tokyonight" then
		vim.defer_fn(function()
			for _, v in pairs(vimModes) do
				updateHl("lualine_y_diff_modified_" .. v, "guifg=#dfd21b")
				updateHl("lualine_y_diff_added_" .. v, "guifg=#369a96")
				updateHl("lualine_a_" .. v, "gui=bold")
			end
		end, 100)
		updateHl("GitSignsChange", "guifg=#acaa62")
		updateHl("GitSignsAdd", "guifg=#369a96")
	elseif theme == "monet" then
		overwriteHl("NonText", { fg = "#717ca7" }) -- more distinguishable from comments
		overwriteHl("Folded", { bg = "#313548" })
		updateHl("String", "gui=none") -- no italics
		overwriteHl("Visual", { bg = "#2a454e" }) -- no bold
		updateHl("TelescopeSelection", "gui=none") -- no bold
		overwriteHl("@keyword.return", { fg = "#1c79d6", bold = true }) -- darker
		for _, v in pairs(vimModes) do
			updateHl("lualine_y_diff_modified_" .. v, "guifg=#cfc53a")
		end
		updateHl("GitSignsChange", "guifg=#acaa62")
	elseif theme == "dawnfox" then
		overwriteHl("IblIndent", { fg = "#e0cfbd" })
		overwriteHl("ColorColumn", { bg = "#e9dfd2" })
		overwriteHl("TreesitterContext", { bg = "#e6d9cb" })
		overwriteHl("VertSplit", { fg = "#b29b84" })
		overwriteHl("Operator", { fg = "#846a52" })
		for _, v in pairs(vimModes) do
			updateHl("lualine_y_diff_modified_" .. v, "guifg=#a9810a")
		end
		-- FIX python highlighting issues
		linkHl("@type.builtin.python", "Typedef")
		linkHl("@string.documentation.python", "Typedef")
		linkHl("@keyword.operator.python", "Operator")

	-----------------------------------------------------------------------------
	elseif theme == "gruvbox-material" or theme == "sonokai" or theme == "everforest" then
		local commentColor = u.getHighlightValue("Comment", "fg")
		updateHl("DiagnosticUnnecessary", "gui=underdouble cterm=underline guifg=" .. commentColor)
		overwriteHl("TSParameter", { fg = "#6f92b3" })
		if theme == "everforest" then overwriteHl("Red", { fg = "#ce7d7c" }) end
	elseif theme == "bamboo" and mode == "light" then
		overwriteHl("@comment", { fg = "#777f76" })
		updateHl("Todo", "guifg=#ffffff")
		updateHl("@text.note", "guifg=#ffffff")
		updateHl("@text.warning", "guifg=#ffffff")
		updateHl("@text.danger", "guifg=#ffffff")
	elseif theme == "material" and mode == "light" then
		updateHl("@property", "guifg=#6c9798")
		updateHl("@field", "guifg=#6c9798")
		updateHl("Comment", "guifg=#9cb4b5")
		updateHl("NonText", "guifg=#9cb4b5")
		updateHl("NotifyINFOTitle", "guifg=#4eb400")
		updateHl("NotifyINFOIcon", "guifg=#4eb400")
		linkHl("@text.warning.comment", "WarningMsg")

		-- fix cursor being partially overwritten by the theme
		updateCursor("r-cr-o-v:hor10")
		updateCursor("a:blinkwait200-blinkoff500-blinkon700")

		for _, type in pairs { "Hint", "Info", "Warn", "Error" } do
			updateHl("DiagnosticUnderline" .. type, "gui=underdouble cterm=underline")
		end
	elseif theme == "bluloco" then
		linkHl("@text.note.comment", "@text.todo.comment")
		linkHl("@text.warning.comment", "@text.todo.comment")
		linkHl("@text.danger.comment", "@text.todo.comment")
		updateCursor("i-ci-c:ver25")
		updateCursor("o-v:hor10")
		if mode == "dark" then updateHl("ColorColumn", "guibg=#2e3742") end
	elseif theme == "kanagawa" then
		overwriteHl("TreesitterContext", { bg = "#363648" })
		-- transparent sign column
		clearHl("SignColumn")
		updateHl("GitSignsAdd", "guibg=none")
		updateHl("GitSignsChange", "guibg=none")
		updateHl("GitSignsDelete", "guibg=none")

		vim.defer_fn(function()
			for _, v in pairs(vimModes) do
				updateHl("lualine_a_" .. v, "gui=bold")
			end
		end, 100)
		for _, type in pairs { "Hint", "Info", "Warn", "Error" } do
			updateHl("DiagnosticSign" .. type, "guibg=none")
		end
	end
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		themeModifications()
		customHighlights()
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
local targetMode = isDarkMode and "dark" or "light"
M.setThemeMode(targetMode)

--------------------------------------------------------------------------------

return M
