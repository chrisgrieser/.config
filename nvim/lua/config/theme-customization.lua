local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local u = require("config.utils")

local M = {}
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

--------------------------------------------------------------------------------

local function customHighlights()
	-- stylua: ignore
	local highlights = { "DiagnosticUnderlineError", "DiagnosticUnderlineWarn", "DiagnosticUnderlineHint", "DiagnosticUnderlineInfo", "SpellLocal", "SpellRare", "SpellCap", "SpellBad" }
	for _, v in pairs(highlights) do
		updateHighlight(v, "gui=underdouble cterm=underline")
	end

	-- FIX: https://github.com/stsewd/tree-sitter-comment/issues/22
	clearHighlight("@lsp.type.comment")
	fn.matchadd("@text.todo.comment", [[\<\(WIP\|INFO\)\>]])
	fn.matchadd("@text.warning.comment", [[\<\(WARN\|FIX\)\>]])

	local commentColor = u.getHighlightValue("Comment", "fg")
	updateHighlight("@text.uri", ("guisp=%s guifg=%s gui=underline term=underline"):format(commentColor, commentColor))

	local overnestingIndent = 8
	updateHighlight("Overnesting", "guibg=#E06C75")
	fn.matchadd("Overnesting", ("\t"):rep(overnestingIndent) .. "\t*")

	updateHighlight("TSRainbowred", "guifg=#7e8a95") -- rainbow brackets without aggressive red
	updateHighlight("MatchParen", "gui=underdotted,bold cterm=underline,bold") -- more visible matchparens
	updateHighlight("TSDefinition", " term=underline gui=underdotted") -- treesittter refactor focus
	updateHighlight("TSDefinitionUsage", " term=underline gui=underdotted")
	updateHighlight("QuickScopePrimary", "gui=reverse cterm=reverse")
	updateHighlight("QuickScopeSecondary", "gui=underdouble cterm=underline")
end

local function themeModifications()
	local mode = vim.opt.background:get()
	local theme = g.colors_name
	-- some themes do not set g.colors_name
	if not theme then theme = mode == "light" and g.lightTheme or g.darkTheme end

	local vimModes = { "normal", "visual", "insert", "terminal", "replace", "command", "inactive" }
	-- FIX lualine_a not getting bold in some themes
	for _, v in pairs(vimModes) do
		updateHighlight("lualine_a_" .. v, "gui=bold")
	end

	if theme == "tokyonight" then
		for _, v in pairs(vimModes) do
			updateHighlight("lualine_y_diff_modified_" .. v, "guifg=#acaa62")
			updateHighlight("lualine_y_diff_added_" .. v, "guifg=#8cbf8e")
		end
		updateHighlight("GitSignsChange", "guifg=#acaa62")
		updateHighlight("GitSignsAdd", "guifg=#7fcc82")
		updateHighlight("ScrollView", "guibg=#5a71b3")
	elseif theme == "oxocarbon" then
		linkHighlight("FloatTitle", "TelescopePromptTitle")
		linkHighlight("@function", "@function.builtin")
	elseif theme == "material" then
		updateHighlight("@property", "guifg=#6c9798")
		updateHighlight("@field", "guifg=#6c9798")
		updateHighlight("Comment", "guifg=#9cb4b5")
		updateHighlight("NonText", "guifg=#9cb4b5")
		linkHighlight("ScrollView", "Substitute")
	elseif theme == "sweetie" and mode == "light" then
		linkHighlight("ScrollView", "Visual")
		linkHighlight("NotifyINFOIcon", "@string")
		linkHighlight("NotifyINFOTitle", "@string")
		linkHighlight("NotifyINFOBody", "@string")
	elseif theme == "bluloco" then
		linkHighlight("@text.note.comment", "@text.todo.comment")
		linkHighlight("@text.warning.comment", "@text.todo.comment")
		linkHighlight("@text.danger.comment", "@text.todo.comment")
		clearHighlight("MatchParen")
		vim.opt.guicursor:append("i-ci-c:ver25")
		vim.opt.guicursor:append("o-v:hor10")
		if mode == "dark" then
			updateHighlight("ScrollView", "guibg=#303d50")
			updateHighlight("ColorColumn", "guibg=#2e3742")
		end
	elseif theme == "kanagawa" then
		updateHighlight("ScrollView", "guibg=#303050")
		updateHighlight("VirtColumn", "guifg=#323036")
		clearHighlight("SignColumn")
		-- linkHighlight("MoreMsg", "Folded") -- FIX for https://github.com/rebelot/kanagawa.nvim/issues/89

		-- stylua: ignore
		local noBackground = { "GitSignsAdd", "GitSignsDelete", "GitSignsChange", "DiagnosticSignHint", "DiagnosticSignInfo", "DiagnosticSignWarn", "DiagnosticSignError" }
		for _, hlGroup in pairs(noBackground) do
			updateHighlight(hlGroup, "guibg=NONE")
		end
	elseif theme == "zephyr" then
		updateHighlight("IncSearch", "guifg=#FFFFFF")
		linkHighlight("TabLineSel", "lualine_a_normal")
		linkHighlight("TabLineFill", "lualine_c_normal")
	elseif theme == "dawnfox" then
		updateHighlight("IndentBlanklineChar", "guifg=#e3d4c4")
		updateHighlight("ScrollView", "guibg=#303050")
		updateHighlight("ColorColumn", "guibg=#ebe1d5")
		updateHighlight("VertSplit", "guifg=#b29b84")
		for _, v in pairs(vimModes) do
			updateHighlight("lualine_y_diff_modified_" .. v, "guifg=#b3880a")
		end
	elseif theme == "rose-pine" and mode == "light" then
		updateHighlight("IndentBlanklineChar", "guifg=#e3d4c4")
		updateHighlight("ScrollView", "guibg=#505030")
		updateHighlight("ColorColumn", "guibg=#eee6dc")
		updateHighlight("Headline", "gui=bold guibg=#ebe1d5")
	end
end

--------------------------------------------------------------------------------

autocmd("ColorScheme", {
	callback = function()
		-- defer needed for some modifications to properly take effect
		for _, delayMs in pairs { 50, 200 } do
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
	g.neovide_transparency = mode == "dark" and g.darkTransparency or g.lightTransparency
	local targetTheme = mode == "dark" and g.darkTheme or g.lightTheme
	cmd.colorscheme(targetTheme)
end

-- initialize theme on startup
local isDarkMode = fn.system([[defaults read -g AppleInterfaceStyle]]):find("Dark")
local targetMode = isDarkMode and "dark" or "light"
M.setThemeMode(targetMode)

--------------------------------------------------------------------------------

return M
